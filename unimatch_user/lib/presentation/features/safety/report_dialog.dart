import 'package:flutter/material.dart';

const reportReasons = [
  'Spam',
  'Acoso',
  'Perfil falso',
  'Contenido inapropiado',
  'Comportamiento ofensivo',
  'Otro',
];

class ReportDraft {
  const ReportDraft(this.reason, this.description);

  final String reason;
  final String description;
}

Future<ReportDraft?> showReportDialog(BuildContext context) {
  return showDialog<ReportDraft>(
    context: context,
    builder: (context) => const _ReportDialog(),
  );
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _descriptionController = TextEditingController();
  String _reason = reportReasons.first;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reportar usuario'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _reason,
              decoration: const InputDecoration(labelText: 'Motivo'),
              items: reportReasons
                  .map(
                    (reason) =>
                        DropdownMenuItem(value: reason, child: Text(reason)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _reason = value!),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              maxLength: 500,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripcion',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            ReportDraft(_reason, _descriptionController.text),
          ),
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
