import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ProfileSpeechScreen extends StatefulWidget {
  const ProfileSpeechScreen({super.key});

  @override
  State<ProfileSpeechScreen> createState() => _ProfileSpeechScreenState();
}

class _ProfileSpeechScreenState extends State<ProfileSpeechScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _wordsSpoken = "Tap the mic and speak...";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _wordsSpoken = result.recognizedWords;
          });
        },
      );
      setState(() {
        _isListening = true;
      });
    } else {
      debugPrint("Speech permissions denied or device not supported.");
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // FIXED: Changed menu icon to a functional back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.indigo),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.indigo)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              // Add settings logic here later
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION ---
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFB3E5FC),
                  child: ClipOval(
                    child: Image.network(
                      'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                      // This "errorBuilder" is the fix!
                      // If the internet fails, it shows a person icon instead of crashing.
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        );
                      },
                      // This shows a loading spinner while the image downloads
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // ... rest of your Column code (User Name, etc.)
              ],
            ),

            // --- SPEECH DISPLAY SECTION ---
            const Text(
              "Voice Insight:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isListening
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                _wordsSpoken,
                style: TextStyle(
                  fontSize: 16,
                  color: _isListening ? Colors.red : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- TAGS SECTION ---
            const Text(
              "Attributes:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            Wrap(
              spacing: 8,
              children: [
                _buildChip("Clarity", Colors.teal[50]!, Colors.teal),
                _buildChip("Fluency", Colors.blue[50]!, Colors.blue),
                _buildChip("Accuracy", Colors.purple[50]!, Colors.purple),
              ],
            ),
            const SizedBox(height: 30),

            // --- GRID CARDS SECTION ---
            const Text(
              "My Reports:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildReportCard(
                  "Daily Log",
                  Icons.assignment,
                  Colors.orange[50]!,
                  Colors.orange,
                ),
                _buildReportCard(
                  "Love Report",
                  Icons.favorite,
                  Colors.pink[50]!,
                  Colors.pink,
                ),
                _buildReportCard(
                  "Progress",
                  Icons.analytics,
                  Colors.green[50]!,
                  Colors.green,
                ),
                _buildReportCard(
                  "Monthly",
                  Icons.calendar_month,
                  Colors.blue[50]!,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 100), // Bottom padding for FAB
          ],
        ),
      ),

      // --- FLOATING MIC BUTTON ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isListening ? Colors.red : Colors.indigo,
        onPressed: _isListening ? _stopListening : _startListening,
        child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home_outlined),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/chat'),
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.indigo),
                onPressed: () {}, // Already on Profile
              ),
              const SizedBox(width: 40), // Space for FAB
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/chat'),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () => Navigator.pushNamed(context, '/calendar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color text) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: text, fontWeight: FontWeight.bold),
      ),
      backgroundColor: bg,
      side: BorderSide.none,
    );
  }

  Widget _buildReportCard(
    String title,
    IconData icon,
    Color color,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Text(
            "View analysis...",
            style: TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
