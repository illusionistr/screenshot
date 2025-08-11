import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/shared/widgets/responsive_layout.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
                    Text('Create your account', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (auth.error != null)
                      Text(auth.error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    AuthForm(
                      showName: true,
                      onSubmit: ({required String email, required String password, String? name}) async {
                        final authProvider = context.read<AuthProvider>();
                        await authProvider.signUp(email, password, displayName: name);
                        if (!context.mounted) return;
                        if (authProvider.isAuthenticated) {
                          context.go('/dashboard');
                        }
                      },
                      submitLabel: 'Create account',
                      isLoading: auth.isLoading,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Already have an account? Sign in'),
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


