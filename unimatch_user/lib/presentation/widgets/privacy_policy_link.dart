import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyLink extends StatelessWidget {
  const PrivacyPolicyLink({super.key});

  static final Uri _uri = Uri.parse(
    'https://github.com/David32361/app_unimach/blob/main/PRIVACIDAD.md',
  );

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        final opened = await launchUrl(
          _uri,
          mode: LaunchMode.externalApplication,
        );
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir la politica de privacidad.'),
            ),
          );
        }
      },
      icon: const Icon(Icons.privacy_tip_outlined),
      label: const Text('Politica de privacidad'),
    );
  }
}
