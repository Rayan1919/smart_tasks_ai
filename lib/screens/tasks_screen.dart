// lib/screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../i18n/strings.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // 0 = All, 1 = Active, 2 = Done
  int _filter = 0;
  final _search = TextEditingController();

  CollectionReference<Map<String, dynamic>>? _col;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .withConverter<Map<String, dynamic>>(
            fromFirestore: (snap, _) => snap.data() ?? {},
            toFirestore: (data, _) => data,
          );
      _col = col;
      _stream = col.orderBy('createdAt', descending: true).snapshots();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _clearCompleted() async {
    if (_col == null) return;
    final qs = await _col!.where('done', isEqualTo: true).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in qs.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(S.t(context, 'clear_completed'))));
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Color _priorityColor(String p, {bool background = false}) {
    switch (p) {
      case 'high':
        return background ? Colors.red.withOpacity(.10) : Colors.red;
      case 'low':
        return background ? Colors.green.withOpacity(.10) : Colors.green;
      default:
        return background ? Colors.blueGrey.withOpacity(.12) : Colors.blueGrey;
    }
  }

  Widget _priorityChip(String? pRaw) {
    final p = (pRaw ?? 'normal');
    final color = _priorityColor(p);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _priorityColor(p, background: true),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            p == 'high'
                ? Icons.arrow_upward
                : p == 'low'
                    ? Icons.arrow_downward
                    : Icons.drag_handle,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            p[0].toUpperCase() + p.substring(1),
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.deepPurple.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sell_outlined, size: 14),
          const SizedBox(width: 4),
          Text(tag, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _dueChip(DateTime d, {required bool overdue}) {
    final color = overdue ? Colors.red : Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: overdue ? Colors.red.withOpacity(.10) : Colors.blueGrey.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(_fmtDate(d), style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // لو ما تم تهيئة الـ stream (مثلاً ما فيه مستخدم)
    if (_col == null || _stream == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(S.t(context, 'tasks_title')),
          actions: [
            IconButton(
              tooltip: S.t(context, 'settings'),
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.t(context, 'please_sign_in')),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
                child: Text(S.t(context, 'go_to_login')),
              ),
            ],
          ),
        ),
      );
    }

    final col = _col!;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.t(context, 'tasks_title')),
        actions: [
          // زر الإعدادات
          IconButton(
            tooltip: S.t(context, 'settings'),
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
          // رابط الشات
          IconButton(
            tooltip: S.t(context, 'ai_chat'),
            onPressed: () => Navigator.of(context).pushNamed('/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
          ),
          // قائمة العمليات
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear_done') await _clearCompleted();
              if (v == 'signout') await FirebaseAuth.instance.signOut();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'clear_done', child: Text(S.t(context, 'clear_completed'))),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'signout', child: Text(S.t(context, 'sign_out'))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // فلاتر
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, icon: const Icon(Icons.list_alt), label: Text(S.t(context, 'filter_all'))),
                ButtonSegment(value: 1, icon: const Icon(Icons.radio_button_unchecked), label: Text(S.t(context, 'filter_active'))),
                ButtonSegment(value: 2, icon: const Icon(Icons.check_circle), label: Text(S.t(context, 'filter_done'))),
              ],
              selected: <int>{_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
          ),
          const SizedBox(height: 8),
          // بحث
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              textDirection: TextDirection.ltr, // يحافظ على اتجاه البحث حتى بالعربية
              decoration: InputDecoration(
                hintText: S.t(context, 'search_hint'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // القائمة
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _stream, // stream ثابت — ما يعيد الاشتراك كل مرة
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allDocs = snap.data?.docs ?? [];

                // فلترة على الجهاز
                final filtered = allDocs.where((d) {
                  final data = d.data();
                  final title = (data['title'] ?? '').toString();
                  final done  = (data['done']  ?? false) as bool;
                  final tag   = (data['tag']   ?? '').toString();

                  final okStatus = _filter == 0 ? true : (_filter == 1 ? !done : done);
                  final q = _search.text.trim().toLowerCase();
                  final okSearch = q.isEmpty ||
                      title.toLowerCase().contains(q) ||
                      tag.toLowerCase().contains(q);

                  return okStatus && okSearch;
                }).toList();

                final total = allDocs.length;
                final active = allDocs.where((d) {
                  final data = d.data();
                  return (data['done'] ?? false) == false;
                }).length;

                if (total == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_outlined, size: 64),
                          const SizedBox(height: 10),
                          Text(S.t(context, 'no_tasks'),
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(S.t(context, 'use_plus')),
                        ],
                      ),
                    ),
                  );
                }

                // ملخّص أعلى القائمة (مترجم يدويًا بسيط)
                final lang = Localizations.localeOf(context).languageCode;
                final summary = lang == 'ar'
                    ? '$active نشِطة • $total الكل'
                    : '$active active • $total total';

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(summary,
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 100),
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final doc = filtered[i];
                          final id = doc.id;
                          final data = doc.data();

                          final title = (data['title'] ?? '').toString();
                          final done = (data['done'] ?? false) as bool;
                          final prio = (data['priority'] ?? 'normal').toString();
                          final tag  = (data['tag'] ?? '').toString();

                          DateTime? due;
                          final dueRaw = data['due'];
                          if (dueRaw is Timestamp) {
                            due = dueRaw.toDate();
                          }

                          final overdue = due != null &&
                              DateTime(due.year, due.month, due.day)
                                  .isBefore(DateTime.now());

                          final chips = <Widget>[
                            _priorityChip(prio),
                            if (tag.isNotEmpty) _tagChip(tag),
                            if (due != null) _dueChip(due, overdue: !done && overdue),
                          ];

                          return Dismissible(
                            key: ValueKey(id),
                            background: Container(color: Colors.red.withOpacity(0.1)),
                            onDismissed: (_) => col.doc(id).delete(),
                            child: CheckboxListTile(
                              title: Text(title),
                              subtitle: chips.isEmpty
                                  ? null
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: chips,
                                      ),
                                    ),
                              value: done,
                              onChanged: (v) => col.doc(id).update({'done': v ?? false}),
                              secondary: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => col.doc(id).delete(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/setup'),
        icon: const Icon(Icons.add_task),
        label: Text(S.t(context, 'new_task')),
      ),
    );
  }
}
