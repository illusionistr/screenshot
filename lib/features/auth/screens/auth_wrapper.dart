import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../projects/screens/dashboard_screen.dart';
import 'login_screen.dart';
import '../providers/auth_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isAuthenticated) {
      return const DashboardScreen();
    }
    return const LoginScreen();
  }
}


