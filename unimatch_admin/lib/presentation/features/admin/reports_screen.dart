import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_admin/models/admin_report.dart';
import 'package:unimatch_admin/models/admin_user.dart';
import 'package:unimatch_admin/presentation/widgets/admin_page.dart';
import 'package:unimatch_admin/providers/admin_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(adminReportsProvider);
    final users = {
      for (final user in ref.watch(adminUsersProvider).value ?? <AdminUser>[])
        user.uid: user,
    };
    return AdminPage(
      title: 'Reportes',
      subtitle: 'Revision y seguimiento de reportes enviados por usuarios.',
      child: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('No fue posible cargar los reportes: $error'),
        data: (reports) {
          if (reports.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Text('No hay reportes registrados.'),
            );
          }
          return Column(
            children: reports
                .map(
                  (report) => _ReportTile(
                    report: report,
                    reporter:
                        users[report.reporterId]?.name ?? report.reporterId,
                    reported:
                        users[report.reportedUserId]?.name ??
                        report.reportedUserId,
                    onStatus: (status) =>
                        _updateStatus(context, ref, report, status),
                    onAccountStatus: users[report.reportedUserId] == null
                        ? null
                        : (status) => _changeAccountStatus(
                            context,
                            ref,
                            users[report.reportedUserId]!,
                            report,
                            status,
                          ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    AdminReport report,
    String status,
  ) async {
    try {
      final adminId = ref.read(firebaseAuthProvider).currentUser!.uid;
      await ref
          .read(adminRepositoryProvider)
          .updateReportStatus(adminId: adminId, report: report, status: status);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No fue posible actualizar: $error')),
        );
      }
    }
  }

  Future<void> _changeAccountStatus(
    BuildContext context,
    WidgetRef ref,
    AdminUser user,
    AdminReport report,
    String status,
  ) async {
    final reasonController = TextEditingController(text: report.reason);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == 'banned'
              ? 'Banear a ${user.name}'
              : 'Suspender a ${user.name}',
        ),
        content: TextField(
          controller: reasonController,
          maxLength: 300,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Motivo administrativo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, reasonController.text.trim().isNotEmpty),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (confirmed != true || reason.isEmpty) return;

    try {
      final adminId = ref.read(firebaseAuthProvider).currentUser!.uid;
      await ref
          .read(adminRepositoryProvider)
          .updateAccountStatus(
            adminId: adminId,
            user: user,
            status: status,
            reason: reason,
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No fue posible actualizar la cuenta: $error'),
          ),
        );
      }
    }
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.report,
    required this.reporter,
    required this.reported,
    required this.onStatus,
    required this.onAccountStatus,
  });

  final AdminReport report;
  final String reporter;
  final String reported;
  final ValueChanged<String> onStatus;
  final ValueChanged<String>? onAccountStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    report.reason,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(label: Text(report.status)),
              ],
            ),
            const SizedBox(height: 10),
            Text('Reportado: $reported'),
            Text('Reportado por: $reporter'),
            if (report.createdAt != null)
              Text(
                'Fecha: ${report.createdAt!.day.toString().padLeft(2, '0')}/${report.createdAt!.month.toString().padLeft(2, '0')}/${report.createdAt!.year}',
              ),
            if (report.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(report.description),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: report.status == 'reviewing'
                      ? null
                      : () => onStatus('reviewing'),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Revisar'),
                ),
                FilledButton.tonalIcon(
                  onPressed: report.status == 'resolved'
                      ? null
                      : () => onStatus('resolved'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Resolver'),
                ),
                TextButton.icon(
                  onPressed: report.status == 'rejected'
                      ? null
                      : () => onStatus('rejected'),
                  icon: const Icon(Icons.close),
                  label: const Text('Rechazar'),
                ),
                OutlinedButton.icon(
                  onPressed: onAccountStatus == null
                      ? null
                      : () => onAccountStatus!('suspended'),
                  icon: const Icon(Icons.pause_circle_outline),
                  label: const Text('Suspender cuenta'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onAccountStatus == null
                      ? null
                      : () => onAccountStatus!('banned'),
                  icon: const Icon(Icons.block),
                  label: const Text('Banear cuenta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
