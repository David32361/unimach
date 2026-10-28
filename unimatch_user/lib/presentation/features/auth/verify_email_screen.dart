import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_feedback.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_scaffold.dart';
import 'package:unimatch_user/providers/auth_providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_checkOnOpen());
    });
  }

  Future<void> _checkOnOpen() async {
    // Opening an App Link is not proof of ownership. Ask Firebase every time.
    try {
      final verified = await ref
          .read(authRepositoryProvider)
          .refreshEmailVerification();
      if (!verified && mounted) await _send();
    } catch (_) {
      // Leave the explicit retry controls available when offline.
    }
  }

  Future<void> _send() async {
    final sent = await ref
        .read(authControllerProvider.notifier)
        .sendEmailVerification();
    if (!mounted || !sent) return;
    setState(() {
      _sent = true;
      _seconds = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _seconds--);
      if (_seconds <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operation = ref.watch(authControllerProvider);
    final email =
        ref.watch(authStateChangesProvider).value?.email ?? 'tu correo';
    listenForAuthErrors(context, ref);
    return AuthScaffold(
      title: 'Confirma tu correo',
      subtitle:
          'Verifica tu correo para activar tu cuenta y completar tu perfil.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.mark_email_unread_outlined, size: 64),
          const SizedBox(height: 20),
          Text(
            email,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            _sent
                ? 'Enlace enviado. Abre el correo de UniMatch, confirma tu dirección y pulsa Continuar para volver a la app. Revisa también la carpeta de spam.'
                : 'Abre el enlace de verificación que enviaremos a tu correo. Si ya lo confirmaste, compruébalo con el botón de abajo.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: operation.isLoading
                ? null
                : ref
                      .read(authControllerProvider.notifier)
                      .checkEmailVerification,
            icon: operation.isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.verified_outlined),
            label: const Text('Ya confirmé mi correo'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: operation.isLoading || _seconds > 0 ? null : _send,
            icon: const Icon(Icons.forward_to_inbox_outlined),
            label: Text(
              _seconds > 0 ? 'Reenviar en $_seconds s' : 'Enviar otro enlace',
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: operation.isLoading
                ? null
                : ref.read(authControllerProvider.notifier).signOut,
            child: const Text('Usar otra cuenta'),
          ),
        ],
      ),
    );
  }
}
