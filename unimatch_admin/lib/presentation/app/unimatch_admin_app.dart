import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/admin_providers.dart';
import '../features/admin/admin_shell_screen.dart';
import '../features/auth/admin_login_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);
  final access = ref.watch(adminAccessProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (auth.isLoading || (auth.value != null && access.isLoading)) {
        return state.matchedLocation == '/loading' ? null : '/loading';
      }
      if (auth.value == null) {
        return state.matchedLocation == '/login' ? null : '/login';
      }
      if (access.value != true) {
        ref.read(firebaseAuthProvider).signOut();
        return state.matchedLocation == '/login' ? null : '/login';
      }
      return state.matchedLocation == '/admin' ? null : '/admin';
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminShellScreen(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    ],
  );
});

class UniMatchAdminApp extends ConsumerWidget {
  const UniMatchAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'UniMatch Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F6B85),
          brightness: Brightness.light,
          surface: const Color(0xFFF7F8F6),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F6),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFDCE2E5)),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
