import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/core/validators/auth_validators.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_feedback.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_scaffold.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:url_launcher/link.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

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
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    listenForAuthErrors(context, ref);
    return AuthScaffold(
      title: 'Recupera tu acceso',
      subtitle: 'Restablece tu contraseña por correo o entra con Google.',
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
              onChanged: (_) {
                if (_sent) setState(() => _sent = false);
              },
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 12),
            Text(
              'Si esta dirección tiene una cuenta con contraseña, '
              'recibirás un enlace. Necesitas acceso a ese correo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_sent) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.mark_email_read_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Solicitud recibida. Revisa tu bandeja y spam. '
                      'Si no controlas ese correo, no podrás restablecer '
                      'la contraseña desde UniMatch.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: auth.isLoading ? null : _submit,
              icon: auth.isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_sent ? 'Reenviar enlace' : 'Enviar enlace'),
            ),
            const SizedBox(height: 20),
            Text(
              'Si creaste tu cuenta con Google, inicia sesión con Google. '
              'Si olvidaste tu clave de Google, recupérala con Google.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: auth.isLoading
                  ? null
                  : ref.read(authControllerProvider.notifier).signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
              label: const Text('Continuar con Google'),
            ),
            Link(
              uri: Uri.parse('https://accounts.google.com/signin/recovery'),
              target: LinkTarget.blank,
              builder: (context, followLink) => TextButton.icon(
                onPressed: auth.isLoading ? null : followLink,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Recuperar cuenta de Google'),
              ),
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
