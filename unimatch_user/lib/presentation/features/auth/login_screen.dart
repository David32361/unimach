import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_user/core/validators/auth_validators.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_feedback.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_scaffold.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/presentation/widgets/privacy_policy_link.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .signIn(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    listenForAuthErrors(context, ref);
    return AuthScaffold(
      title: 'Inicia sesion',
      subtitle: 'Conecta con personas que comparten tus intereses.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
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
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => auth.isLoading ? null : _submit(),
              decoration: InputDecoration(
                labelText: 'Contrasena',
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
              validator: AuthValidators.loginPassword,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () => context.push('/forgot-password'),
                child: const Text('Olvide mi contrasena'),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: auth.isLoading ? null : _submit,
              icon: auth.isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: const Text('Iniciar sesion'),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: auth.isLoading
                  ? null
                  : ref.read(authControllerProvider.notifier).signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
              label: const Text('Continuar con Google'),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('¿Aun no tienes cuenta?'),
                TextButton(
                  onPressed: auth.isLoading
                      ? null
                      : () => context.push('/register'),
                  child: const Text('Registrate'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Center(child: PrivacyPolicyLink()),
          ],
        ),
      ),
    );
  }
}
