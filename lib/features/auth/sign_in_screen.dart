import 'package:flutter/material.dart';
import 'package:aqua_node/core/widgets/status_chip.dart';
import 'package:aqua_node/state/app_state.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController(), _pass = TextEditingController();
  bool _busy = false, _hide = true; String? _error;

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    final err = await store.signIn(_email.text.trim(), _pass.text);
    if (mounted) setState(() { _busy = false; _error = err; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: Center(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Form(key: _key, child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Icon(Icons.water_drop, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text('Aqua Node', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
              Text('Sign in to manage your devices', textAlign: TextAlign.center, style: TextStyle(color: tk(context).muted)),
              const SizedBox(height: 28),
              TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                  validator: (v) => (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? 'Enter a valid email address' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _pass, obscureText: _hide,
                  decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(tooltip: _hide ? 'Show password' : 'Hide password',
                          icon: Icon(_hide ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _hide = !_hide))),
                  validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Row(children: [Icon(Icons.error, color: tk(context).error, size: 18), const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: tk(context).error)))]),
              ],
              const SizedBox(height: 22),
              FilledButton(onPressed: _busy ? null : _submit,
                  child: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sign in')),
            ]))),
        ))),
      );
}
