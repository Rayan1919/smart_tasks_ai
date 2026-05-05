import 'package:flutter/material.dart';
import 'chat_screen.dart';

class GoalInputScreen extends StatefulWidget {
  const GoalInputScreen({super.key});

  @override
  State<GoalInputScreen> createState() => _GoalInputScreenState();
}

class _GoalInputScreenState extends State<GoalInputScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToChat() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(initialGoal: text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set your goal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your goal',
                hintText: 'e.g., Finish the report draft',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _goToChat,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
