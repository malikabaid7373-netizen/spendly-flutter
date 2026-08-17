import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../view_models/finance_view_model.dart';
import 'auth_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'abaid@spendly.app');
  final _password = TextEditingController(text: 'password123');
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await context.read<AppSettingsViewModel>().login(email: _email.text);
    if (mounted) context.go('/home');
  }

  Future<void> _demo() async {
    setState(() => _busy = true);
    await context.read<AppSettingsViewModel>().enterDemo();
    if (!mounted) return;
    await context.read<FinanceViewModel>().seedDemoData();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(children: [
      Text(context.t('welcomeBack'), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, height: 1.05)),
      const SizedBox(height: 12),
      Text(context.t('loginSubtitle'), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor, height: 1.5)),
      const SizedBox(height: 32),
      Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: context.t('email'), prefixIcon: const Icon(Icons.alternate_email_rounded)),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return context.t('requiredField');
              if (!value.contains('@')) return context.t('invalidEmail');
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: context.t('password'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
            ),
            validator: (value) => (value?.length ?? 0) < 8 ? context.t('passwordLength') : null,
          ),
        ]),
      ),
      const SizedBox(height: 22),
      SizedBox(height: 54, child: FilledButton(onPressed: _busy ? null : _login, child: _busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Text(context.t('login'), style: const TextStyle(fontWeight: FontWeight.w900)))),
      const SizedBox(height: 12),
      SizedBox(height: 54, child: OutlinedButton.icon(onPressed: _busy ? null : _demo, icon: const Icon(Icons.auto_awesome_rounded, color: AppPalette.emerald), label: Text(context.t('exploreDemo'), style: const TextStyle(fontWeight: FontWeight.w800)))),
      const SizedBox(height: 12),
      Text(context.t('demoHint'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
      const SizedBox(height: 28),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(context.t('noAccount')), TextButton(onPressed: () => context.go('/register'), child: Text(context.t('createAccount')))]),
    ]);
  }
}
