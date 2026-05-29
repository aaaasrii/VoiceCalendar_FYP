import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voca_assist/globals.dart' as globals;
import 'package:voca_assist/services/ai_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speechToText;
  bool _isRecording = false;
  bool _isTyping = false;

  final AIService _aiService = AIService();
  late final GenerativeModel _model;
  late final ChatSession _chat; // Persistent chat session

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();

    final scheduleTool = Tool(
      functionDeclarations: [
        FunctionDeclaration(
          'createAppointment',
          'Use this to schedule an appointment when the user mentions a title and a date.',
          Schema(
            SchemaType.object,
            properties: {
              'title': Schema(
                SchemaType.string,
                description: 'Title of the event',
              ),
              'date': Schema(
                SchemaType.string,
                description: 'Date in YYYY-MM-DD format',
              ),
            },
            requiredProperties: ['title', 'date'],
          ),
        ),
      ],
    );

    // ------------------------------------------------------------------------
    // UPDATED: Stricter System Instruction so the AI is forced to use the tool
    // ------------------------------------------------------------------------
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AIService.geminiApiKey,
      tools: [scheduleTool],
      systemInstruction: Content.system(
        "You are Voca-Assist. If the user mentions scheduling, an event, or a date, "
        "you MUST ONLY use the createAppointment tool. Do not reply with regular text "
        "if they want to schedule something. Today's date is ${DateTime.now().toString()}.",
      ),
    );

    // Start the chat here so it stays connected!
    _chat = _model.startChat();
  }

  // --- MIC LOGIC ---
  void _handleRecording() async {
    if (!_isRecording) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => debugPrint('Status: $status'),
        onError: (errorNotification) => debugPrint('Error: $errorNotification'),
      );

      if (available) {
        setState(() => _isRecording = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _textController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isRecording = false);
      _speechToText.stop();
      if (_textController.text.isNotEmpty) {
        _sendMessage();
      }
    }
  }

  // --- SEND MESSAGE & AI LOGIC ---
  Future<void> _sendMessage() async {
    final userText = _textController.text.trim();
    if (userText.isEmpty) return;

    try {
      debugPrint('DEBUG LOG: Parsing appointment from STT/text input: $userText');
      final structuredJson = await _aiService.parseAppointment(userText);
      debugPrint('DEBUG LOG: parseAppointment JSON -> $structuredJson');
    } catch (e) {
      debugPrint('ERROR: parseAppointment failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment parsing failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    debugPrint("DEBUG LOG: Send button pressed! Text: $userText");

    setState(() {
      _messages.add({"role": "user", "text": userText});
      _textController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      debugPrint("DEBUG LOG: Attempting to reach Gemini API...");

      // Use the persistent _chat session initialized in initState
      final response = await _chat.sendMessage(Content.text(userText));

      debugPrint("DEBUG LOG: Gemini replied successfully!");

      final functionCalls = response.functionCalls.toList();

      if (functionCalls.isNotEmpty) {
        for (final call in functionCalls) {
          if (call.name == 'createAppointment') {
            final title = call.args['title'] as String;
            final dateStr = call.args['date'] as String;

            debugPrint("DEBUG LOG: Saving to Firestore -> $title on $dateStr");

            // Save to Firestore
            await FirebaseFirestore.instance.collection('events').add({
              'title': title,
              'date': DateTime.parse(dateStr),
              'user': globals.loggedInUsername,
              'created_at': FieldValue.serverTimestamp(),
            });

            setState(() {
              _isTyping = false;
              _messages.add({
                "role": "ai",
                "text": "✅ Success! I've scheduled '$title' for $dateStr.",
              });
            });
          }
        }
      } else {
        setState(() {
          _isTyping = false;
          _messages.add({
            "role": "ai",
            "text": response.text ?? "I'm not sure how to help with that.",
          });
        });
      }
    } catch (e) {
      debugPrint("CRITICAL ERROR: $e");

      // This will pop up a red error message on your phone screen!
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("AI Connection Error: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      setState(() {
        _isTyping = false;
        _messages.add({
          "role": "ai",
          "text":
              "Sorry, I couldn't connect. Please check your internet or API key.",
        });
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: _buildDrawer(context),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFF3DA4FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _messages.isEmpty
                    ? const Center(
                        child: Text(
                          "What can I help you\ntoday?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg["role"] == "user";
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.white.withAlpha(230)
                                    : const Color(0xFFB3E5FC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                msg["text"]!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.only(left: 25, bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Voca-Assist is thinking...",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black54),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
      child: Column(
        children: [
          Center(
            child: GestureDetector(
              onTap: _handleRecording,
              child: Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                  gradient: LinearGradient(
                    colors: _isRecording
                        ? [Colors.redAccent, Colors.orangeAccent]
                        : [const Color(0xFFD1FFDA), const Color(0xFF98B7FF)],
                  ),
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic_none_outlined,
                  size: 35,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFFD1FFDA), Color(0xFF98B7FF)],
              ),
            ),
            child: TextField(
              controller: _textController,
              textAlign: TextAlign.center,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: _isRecording
                    ? "Listening..."
                    : "Ask Voca-Assist . . .",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFE3F2FD),
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFB3E5FC)),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF5E5E8C)),
              ),
            ),
            accountName: Text(
              globals.loggedInUsername,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
              child: const Text(
                "Edit profile >",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.event_note, color: Colors.blue),
            title: const Text("Upcoming Events"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/events');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text("Calendar View"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/calendar');
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
