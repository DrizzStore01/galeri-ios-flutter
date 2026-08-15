import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  // Open any necessary boxes here, e.g., await Hive.openBox('settings');

  runApp(
    const ProviderScope(
      child: GaleriApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Home'))), // Placeholder
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Favorites'))), // Placeholder
    ),
    GoRoute(
      path: '/trash',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Trash'))), // Placeholder
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Editor'))), // Placeholder
    ),
    GoRoute(
      path: '/backup',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Backup'))), // Placeholder
    ),
    GoRoute(
      path: '/viewer',
      builder: (context, state) => const Scaffold(body: Center(child: Text('Viewer'))), // Placeholder
    ),
    GoRoute(
      path: '/:albumId',
      builder: (context, state) => Scaffold(body: Center(child: Text('Album ${state.pathParameters['albumId']}'))), // Placeholder
    ),
  ],
);

class GaleriApp extends StatelessWidget {
  const GaleriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
