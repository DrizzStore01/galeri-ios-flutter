import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/models/album_model.dart';
import 'data/models/media_item.dart';
import 'data/providers/media_providers.dart';
import 'data/repositories/media_repository.dart';
import 'presentation/screens/album/album_detail_screen.dart';
import 'presentation/screens/album/album_screen.dart';
import 'presentation/screens/backup/backup_screen.dart';
import 'presentation/screens/editor/photo_editor_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/home/slideshow_screen.dart';
import 'presentation/screens/trash/trash_screen.dart';
import 'presentation/screens/viewer/photo_viewer_screen.dart';
import 'presentation/widgets/common/permission_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final mediaRepository = await MediaRepository.init();

  runApp(
    ProviderScope(
      overrides: [
        mediaRepositoryProvider.overrideWithValue(mediaRepository),
      ],
      child: const GaleriApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PermissionGate(
        child: HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/trash',
      builder: (context, state) => const TrashScreen(),
    ),
    GoRoute(
      path: '/editor',
      builder: (context, state) {
        final asset = state.extra as AssetEntity;
        return PhotoEditorScreen(asset: asset);
      },
    ),
    GoRoute(
      path: '/backup',
      builder: (context, state) => const BackupScreen(),
    ),
    GoRoute(
      path: '/viewer',
      builder: (context, state) {
        final item = state.extra as MediaItem;
        return PhotoViewerScreen(initialItem: item);
      },
    ),
    GoRoute(
      path: '/album_detail',
      builder: (context, state) {
        final album = state.extra as AlbumModel;
        return AlbumDetailScreen(album: album);
      },
    ),
    GoRoute(
      path: '/slideshow',
      builder: (context, state) {
        final assets = state.extra as List<AssetEntity>;
        return SlideshowScreen(assets: assets);
      },
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
