import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/media_repository.dart';
import '../models/media_item.dart';
import '../models/album_model.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  throw UnimplementedError('mediaRepositoryProvider must be overridden in main() with the initialized repository');
});

final allMediaProvider = StreamProvider<List<MediaItem>>((ref) {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.getAllMedia();
});

final albumsProvider = FutureProvider<List<AlbumModel>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.getAlbums();
});

final favoritesProvider = FutureProvider<List<MediaItem>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.getFavorites();
});

final trashProvider = FutureProvider<List<MediaItem>>((ref) async {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.getTrash();
});

final mediaByAlbumProvider = FutureProvider.family<List<MediaItem>, String>((ref, albumId) async {
  final repo = ref.watch(mediaRepositoryProvider);
  return repo.getMediaByAlbum(albumId);
});

final selectedMediaProvider = StateProvider<Set<String>>((ref) => {});

final viewerIndexProvider = StateProvider<int>((ref) => 0);

final slideshowActiveProvider = StateProvider<bool>((ref) => false);
