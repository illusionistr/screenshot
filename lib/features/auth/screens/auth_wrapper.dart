import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/loading_widget.dart';
import '../../projects/screens/dashboard_screen.dart';
import 'login_screen.dart';
import '../providers/auth_provider.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateStreamProvider);
    
    return authState.when(
      data: (user) => user != null ? const DashboardScreen() : const LoginScreen(),
      loading: () => const LoadingWidget(),
      error: (error, stack) => const LoginScreen(),
    );
  }
}


