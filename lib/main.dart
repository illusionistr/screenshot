import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/dependency_injection.dart';
import 'core/services/firebase_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/projects/providers/project_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  setupDependencyInjection();
  // Ensure FirebaseService is initialized (for possible web configs)
  await serviceLocator<FirebaseService>().initialize();

  runApp(const Bootstrap());
}

class Bootstrap extends StatelessWidget {
  const Bootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProjectProvider>(
          create: (context) => ProjectProvider(authProvider: context.read<AuthProvider>()),
          update: (context, auth, previous) => previous ?? ProjectProvider(authProvider: auth),
        ),
      ],
      child: const AppRoot(),
    );
  }
}
