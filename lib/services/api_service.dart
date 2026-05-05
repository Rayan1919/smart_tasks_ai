import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  // مرر المفتاح وقت التشغيل:
  // flutter run --dart-define=OPENAI_API_KEY=sk-XXXX
  final String _apiKey =
      const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  // Mock Mode:
  // flutter run --dart-define=USE_MOCK_AI=true
  final bool _useMock =
      const String.fromEnvironment('USE_MOCK_AI', defaultValue: 'false')
          .toLowerCase() ==
      'true';

  bool get apiAvailable => _apiKey.isNotEmpty && !_useMock;

  Future<String> sendMessage(
    String userMessage, {
    List<Map<String, String>>? history,
  }) async {
    if (_useMock || _apiKey.isEmpty) {
      return _mockReply(userMessage);
    }

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'You are Smart Tasks AI. Be concise and helpful for task management.'
      },
      if (history != null) ...history,
      {'role': 'user', 'content': userMessage},
    ];

    final resp = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.3,
      }),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body);
      final content = data['choices']?[0]?['message']?['content'];
      return (content is String) ? content : 'No content';
    } else {
      throw Exception('OpenAI error ${resp.statusCode}: ${resp.body}');
    }
  }

  String _mockReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('task') || lower.contains('organize') || lower.contains('مهام')) {
      return 'Here are 3 quick tasks:\n'
          '1) List your top 3 priorities.\n'
          '2) Block 25 minutes for the first one.\n'
          '3) Add a 6pm review reminder.';
    }
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('سلام')) {
      return 'Hi! I can turn your goals into short actionable tasks.';
    }
    return 'Got it. Tell me your goal and I will suggest a short checklist.';
  }
}
