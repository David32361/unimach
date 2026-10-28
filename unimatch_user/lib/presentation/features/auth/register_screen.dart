import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/core/validators/auth_validators.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_feedback.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_scaffold.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/presentation/widgets/privacy_policy_link.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .register(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    listenForAuthErrors(context, ref);
    return AuthScaffold(
      title: 'Crea tu cuenta',
      subtitle: 'Confirma tu correo y después completa tu perfil.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.newUsername],
              decoration: const InputDecoration(
                labelText: 'Correo',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Contrasena',
                helperText:
                    'De 8 a 128 caracteres: mayúscula, minúscula, número y símbolo.',
                helperMaxLines: 3,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Mostrar contrasena'
                      : 'Ocultar contrasena',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmationController,
              obscureText: _obscurePassword,
              onFieldSubmitted: (_) => auth.isLoading ? null : _submit(),
              decoration: const InputDecoration(
                labelText: 'Confirma la contrasena',
                prefixIcon: Icon(Icons.lock_reset_rounded),
              ),
              validator: (value) => AuthValidators.confirmPassword(
                value,
                _passwordController.text,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: auth.isLoading ? null : _submit,
              icon: auth.isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Crear cuenta'),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: auth.isLoading ? null : () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Volver al inicio de sesion'),
            ),
            const Center(child: PrivacyPolicyLink()),
          ],
        ),
      ),
    );
  }
}
