import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _currentStatus = 'Checking Mic...'; // Added status tracker

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    // We pass status and error listeners to see what's happening in the console
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => setState(() => _currentStatus = status),
      onError: (errorNotification) =>
          setState(() => _currentStatus = 'Error: $errorNotification'),
    );
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      localeId: "en_US",
      // ✅ We move both into listenOptions to follow the new rules
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
      ),
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Demo'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Status Indicator (Very helpful for debugging)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Status: $_currentStatus',
                style: TextStyle(
                  color: _currentStatus == 'listening'
                      ? Colors.red
                      : Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: Colors.grey[100],
                child: Text(
                  _lastWords.isEmpty
                      ? (_speechEnabled
                            ? 'Tap the mic and speak...'
                            : 'Mic not ready')
                      : _lastWords,
                  style: const TextStyle(fontSize: 24, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isNotListening
            ? _startListening
            : _stopListening,
        tooltip: 'Listen',
        backgroundColor: _speechToText.isListening ? Colors.red : Colors.blue,
        child: Icon(_speechToText.isNotListening ? Icons.mic_none : Icons.mic),
      ),
    );
  }
}
