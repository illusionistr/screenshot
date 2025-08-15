import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/auth_wrapper.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/editor/screens/editor_screen.dart';
import '../features/projects/screens/create_project_screen.dart';
import '../features/projects/screens/dashboard_screen.dart';
import '../features/projects/screens/upload_screenshots_screen.dart';

part 'routes.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
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
      GoRoute(
        path: '/projects/:projectId/upload',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return UploadScreenshotsScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: '/projects/:projectId/editor',
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return EditorScreen(projectId: projectId);
        },
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateStreamProvider);
      
      print('Router redirect - location: ${state.matchedLocation}');
      
      // Handle different auth states
      return authState.when(
        data: (user) {
          final isLoggedIn = user != null;
          final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
          
          print('Router redirect - data: isLoggedIn=$isLoggedIn, loggingIn=$loggingIn');
          
          // If not logged in and trying to access protected routes
          if (!isLoggedIn && (state.matchedLocation.startsWith('/dashboard') || 
                            state.matchedLocation.startsWith('/projects'))) {
            print('Router redirect - redirecting to login (not logged in)');
            return '/login';
          }
          
          // If logged in and on login/signup pages, go to dashboard
          if (isLoggedIn && loggingIn) {
            print('Router redirect - redirecting to dashboard (logged in but on login page)');
            return '/dashboard';
          }
          
          print('Router redirect - no redirect needed');
          return null;
        },
        loading: () {
          print('Router redirect - auth loading, no redirect');
          // During loading, don't redirect protected routes to avoid navigation loops
          return null;
        },
        error: (_, __) {
          print('Router redirect - auth error, redirecting to login');
          // On auth error, redirect to login
          final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
          if (!loggingIn) {
            return '/login';
          }
          return null;
        },
      );
    },
  );
}


