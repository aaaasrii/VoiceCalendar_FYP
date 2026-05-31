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
      model: 'gemini-2.5-flash',
      apiKey: geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<String> parseAppointment(String userInput) async {
    final model = _buildModel();
    final now = DateTime.now().toIso8601String();

    final prompt = '''
System Context: Today's exact date and time is $now. You must calculate all relative dates (like 'tomorrow', 'next week') strictly based on this current date.

You are a scheduling assistant. Extract appointment details from this user input:
"$userInput"

OUTPUT FORMAT (mandatory):
Return ONLY valid JSON matching this exact schema (replace placeholders with extracted values):
{"title": "...", "date": "YYYY-MM-DD", "time": "HH:MM", "action": "create"}
Do NOT wrap the response in Markdown code blocks (no ```json fences). No explanation or extra text.
The JSON object MUST contain exactly these four keys and no others.

Field rules:
- "title": short event name inferred from the input (string, never omit)
- "date": calendar date as YYYY-MM-DD (string, never omit)
- "time": 24-hour clock as HH:MM (string, never omit); use "00:00" if no time is mentioned
- "action": must be the literal string "create" (never omit, never change)
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
