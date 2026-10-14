import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/core/validators/auth_validators.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_feedback.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_scaffold.dart';
import 'package:unimatch_user/providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text);
    if (!mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Revisa tu correo para restablecerla.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    listenForAuthErrors(context, ref);
    return AuthScaffold(
      title: 'Recupera tu acceso',
      subtitle: 'Te enviaremos un enlace para crear una nueva contrasena.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Correo',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: auth.isLoading ? null : _submit,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Enviar enlace'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: auth.isLoading ? null : () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
