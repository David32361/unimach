import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_admin/presentation/widgets/admin_page.dart';
import 'package:unimatch_admin/providers/admin_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider).value ?? const [];
    final reports = ref.watch(adminReportsProvider).value ?? const [];
    final matches = ref.watch(matchCountProvider).value ?? 0;
    final conversations = ref.watch(conversationCountProvider).value ?? 0;
    final usage =
        ref.watch(usageSecondsProvider).value ?? const <String, int>{};
    final active = users.where((user) => user.accountStatus == 'active').length;
    final banned = users.where((user) => user.accountStatus == 'banned').length;
    final pending = reports
        .where((report) => report.status == 'pending')
        .length;
    final now = DateTime.now();
    final newUsers = users
        .where(
          (user) =>
              user.createdAt != null &&
              now.difference(user.createdAt!).inDays < 7,
        )
        .length;

    final mostActive = users.toList()
      ..sort((a, b) => (usage[b.uid] ?? 0).compareTo(usage[a.uid] ?? 0));

    return AdminPage(
      title: 'Dashboard',
      subtitle: 'Resumen general de la comunidad.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1100
              ? 4
              : constraints.maxWidth >= 600
              ? 2
              : 1;
          final width = (constraints.maxWidth - ((columns - 1) * 16)) / columns;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _Metric(
                    width: width,
                    icon: Icons.people,
                    label: 'Usuarios registrados',
                    value: users.length,
                    color: const Color(0xFF2F6B85),
                  ),
                  _Metric(
                    width: width,
                    icon: Icons.person_add_alt_1,
                    label: 'Nuevos esta semana',
                    value: newUsers,
                    color: const Color(0xFF4E8A67),
                  ),
                  _Metric(
                    width: width,
                    icon: Icons.check_circle,
                    label: 'Usuarios activos',
                    value: active,
                    color: const Color(0xFF317C5D),
                  ),
                  _Metric(
                    width: width,
                    icon: Icons.block,
                    label: 'Usuarios baneados',
                    value: banned,
                    color: const Color(0xFFA64652),
                  ),
                  _Metric(
                    width: width,
                    icon: Icons.favorite,
                    label: 'Matches',
                    value: matches,
                    color: const Color(0xFFE26177),
                  ),
                  _Metric(
                    width: width,
                    icon: Icons.forum,
                    label: 'Conversaciones',
                    value: conversations,
                    color: const Color(0xFF6B5D92),
                  ),
                  _Metric(
                    width: width,
                    icon: Icons.flag,
                    label: 'Reportes pendientes',
                    value: pending,
                    color: const Color(0xFFD07B35),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Distribucion de cuentas',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _DistributionRow(
                label: 'Activas',
                value: active,
                total: users.length,
                color: const Color(0xFF317C5D),
              ),
              _DistributionRow(
                label: 'Baneadas',
                value: banned,
                total: users.length,
                color: const Color(0xFFA64652),
              ),
              const SizedBox(height: 28),
              Text(
                'Tiempo de uso registrado',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (mostActive.isEmpty)
                const Text('Aun no hay sesiones registradas.')
              else
                ...mostActive
                    .take(5)
                    .map(
                      (user) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: Text(user.name),
                        trailing: Text(_durationLabel(usage[user.uid] ?? 0)),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : value / total,
              color: color,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 36, child: Text('$value')),
        ],
      ),
    );
  }
}

String _durationLabel(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  return '$hours h ${minutes.toString().padLeft(2, '0')} min';
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final double width;
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: color),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(label),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
