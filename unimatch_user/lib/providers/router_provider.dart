import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimatch_admin/presentation/features/admin/admin_shell_screen.dart';
import 'package:unimatch_user/models/interest_catalog.dart';
import 'package:unimatch_user/presentation/features/auth/account_unavailable_screen.dart';
import 'package:unimatch_user/presentation/features/auth/forgot_password_screen.dart';
import 'package:unimatch_user/presentation/features/auth/login_screen.dart';
import 'package:unimatch_user/presentation/features/auth/register_screen.dart';
import 'package:unimatch_user/presentation/features/auth/verify_email_screen.dart';
import 'package:unimatch_user/presentation/features/home/authenticated_home_screen.dart';
import 'package:unimatch_user/presentation/features/messages/chat_screen.dart';
import 'package:unimatch_user/presentation/features/profile/interest_selection_screen.dart';
import 'package:unimatch_user/presentation/features/profile/profile_edit_screen.dart';
import 'package:unimatch_user/presentation/features/profile/profile_setup_screen.dart';
import 'package:unimatch_user/providers/auth_providers.dart';
import 'package:unimatch_user/providers/profile_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier(ref);
  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/email-verified',
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile/setup',
        builder: (_, _) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/interests',
        builder: (_, _) => const InterestSelectionScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, _) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/account-unavailable',
        builder: (_, _) => const AccountUnavailableScreen(),
      ),
      GoRoute(path: '/admin', builder: (_, _) => const AdminShellScreen()),
      GoRoute(
        path: '/home',
        builder: (_, _) => const AuthenticatedHomeScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId/:otherUserId',
        builder: (_, state) => ChatScreen(
          conversationId: state.pathParameters['conversationId']!,
          otherUserId: state.pathParameters['otherUserId']!,
        ),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final adminAccess = ref.read(adminAccessProvider);
      final profileState = ref.read(currentProfileProvider);
      if (authState.isLoading) return null;
      final signedIn = authState.value != null;
      final public =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      if (!signedIn && !public) return '/login';
      if (!signedIn) return null;
      final verifying =
          state.matchedLocation == '/verify-email' ||
          state.matchedLocation == '/email-verified';
      if (!authState.value!.emailVerified) {
        return verifying ? null : '/verify-email';
      }
      if (verifying) return '/home';
      if (adminAccess.isLoading) return null;
      if (adminAccess.value == true) {
        return state.matchedLocation == '/admin' ? null : '/admin';
      }
      if (state.matchedLocation == '/admin') return '/home';
      if (profileState.isLoading) return null;
      final accountStatus = profileState.value?.accountStatus;
      if (accountStatus != null && accountStatus != 'active') {
        return state.matchedLocation == '/account-unavailable'
            ? null
            : '/account-unavailable';
      }
      final hasProfile = profileState.value?.profileComplete == true;
      if (!hasProfile && state.matchedLocation != '/profile/setup') {
        return '/profile/setup';
      }
      final profile = profileState.value;
      final hasInterests =
          profile != null &&
          validateInterestSelection(profile.interests, profile.animeGenres) ==
              null;
      if (hasProfile &&
          !hasInterests &&
          state.matchedLocation != '/interests') {
        return '/interests';
      }
      if (hasProfile &&
          hasInterests &&
          (public ||
              state.matchedLocation == '/account-unavailable' ||
              state.matchedLocation == '/profile/setup' ||
              state.matchedLocation == '/interests')) {
        return '/home';
      }
      return null;
    },
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateChangesProvider, (_, _) => notifyListeners());
    ref.listen(adminAccessProvider, (_, _) => notifyListeners());
    ref.listen(currentProfileProvider, (_, _) => notifyListeners());
  }
}
