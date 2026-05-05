// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../i18n/strings.dart';
import '../services/api_service.dart';

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String text;
  final DateTime ts;
  ChatMessage({required this.role, required this.text, DateTime? ts})
      : ts = ts ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  final String? initialGoal;
  const ChatScreen({super.key, this.initialGoal});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final g = widget.initialGoal?.trim();
    if (g != null && g.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(g));
    }
  }

  Future<void> _send([String? override]) async {
    final text = (override ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', text: text));
      _sending = true;
      if (override == null) _controller.clear();
    });

    final history = _messages.take(8).map((m) => {
          'role': m.role,
          'content': m.text,
        }).toList();

    try {
      final reply =
          await ApiService.instance.sendMessage(text, history: history);
      setState(() => _messages.add(ChatMessage(role: 'assistant', text: reply)));
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          role: 'assistant',
          text: 'Error: $e\n\n${S.t(context, 'mock_banner')}',
        ));
      });
    } finally {
      setState(() => _sending = false);
      await Future.delayed(const Duration(milliseconds: 60));
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  List<String> _parseTasks(String text) {
    final lines = text.split('\n');
    final reg = RegExp(r'^\s*(?:[-*•]|(?:\d+[\.\)]))\s+(.*)$');
    final tasks = <String>[];
    for (final l in lines) {
      final m = reg.firstMatch(l.trim());
      if (m != null) {
        final t = m.group(1)!.trim();
        if (t.isNotEmpty) tasks.add(t);
      }
    }
    if (tasks.isEmpty && text.trim().isNotEmpty) tasks.add(text.trim());
    return tasks.take(10).toList();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _addTasksFromLastReply() async {
    final last = _messages.lastWhere(
      (m) => m.role == 'assistant',
      orElse: () => ChatMessage(role: 'assistant', text: ''),
    ).text.trim();

    if (last.isEmpty) {
      _toast(S.t(context, 'no_reply_to_convert'));
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _toast('Please sign in first.');
      return;
    }

    final items = _parseTasks(last);
    final col = FirebaseFirestore.instance
        .collection('users').doc(uid).collection('tasks');

    final batch = FirebaseFirestore.instance.batch();
    for (var i = 0; i < items.length; i++) {
      final t = items[i];
      final doc = col.doc();
      batch.set(doc, {
        'title': t,
        'done': false,
        'createdAt': FieldValue.serverTimestamp(),
        'aiOrder': i + 1,
      });
    }
    await batch.commit();
    _toast(S.t(context, 'added_tasks_n').replaceFirst('{n}', items.length.toString()));
  }

  void _copyLastReply() {
    final last = _messages.lastWhere(
      (m) => m.role == 'assistant',
      orElse: () => ChatMessage(role: 'assistant', text: ''),
    ).text;
    if (last.trim().isEmpty) {
      _toast(S.t(context, 'no_reply_to_copy'));
      return;
    }
    Clipboard.setData(ClipboardData(text: last));
    _toast(S.t(context, 'copied'));
  }

  void _clearChat() => setState(() => _messages.clear());

  String _fmtTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Widget _banner() {
    final api = ApiService.instance;
    if (api.apiAvailable) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? Colors.amber.shade200.withOpacity(0.20)
        : Colors.amber.shade100;
    final fg = isDark ? Colors.redAccent : Colors.black87;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        S.t(context, 'mock_banner'),
        style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _bubble(ChatMessage m) {
    final isUser = m.role == 'user';
    final bg = isUser ? Colors.blue.shade600 : Colors.grey.shade200;
    final fg = isUser ? Colors.white : Colors.black87;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    final bubble = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.06),
            )
          ],
        ),
        child: Text(m.text, style: TextStyle(color: fg, fontSize: 15)),
      ),
    );

    final time = Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        _fmtTime(m.ts),
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      ),
    );

    return Align(
      alignment: align,
      child: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: m.text));
          _toast(S.t(context, 'copied'));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [bubble, time],
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    final bottom = MediaQuery.of(context).padding.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + (bottom > 0 ? 0 : 8)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: _sending
                      ? S.t(context, 'waiting_reply')
                      : S.t(context, 'type_message'),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.08),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // عنوان متوسّط + يقتص تلقائيًا مع كثرة الأزرار
        title: Text(
          S.t(context, 'chat_title'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        // خفّضنا عدد الأزرار الظاهرة لتوسيع مساحة العنوان
        actions: [
          IconButton(
            tooltip: S.t(context, 'settings'),
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'add':
                  _addTasksFromLastReply();
                  break;
                case 'copy':
                  _copyLastReply();
                  break;
                case 'clear':
                  _clearChat();
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'add', child: Text(S.t(context, 'add_from_reply'))),
              PopupMenuItem(value: 'copy', child: Text(S.t(context, 'copy_last_reply'))),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'clear', child: Text(S.t(context, 'clear_chat'))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _banner(),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _bubble(_messages[i]),
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }
}
