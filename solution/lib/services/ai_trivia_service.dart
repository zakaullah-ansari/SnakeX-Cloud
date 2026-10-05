import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · AiTriviaService
/// SYLLABUS: REST API integration + async/await + exception handling.
///
/// ZERO native ML SDKs. A hosted LLM is just… an HTTP endpoint.
/// One POST out, one string back — the whole "AI feature" is ~10 lines.
/// ─────────────────────────────────────────────────────────────────────────
class AiTriviaService {
  // Groq's free tier is OpenAI-API-compatible → students' code also works
  // against https://api.openai.com/v1/chat/completions by swapping the key.
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  // NEVER hardcode keys. Injected at run time:
  //   flutter run --dart-define=GROQ_API_KEY=gsk_your_key_here
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  static const List<String> _offlineRoasts = [
    'The arcade council has reviewed your score and declared it… vintage.',
    'Somewhere, a Nokia 3310 is laughing. Quietly. In T9.',
    'Retro fact: the 1976 game Blockade started it all — and it had no score to beat. You do.',
  ];

  /// Sends [score] to the AI "intermission host" and returns ONE sentence
  /// of retro trivia or a lovingly savage roast. The core request below
  /// is the 10-line live-coding demo (STEP 7 of the workshop).
  Future<String> fetchGameOverTrivia(int score) async {
    if (_apiKey.isEmpty) {
      // Offline / DartPad mode: the show must go on without a key.
      return _offlineRoasts[Random().nextInt(_offlineRoasts.length)];
    }
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Give a 1-sentence funny retro gaming fact or roast for '
                      'someone who scored $score in Snake.',
            }
          ],
          'max_tokens': 60,
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['choices'][0]['message']['content'] as String;
    } catch (_) {
      // SYLLABUS: exception handling — Wi-Fi down, key revoked, quota hit…
      // A hosted AI is an *unreliable third party*. Bound it, never crash.
      return 'The AI judge lost signal📡… but a score of $score still echoes through the arcade.';
    }
  }
}
