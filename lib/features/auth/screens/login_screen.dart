import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/shared/widgets/responsive_layout.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: ResponsiveLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(AppConstants.appName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Sign in', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (auth.error != null)
                      Text(auth.error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    AuthForm(
                      onSubmit: ({required String email, required String password, String? name}) async {
                        final authProvider = context.read<AuthProvider>();
                        await authProvider.signIn(email, password);
                        if (!context.mounted) return;
                        if (authProvider.isAuthenticated) {
                          context.go('/dashboard');
                        }
                      },
                      submitLabel: 'Sign in',
                      isLoading: auth.isLoading,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text("Don't have an account? Sign up"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


