import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';
import 'package:unimatch_user/providers/router_provider.dart';

class UniMatchUserApp extends ConsumerStatefulWidget {
  const UniMatchUserApp({super.key});

  @override
  ConsumerState<UniMatchUserApp> createState() => _UniMatchUserAppState();
}

class _UniMatchUserAppState extends ConsumerState<UniMatchUserApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final service = ref.read(usageSessionServiceProvider);
    if (state == AppLifecycleState.resumed) {
      final user = ref.read(firebaseAuthProvider).currentUser;
      final profile = ref.read(currentProfileProvider).value;
      if (user != null && profile?.accountStatus == 'active') {
        unawaited(service.startSession(user.uid).catchError((_) {}));
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(service.endSession().catchError((_) {}));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value;
    final profile = ref.watch(currentProfileProvider).value;
    if (user != null && profile?.accountStatus == 'active') {
      ref.watch(notificationRegistrationProvider);
      unawaited(
        ref
            .read(usageSessionServiceProvider)
            .startSession(user.uid)
            .catchError((_) {}),
      );
    }
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'UniMatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB83A55),
          brightness: Brightness.light,
          surface: const Color(0xFFF8F9F8),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9F8),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
