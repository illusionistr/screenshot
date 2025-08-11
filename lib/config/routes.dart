import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/auth_wrapper.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/projects/screens/create_project_screen.dart';
import '../features/projects/screens/dashboard_screen.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthWrapper(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/projects/create',
        builder: (context, state) => const CreateProjectScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!isLoggedIn && state.matchedLocation.startsWith('/dashboard')) {
        return '/login';
      }
      if (!isLoggedIn && state.matchedLocation.startsWith('/projects')) {
        return '/login';
      }
      if (isLoggedIn && loggingIn) {
        return '/dashboard';
      }
      return null;
    },
  );
}


