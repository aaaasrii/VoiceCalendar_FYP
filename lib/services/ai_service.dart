import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  /// Supply at build/run time: --dart-define=GEMINI_API_KEY=your_key_here
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  GenerativeModel _buildModel() {
    if (geminiApiKey.isEmpty) {
      throw StateError(
        'GEMINI_API_KEY is not configured. '
        'Pass it via --dart-define=GEMINI_API_KEY=...',
      );
    }
    return GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: geminiApiKey,
    );
  }

  Future<String> parseAppointment(String userInput) async {
    final model = _buildModel();

    final prompt = '''
You are a scheduling assistant. Extract appointment details from this user input:
"$userInput"

Return ONLY a raw JSON string with no markdown, no code fences, and no extra text.
The JSON object must contain exactly these keys:
{"title": "", "date": "YYYY-MM-DD", "time": "HH:MM", "action": "create"}

Rules:
- "title": short event name inferred from the input
- "date": ISO date in YYYY-MM-DD format
- "time": 24-hour time in HH:MM format; use "00:00" if no time is mentioned
- "action": always the literal string "create"
- If no year is mentioned, use ${DateTime.now().year}
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final raw = response.text?.trim() ?? '';

    if (raw.isEmpty) {
      throw FormatException('Gemini returned an empty response');
    }

    return _extractRawJson(raw);
  }

  String _extractRawJson(String raw) {
    final fenced = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      caseSensitive: false,
    ).firstMatch(raw);
    if (fenced != null) {
      return fenced.group(1)!.trim();
    }
    return raw;
  }
}
