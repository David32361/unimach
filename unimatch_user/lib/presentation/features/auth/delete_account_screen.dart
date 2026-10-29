import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_admin/core/support.dart';
import 'package:unimatch_admin/presentation/widgets/support_contact.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/presentation/features/auth/widgets/auth_feedback.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});
  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmation = TextEditingController();
  final _password = TextEditingController();
  bool _withGoogle = false;
  @override
  void dispose() {
    _confirmation.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_confirmation.text.trim() != 'ELIMINAR') return;
    final messenger = ScaffoldMessenger.of(context);
    final success = await ref
        .read(authControllerProvider.notifier)
        .deleteOwnAccount(password: _password.text, withGoogle: _withGoogle);
    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Eliminación solicitada. El acceso está desactivado y el borrado se completará en el servidor.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final operation = ref.watch(authControllerProvider);
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final hasGoogle =
        user?.providerData.any(
          (provider) => provider.providerId == 'google.com',
        ) ==
        true;
    final hasPassword =
        user?.providerData.any(
          (provider) => provider.providerId == 'password',
        ) ==
        true;
    listenForAuthErrors(context, ref);
    return Scaffold(
      appBar: AppBar(title: const Text('Eliminar mi cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.person_remove_outlined, size: 56),
          const SizedBox(height: 20),
          const Text(
            'La eliminación definitiva no se puede deshacer.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Se borrarán tu cuenta de acceso, perfil, dispositivos, sesiones, intereses, matches, bloqueos y reportes asociados. Tus conversaciones y sus mensajes se eliminarán también para la otra persona. Los registros mínimos de la operación se conservan temporalmente para gestionar incidencias.',
          ),
          const SizedBox(height: 20),
          if (!accountManagementBackendEnabled) ...[
            const Text(
              'La eliminación automática aún no está disponible en esta versión. Puedes solicitar la eliminación escribiendo al siguiente correo desde la dirección de tu cuenta. Indica «Solicitud de eliminación de cuenta» y no compartas tu contraseña.',
            ),
            const SizedBox(height: 20),
          ] else ...[
            if (hasGoogle && hasPassword)
              SwitchListTile(
                title: const Text('Confirmar con Google'),
                value: _withGoogle,
                onChanged: operation.isLoading
                    ? null
                    : (value) => setState(() => _withGoogle = value),
              ),
            if (hasPassword && !_withGoogle)
              TextField(
                controller: _password,
                obscureText: true,
                enabled: !operation.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmation,
              enabled: !operation.isLoading,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Escribe ELIMINAR para confirmar',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed:
                  operation.isLoading || _confirmation.text.trim() != 'ELIMINAR'
                  ? null
                  : () {
                      if (!hasPassword && hasGoogle) _withGoogle = true;
                      _delete();
                    },
              icon: const Icon(Icons.delete_forever),
              label: const Text('Eliminar definitivamente'),
            ),
            const SizedBox(height: 20),
          ],
          const SupportContact(),
        ],
      ),
    );
  }
}
