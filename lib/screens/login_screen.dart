// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../i18n/strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return S.t(context, 'enter_email_pass');
    final ok = RegExp(r'^\S+@\S+\.\S+$').hasMatch(s);
    if (!ok) return S.t(context, 'invalid_email');
    return null;
  }

  String? _validatePass(String? v) {
    final s = (v ?? '').trim();
    if (s.length < 6) return S.t(context, 'pass_min');
    return null;
  }

  Future<void> _submit({required bool create}) async {
    final current = FocusScope.of(context);
    if (!(_form.currentState?.validate() ?? false)) return;
    current.unfocus();

    setState(() => _loading = true);
    try {
      final email = _email.text.trim();
      final pass = _pass.text.trim();

      if (create) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pass,
        );
      }
      // AuthGate سيتولّى التوجيه بعد النجاح
    } on FirebaseAuthException catch (e) {
      _toast(e.message ?? e.code);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      // AuthGate سيحوّل تلقائيًا بعد نجاح تسجيل الضيف
    } on FirebaseAuthException catch (_) {
      if (!mounted) return;
      // fallback: افتح الشات كضيف محلي بلا مزامنة
      Navigator.of(context).pushReplacementNamed('/chat');
      _toast(S.t(context, 'guest_local'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.t(context, 'signin_title')),
        actions: [
          IconButton(
            tooltip: S.t(context, 'settings'),
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // heading
                  Text(
                    'Smart Tasks AI',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    S.t(context, 'welcome_line'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),

                  // card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              decoration: InputDecoration(
                                labelText: S.t(context, 'email'),
                                prefixIcon: const Icon(Icons.alternate_email),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pass,
                              obscureText: _obscure,
                              validator: _validatePass,
                              decoration: InputDecoration(
                                labelText: S.t(context, 'password'),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: _loading
                                        ? null
                                        : () => _submit(create: false),
                                    child: _loading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(S.t(context, 'sign_in')),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _loading
                                        ? null
                                        : () => _submit(create: true),
                                    child:
                                        Text(S.t(context, 'create_account')),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _loading ? null : _continueAsGuest,
                      style: TextButton.styleFrom(foregroundColor: cs.primary),
                      child: Text(S.t(context, 'continue_guest')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
