import 'package:flutter/material.dart';
import 'package:unimatch_admin/core/support.dart';

class SupportContact extends StatelessWidget {
  const SupportContact({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Quejas, sugerencias y apelaciones',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 6),
      const SelectableText(supportEmail, textAlign: TextAlign.center),
      const SizedBox(height: 6),
      Text(
        'Escribe desde el correo de tu cuenta. No envíes contraseñas.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}
