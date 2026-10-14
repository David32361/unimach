import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/app/unimatch_user_app.dart';
import 'services/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseStatus = await FirebaseBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: [
        firebaseStartupStateProvider.overrideWithValue(firebaseStatus),
      ],
      child: const UniMatchUserApp(),
    ),
  );
}
