import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';
import 'package:unimatch_user/providers/account_notice_provider.dart';
import 'package:unimatch_admin/presentation/widgets/support_contact.dart';
import 'package:go_router/go_router.dart';

class AccountUnavailableScreen extends ConsumerWidget {
  const AccountUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(accountNoticeProvider).value;
    final status =
        ref.watch(currentProfileProvider).value?.accountStatus ??
        notice?['status'] as String?;
    final reason = notice?['reason'] as String?;
    final (title, message, icon) = switch (status) {
      'suspended' => (
        'Cuenta suspendida',
        'Tu cuenta está suspendida temporalmente. Contacta al administrador si necesitas ayuda.',
        Icons.pause_circle_outline,
      ),
      'banned' => (
        'Cuenta baneada',
        'Tu cuenta no puede utilizar UniMatch.',
        Icons.block,
      ),
      'deleted' => (
        'Cuenta eliminada',
        'Esta cuenta ya no tiene acceso a UniMatch.',
        Icons.person_off_outlined,
      ),
      _ => (
        'Cuenta no disponible',
        'No fue posible habilitar tu cuenta en este momento.',
        Icons.error_outline,
      ),
    };

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 72,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                if (reason != null && reason.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Motivo: $reason', textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Puedes solicitar una revisión desde el correo asociado a tu cuenta. Los datos borrados definitivamente no pueden recuperarse.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const SupportContact(),
                TextButton(
                  onPressed: () => context.push('/account/delete'),
                  child: const Text('Solicitar eliminación de mis datos'),
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
