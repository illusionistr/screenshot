import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/shared/widgets/responsive_layout.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for successful authentication to navigate
    ref.listen(authStateStreamProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null && context.mounted) {
            context.go('/dashboard');
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    });

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
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        return AuthForm(
                          onSubmit: ({required String email, required String password, String? name}) async {
                            try {
                              await ref.read(authNotifierProvider.notifier).signIn(email, password);
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString())),
                                );
                              }
                            }
                          },
                          submitLabel: 'Sign in',
                          isLoading: false,
                        );
                      },
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


