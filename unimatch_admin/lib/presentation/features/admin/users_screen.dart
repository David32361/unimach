import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_admin/models/admin_user.dart';
import 'package:unimatch_admin/presentation/widgets/admin_page.dart';
import 'package:unimatch_admin/presentation/widgets/avatar_sprite.dart';
import 'package:unimatch_admin/providers/admin_providers.dart';
import 'package:unimatch_admin/core/support.dart';
import 'package:unimatch_admin/presentation/widgets/support_contact.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _query = '';
  String _status = 'all';
  String _gender = '';
  String _university = '';
  String _career = '';
  int _minimumAge = 18;
  int _maximumAge = 99;
  int _registrationDays = 0;
  int _activityDays = 0;
  String _order = 'recent';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);
    return AdminPage(
      title: 'Usuarios',
      subtitle: 'Consulta perfiles y administra el estado de las cuentas.',
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 360,
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar por nombre, correo o universidad',
                  ),
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todos')),
                    DropdownMenuItem(value: 'active', child: Text('Activos')),
                    DropdownMenuItem(
                      value: 'suspended',
                      child: Text('Suspendidos'),
                    ),
                    DropdownMenuItem(value: 'banned', child: Text('Baneados')),
                    DropdownMenuItem(
                      value: 'deleted',
                      child: Text('Eliminados'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _status = value ?? 'all'),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Genero',
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  onChanged: (value) =>
                      setState(() => _gender = value.trim().toLowerCase()),
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Universidad',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  onChanged: (value) =>
                      setState(() => _university = value.trim().toLowerCase()),
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Carrera',
                    prefixIcon: Icon(Icons.menu_book_outlined),
                  ),
                  onChanged: (value) =>
                      setState(() => _career = value.trim().toLowerCase()),
                ),
              ),
              SizedBox(
                width: 125,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Edad minima'),
                  onChanged: (value) =>
                      setState(() => _minimumAge = int.tryParse(value) ?? 18),
                ),
              ),
              SizedBox(
                width: 125,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Edad maxima'),
                  onChanged: (value) =>
                      setState(() => _maximumAge = int.tryParse(value) ?? 99),
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _registrationDays,
                  decoration: const InputDecoration(labelText: 'Registro'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Cualquier fecha')),
                    DropdownMenuItem(value: 7, child: Text('Ultimos 7 dias')),
                    DropdownMenuItem(value: 30, child: Text('Ultimos 30 dias')),
                    DropdownMenuItem(value: 365, child: Text('Ultimo ano')),
                  ],
                  onChanged: (value) =>
                      setState(() => _registrationDays = value ?? 0),
                ),
              ),
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _activityDays,
                  decoration: const InputDecoration(labelText: 'Actividad'),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Cualquier fecha')),
                    DropdownMenuItem(
                      value: 7,
                      child: Text('Activos en 7 dias'),
                    ),
                    DropdownMenuItem(
                      value: 30,
                      child: Text('Activos en 30 dias'),
                    ),
                    DropdownMenuItem(
                      value: 365,
                      child: Text('Activos este ano'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _activityDays = value ?? 0),
                ),
              ),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _order,
                  decoration: const InputDecoration(labelText: 'Orden'),
                  items: const [
                    DropdownMenuItem(
                      value: 'recent',
                      child: Text('Mas recientes'),
                    ),
                    DropdownMenuItem(
                      value: 'oldest',
                      child: Text('Mas antiguos'),
                    ),
                    DropdownMenuItem(
                      value: 'activity',
                      child: Text('Mayor actividad'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _order = value ?? 'recent'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorText(error: error),
            data: (users) {
              final filtered = users.where((user) {
                final matchesQuery =
                    _query.isEmpty ||
                    '${user.name} ${user.email} ${user.university} ${user.career}'
                        .toLowerCase()
                        .contains(_query);
                final matchesRegistration =
                    _registrationDays == 0 ||
                    (user.createdAt != null &&
                        DateTime.now().difference(user.createdAt!).inDays <=
                            _registrationDays);
                final matchesActivity =
                    _activityDays == 0 ||
                    (user.lastActivity != null &&
                        DateTime.now().difference(user.lastActivity!).inDays <=
                            _activityDays);
                return matchesQuery &&
                    (_status == 'all' || user.accountStatus == _status) &&
                    (_gender.isEmpty ||
                        user.gender.toLowerCase().contains(_gender)) &&
                    (_university.isEmpty ||
                        user.university.toLowerCase().contains(_university)) &&
                    (_career.isEmpty ||
                        user.career.toLowerCase().contains(_career)) &&
                    user.age >= _minimumAge &&
                    user.age <= _maximumAge &&
                    matchesRegistration &&
                    matchesActivity;
              }).toList();
              filtered.sort((a, b) {
                final first = _order == 'activity'
                    ? a.lastActivity
                    : a.createdAt;
                final second = _order == 'activity'
                    ? b.lastActivity
                    : b.createdAt;
                final result = (second ?? DateTime(1970)).compareTo(
                  first ?? DateTime(1970),
                );
                return _order == 'oldest' ? -result : result;
              });
              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No hay usuarios que coincidan.'),
                );
              }
              return Column(
                children: filtered
                    .map(
                      (user) => _UserTile(
                        user: user,
                        onAction: () => _showStatusDialog(user),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showStatusDialog(AdminUser user) async {
    final reasonController = TextEditingController();
    var selected = user.accountStatus;
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Administrar a ${user.name}'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selected,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo estado',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Activo')),
                      DropdownMenuItem(
                        value: 'suspended',
                        child: Text('Suspendido'),
                      ),
                      DropdownMenuItem(value: 'banned', child: Text('Baneado')),
                      DropdownMenuItem(
                        value: 'deleted',
                        enabled: accountManagementBackendEnabled,
                        child: Text('Eliminar definitivamente'),
                      ),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => selected = value ?? selected),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    maxLength: 300,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Motivo'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'El motivo será visible para la persona afectada. No incluyas datos de terceros ni contraseñas.',
                  ),
                  if (!accountManagementBackendEnabled)
                    const Text(
                      'La eliminación definitiva está pendiente de activar el servicio de cuentas.',
                    ),
                  const SizedBox(height: 12),
                  const SupportContact(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.length >= 5 && selected != user.accountStatus) {
                  Navigator.pop(context, (selected, reason));
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
    reasonController.dispose();
    if (result == null || !mounted) return;
    if (result.$1 == 'deleted') {
      final confirmed = await _confirmPermanentDeletion(user);
      if (!confirmed || !mounted) return;
    }
    try {
      final adminId = ref.read(firebaseAuthProvider).currentUser!.uid;
      await ref
          .read(adminRepositoryProvider)
          .updateAccountStatus(
            adminId: adminId,
            user: user,
            status: result.$1,
            reason: result.$2,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Estado actualizado.')));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ?? 'No fue posible actualizar la cuenta.',
            ),
          ),
        );
      }
    }
  }

  Future<bool> _confirmPermanentDeletion(AdminUser user) async {
    final confirmation = TextEditingController();
    final password = TextEditingController();
    final form = GlobalKey<FormState>();
    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    final needsPassword =
        currentUser?.providerData.any(
          (provider) => provider.providerId == 'password',
        ) ==
        true;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta definitivamente'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Se borrará el acceso, perfil, sesiones e interacciones de ${user.name}, incluidas sus conversaciones compartidas. Los datos borrados no pueden recuperarse.',
                ),
                TextFormField(
                  controller: confirmation,
                  decoration: const InputDecoration(
                    labelText: 'Escribe ELIMINAR',
                  ),
                  validator: (value) => value?.trim() == 'ELIMINAR'
                      ? null
                      : 'Escribe ELIMINAR para confirmar.',
                ),
                if (needsPassword)
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Tu contraseña de administrador',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Confirma tu contraseña.'
                        : null,
                  ),
                if (!needsPassword)
                  const Text(
                    'Para confirmar debes haber iniciado sesión en los últimos cinco minutos.',
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );
    try {
      if (accepted != true) return false;
      if (needsPassword && currentUser?.email != null) {
        await currentUser!.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: currentUser.email!,
            password: password.text,
          ),
        );
        await currentUser.getIdToken(true);
      }
      return true;
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ?? 'No se pudo confirmar tu identidad.',
            ),
          ),
        );
      }
      return false;
    } finally {
      confirmation.dispose();
      password.dispose();
    }
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onAction});
  final AdminUser user;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AvatarSprite(avatarId: user.avatarId),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(user.email),
                Text(
                  '${user.age} anos · ${user.gender} · ${user.university} · ${user.career}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Registro: ${_dateLabel(user.createdAt)} · Ultima actividad: ${_dateLabel(user.lastActivity)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Chip(label: Text(_statusLabel(user.accountStatus))),
          IconButton(
            tooltip: 'Administrar cuenta',
            onPressed: onAction,
            icon: const Icon(Icons.manage_accounts_outlined),
          ),
        ],
      ),
    ),
  );
}

String _statusLabel(String status) => switch (status) {
  'suspended' => 'Suspendido',
  'banned' => 'Baneado',
  'deleted' => 'Eliminado',
  _ => 'Activo',
};

String _dateLabel(DateTime? date) {
  if (date == null) return 'Sin datos';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.error});
  final Object error;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Text('No fue posible cargar los datos: $error'),
  );
}
