// lib/screens/task_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../i18n/strings.dart';
import 'chat_screen.dart';

class TaskSetupScreen extends StatefulWidget {
  const TaskSetupScreen({super.key});

  @override
  State<TaskSetupScreen> createState() => _TaskSetupScreenState();
}

class _TaskSetupScreenState extends State<TaskSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note  = TextEditingController();
  final _tag   = TextEditingController();

  DateTime? _due;

  /// 0=low, 1=normal, 2=high
  int _prio = 1;
  bool _showMore = false;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _tag.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      initialDate: _due ?? now,
    );
    if (picked != null) setState(() => _due = picked);
  }

  String _prioStr() => _prio == 0 ? 'low' : (_prio == 2 ? 'high' : 'normal');

  Color _prioColor(int p) {
    switch (p) {
      case 2: return Colors.red;       // High
      case 0: return Colors.green;     // Low
      default: return Colors.blueGrey; // Normal
    }
  }

  void _createWithAI() {
    if ((_title.text.trim()).isEmpty) {
      _toast(S.t(context, 'title_label'));
      return;
    }
    final b = StringBuffer('${S.t(context, 'goal')}: ${_title.text.trim()}');
    if (_note.text.trim().isNotEmpty) {
      b.write('\n${S.t(context, 'context')}: ${_note.text.trim()}');
    }
    if (_due != null) {
      final d = _due!;
      b.write('\n${S.t(context, 'due')}: ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }
    b.write('\n${S.t(context, 'priority_label')}: ${_prioStr()}');
    if (_tag.text.trim().isNotEmpty) {
      b.write('\n${S.t(context, 'tag')}: ${_tag.text.trim()}');
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(initialGoal: b.toString())),
    );
  }

  Future<void> _saveTask() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _toast('Sign in first');
      return;
    }

    final col = FirebaseFirestore.instance
        .collection('users').doc(uid).collection('tasks');

    await col.add({
      'title': _title.text.trim(),
      'note': _note.text.trim().isEmpty ? null : _note.text.trim(),
      'due': _due != null ? Timestamp.fromDate(_due!) : null,
      'priority': _prioStr(),
      'tag': _tag.text.trim().isEmpty ? null : _tag.text.trim(),
      'done': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      _toast(S.t(context, 'save_success'));
      Navigator.of(context).pop();
    }
  }

  Widget _heroCard() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer.withOpacity(.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: cs.primary.withOpacity(.15),
            child: Icon(Icons.checklist_rounded, color: cs.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              S.t(context, 'hero_text'),
              style: TextStyle(
                color: cs.onSecondaryContainer.withOpacity(.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleCard() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.6),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: TextFormField(
        controller: _title,
        autofocus: true,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: S.t(context, 'title_label'),
          hintText: 'e.g., Write project report',
          prefixIcon: const Icon(Icons.title),
          border: const OutlineInputBorder(),
        ),
        validator: (v) => (v ?? '').trim().isEmpty ? S.t(context, 'title_label') : null,
      ),
    );
  }

  Widget _quickChips() {
    final labels = <String>[
      S.t(context, 'preset_study'),
      S.t(context, 'preset_grocery'),
      S.t(context, 'preset_clean'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((p) {
        return ActionChip(
          label: Text(p),
          avatar: const Icon(Icons.bolt_outlined, size: 18),
          onPressed: () {
            _title.text = p;
            if (p == S.t(context, 'preset_study')) {
              _note.text = 'Math, 2 hours, Pomodoro';
              _prio = 2;
            } else if (p == S.t(context, 'preset_grocery')) {
              _note.text = 'Fruits, veggies, dairy';
              _tag.text = 'Home';
              _prio = 1;
            } else if (p == S.t(context, 'preset_clean')) {
              _note.text = 'Desk, cables, wipe surfaces';
              _prio = 0;
            }
            setState(() {});
          },
        );
      }).toList(),
    );
  }

  Widget _moreOptionsCard() {
    final cs = Theme.of(context).colorScheme;
    return AnimatedCrossFade(
      crossFadeState: _showMore ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 200),
      firstChild: Container(
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(.45),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Notes
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: S.t(context, 'notes_optional'),
                hintText: S.t(context, 'notes_hint'),
                prefixIcon: const Icon(Icons.notes_outlined),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),

            // Priority
            Align(
              alignment: Alignment.centerLeft,
              child: Text(S.t(context, 'priority'),
                  style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(S.t(context, 'low')),
                  selected: _prio == 0,
                  onSelected: (_) => setState(() => _prio = 0),
                  selectedColor: Colors.green.withOpacity(.2),
                  labelStyle: TextStyle(color: _prio == 0 ? _prioColor(0) : null),
                ),
                ChoiceChip(
                  label: Text(S.t(context, 'normal')),
                  selected: _prio == 1,
                  onSelected: (_) => setState(() => _prio = 1),
                  selectedColor: Colors.blueGrey.withOpacity(.2),
                  labelStyle: TextStyle(color: _prio == 1 ? _prioColor(1) : null),
                ),
                ChoiceChip(
                  label: Text(S.t(context, 'high')),
                  selected: _prio == 2,
                  onSelected: (_) => setState(() => _prio = 2),
                  selectedColor: Colors.red.withOpacity(.2),
                  labelStyle: TextStyle(color: _prio == 2 ? _prioColor(2) : null),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tag + Due
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tag,
                    decoration: InputDecoration(
                      labelText: S.t(context, 'tag_optional'),
                      hintText: S.t(context, 'tag_hint'),
                      prefixIcon: const Icon(Icons.sell_outlined),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: S.t(context, 'due_optional'),
                        prefixIcon: const Icon(Icons.event_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          _due == null
                              ? S.t(context, 'no_due_date')
                              : '${_due!.year}-${_due!.month.toString().padLeft(2, '0')}-${_due!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: _due == null
                                ? Theme.of(context).hintColor
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      secondChild: const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          S.t(context, 'new_task'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            tooltip: S.t(context, 'settings'),
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: cs.surfaceVariant.withOpacity(.25),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _heroCard(),
                      const SizedBox(height: 12),
                      _titleCard(),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              icon: const Icon(Icons.save_outlined),
                              label: Text(S.t(context, 'save_task')),
                              onPressed: _saveTask,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.smart_toy_outlined),
                              label: Text(S.t(context, 'create_with_ai')),
                              onPressed: _createWithAI,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      _quickChips(),

                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => setState(() => _showMore = !_showMore),
                        icon: Icon(_showMore ? Icons.expand_less : Icons.expand_more),
                        label: Text(_showMore
                            ? S.t(context, 'hide_optional')
                            : S.t(context, 'show_optional')),
                      ),

                      _moreOptionsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
