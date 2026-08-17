import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_strings.dart';
import '../../view_models/app_settings_view_model.dart';
import 'auth_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await context.read<AppSettingsViewModel>().register(name: _name.text, email: _email.text);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(children: [
      Text(context.t('createYourAccount'), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, height: 1.05)),
      const SizedBox(height: 12),
      Text(context.t('registerSubtitle'), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor, height: 1.5)),
      const SizedBox(height: 30),
      Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(controller: _name, textCapitalization: TextCapitalization.words, decoration: InputDecoration(labelText: context.t('fullName'), prefixIcon: const Icon(Icons.person_outline_rounded)), validator: (value) => value == null || value.trim().isEmpty ? context.t('requiredField') : null),
          const SizedBox(height: 14),
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
            decoration: InputDecoration(labelText: context.t('password'), prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
            validator: (value) => (value?.length ?? 0) < 8 ? context.t('passwordLength') : null,
          ),
          const SizedBox(height: 14),
          TextFormField(controller: _confirm, obscureText: _obscure, decoration: InputDecoration(labelText: context.t('confirmPassword'), prefixIcon: const Icon(Icons.verified_user_outlined)), validator: (value) => value != _password.text ? context.t('passwordMismatch') : null),
        ]),
      ),
      const SizedBox(height: 22),
      SizedBox(height: 54, child: FilledButton(onPressed: _busy ? null : _register, child: _busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Text(context.t('createAccount'), style: const TextStyle(fontWeight: FontWeight.w900)))),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(context.t('alreadyAccount')), TextButton(onPressed: () => context.go('/login'), child: Text(context.t('login')))]),
    ]);
  }
}
