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

  Future<List<Map<String, dynamic>>> suggestTaskOrder(
    List<Map<String, dynamic>> tasks,
  ) async {
    if (tasks.isEmpty) return [];

    // وضع mock إذا ما فيه مفتاح
    if (_useMock || _apiKey.isEmpty) {
      int score(Map<String, dynamic> t) {
        final priority = (t['priority'] ?? 'normal').toString();
        final dueRaw = t['due']?.toString();
        final due = DateTime.tryParse(dueRaw ?? '');

        final pScore = priority == 'high'
            ? 0
            : priority == 'normal'
                ? 1
                : 2;

        final dueScore = due == null
            ? 50
            : due.difference(DateTime.now()).inDays.abs();

        return pScore * 100 + dueScore;
      }

      final ranked = List<Map<String, dynamic>>.from(tasks)
        ..sort((a, b) => score(a).compareTo(score(b)));

      return [
        for (var i = 0; i < ranked.length; i++)
          {
            'id': ranked[i]['id'],
            'rank': i + 1,
            'reason': 'Mock heuristic',
          }
      ];
    }

    final prompt = '''
Return JSON only in this shape:
{"items":[{"id":"TASK_ID","rank":1,"reason":"..."}]}

Rank these tasks from most important to least important for the user to finish first.
Use due date, priority, urgency, and note if available.

Tasks:
${jsonEncode(tasks.map((t) => {
        'id': t['id'],
        'title': t['title'],
        'note': t['note'],
        'priority': t['priority'],
        'due': t['due'],
        'tag': t['tag'],
      }).toList())}
''';

    final resp = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are Smart Tasks AI. Return only valid JSON. No markdown.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.2,
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('OpenAI error ${resp.statusCode}: ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    final content = data['choices']?[0]?['message']?['content'];

    if (content is! String) return [];

    final jsonText = _extractJson(content);
    final decoded = jsonDecode(jsonText) as Map<String, dynamic>;
    final items = (decoded['items'] as List? ?? []);

    return items.map((e) {
      final m = e as Map<String, dynamic>;
      return {
        'id': m['id'].toString(),
        'rank': int.tryParse(m['rank'].toString()) ?? 9999,
        'reason': (m['reason'] ?? '').toString(),
      };
    }).toList();
  }
}

String _extractJson(String text) {
  final cleaned = text
      .replaceAll(RegExp(r'```json', multiLine: true), '')
      .replaceAll('```', '')
      .trim();

  final start = cleaned.indexOf('{');
  final end = cleaned.lastIndexOf('}');
  if (start == -1 || end == -1 || end <= start) return cleaned;

  return cleaned.substring(start, end + 1);
}
