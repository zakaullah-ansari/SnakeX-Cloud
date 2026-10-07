import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// ─────────────────────────────────────────────────────────────────────────
/// SnakeX Cloud · STARTER — AiTriviaService
/// SYLLABUS: REST API + async/await + try/catch. ~10 lines of YOUR code.
/// A hosted LLM is just an HTTP endpoint: one POST out, one string back.
/// ─────────────────────────────────────────────────────────────────────────
class AiTriviaService {
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  // Injected at run time — NEVER hardcode keys:
  //   flutter run --dart-define=GROQ_API_KEY=gsk_your_key_here
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  static const List<String> _offlineRoasts = [
    'The arcade council has reviewed your score and declared it… vintage.',
    'Somewhere, a Nokia 3310 is laughing. Quietly. In T9.',
    'Retro fact: the 1976 game Blockade started it all — and it had no score to beat. You do.',
  ];

  Future<String> fetchGameOverTrivia(int score) async {
    if (_apiKey.isEmpty) {
      return _offlineRoasts[Random().nextInt(_offlineRoasts.length)];
    }
    // TODO(STEP 7): the famous 10-line AI call —
    //   try {
    //     final response = await http.post(
    //       Uri.parse(_endpoint),
    //       headers: {'Authorization': 'Bearer $_apiKey',
    //                 'Content-Type': 'application/json'},
    //       body: jsonEncode({'model': _model, 'messages': [
    //         {'role': 'user', 'content':
    //           'Give a 1-sentence funny retro gaming fact or roast '
    //           'for someone who scored $score in Snake.'}]}),
    //     );
    //     final data = jsonDecode(response.body);
    //     return data['choices'][0]['message']['content'];
    //   } catch (_) {
    //     return 'The AI judge lost signal📡… but $score echoes on.';
    //   }
    return 'TODO Step 7: call the AI and return its 1-liner!';
  }
}
