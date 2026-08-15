import 'dart:async';
import 'package:hive/hive.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/media_item.dart';
import '../models/album_model.dart';

class MediaRepository {
  final Box<bool> _favoritesBox;
  final Box<DateTime> _trashBox;

  MediaRepository(this._favoritesBox, this._trashBox);

  static Future<MediaRepository> init() async {
    final favBox = await Hive.openBox<bool>('favorites');
    final trashBox = await Hive.openBox<DateTime>('trash');
    return MediaRepository(favBox, trashBox);
  }

  Stream<List<MediaItem>> getAllMedia() async* {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      yield [];
      return;
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      hasAll: true,
    );

    if (albums.isEmpty) {
      yield [];
      return;
    }

    final AssetPathEntity allPhotos = albums.first;
    final int assetCount = await allPhotos.assetCountAsync;
    final List<AssetEntity> assets = await allPhotos.getAssetListRange(start: 0, end: assetCount);
    
    final List<MediaItem> mediaItems = [];
    for (var asset in assets) {
      if (_trashBox.containsKey(asset.id)) continue;
      
      var item = await MediaItem.fromAssetEntity(asset);
      if (_favoritesBox.containsKey(asset.id)) {
        item = item.copyWith(isFavorite: true);
      }
      mediaItems.add(item);
    }
    
    yield mediaItems;
  }

  Future<List<AlbumModel>> getAlbums() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) return [];

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );

    final List<AlbumModel> albums = [];
    for (var path in paths) {
      final int count = await path.assetCountAsync;
      if (count == 0) continue;
      
      final List<AssetEntity> firstAsset = await path.getAssetListRange(start: 0, end: 1);
      
      AlbumType type = AlbumType.custom;
      if (path.isAll) type = AlbumType.recents;

      albums.add(AlbumModel(
        id: path.id,
        name: path.name,
        assetPathId: path.id,
        coverAssetId: firstAsset.isNotEmpty ? firstAsset.first.id : null,
        count: count,
        type: type,
      ));
    }

    return albums;
  }

  Future<List<MediaItem>> getMediaByAlbum(String albumId) async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) return [];

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );

    final path = paths.firstWhere((p) => p.id == albumId, orElse: () => paths.first);
    final int count = await path.assetCountAsync;
    final List<AssetEntity> assets = await path.getAssetListRange(start: 0, end: count);

    final List<MediaItem> items = [];
    for (var asset in assets) {
      if (_trashBox.containsKey(asset.id)) continue;

      var item = await MediaItem.fromAssetEntity(asset);
      if (_favoritesBox.containsKey(asset.id)) {
        item = item.copyWith(isFavorite: true);
      }
      items.add(item);
    }

    return items;
  }

  Future<List<MediaItem>> getFavorites() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) return [];

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(hasAll: true);
    if (paths.isEmpty) return [];

    final AssetPathEntity allPhotos = paths.first;
    final int count = await allPhotos.assetCountAsync;
    final List<AssetEntity> assets = await allPhotos.getAssetListRange(start: 0, end: count);

    final List<MediaItem> items = [];
    for (var asset in assets) {
      if (_trashBox.containsKey(asset.id)) continue;
      
      if (_favoritesBox.containsKey(asset.id) || asset.isFavorite) {
        var item = await MediaItem.fromAssetEntity(asset);
        item = item.copyWith(isFavorite: true);
        items.add(item);
      }
    }
    return items;
  }

  Future<List<MediaItem>> getTrash() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) return [];

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(hasAll: true);
    if (paths.isEmpty) return [];

    final AssetPathEntity allPhotos = paths.first;
    final int count = await allPhotos.assetCountAsync;
    final List<AssetEntity> assets = await allPhotos.getAssetListRange(start: 0, end: count);

    final List<MediaItem> items = [];
    for (var asset in assets) {
      if (_trashBox.containsKey(asset.id)) {
        var item = await MediaItem.fromAssetEntity(asset);
        item = item.copyWith(
          isDeleted: true,
          deletedAt: _trashBox.get(asset.id),
        );
        items.add(item);
      }
    }
    return items;
  }

  Future<void> toggleFavorite(String id) async {
    if (_favoritesBox.containsKey(id)) {
      await _favoritesBox.delete(id);
    } else {
      await _favoritesBox.put(id, true);
    }
  }

  Future<void> moveToTrash(List<String> ids) async {
    final now = DateTime.now();
    for (var id in ids) {
      await _trashBox.put(id, now);
      if (_favoritesBox.containsKey(id)) {
        await _favoritesBox.delete(id);
      }
    }
  }

  Future<void> restoreFromTrash(List<String> ids) async {
    for (var id in ids) {
      await _trashBox.delete(id);
    }
  }

  Future<void> deleteForever(List<String> ids) async {
    for (var id in ids) {
      await _trashBox.delete(id);
    }
    await PhotoManager.editor.deleteWithIds(ids);
  }

  Future<void> emptyTrash() async {
    final ids = _trashBox.keys.cast<String>().toList();
    await _trashBox.clear();
    if (ids.isNotEmpty) {
      await PhotoManager.editor.deleteWithIds(ids);
    }
  }

  Future<void> deleteOldTrashItems() async {
    final now = DateTime.now();
    final List<String> toDelete = [];
    
    for (var key in _trashBox.keys) {
      final String id = key as String;
      final DateTime? deletedAt = _trashBox.get(id);
      if (deletedAt != null && now.difference(deletedAt).inDays >= 30) {
        toDelete.add(id);
      }
    }

    if (toDelete.isNotEmpty) {
      for (var id in toDelete) {
        await _trashBox.delete(id);
      }
      await PhotoManager.editor.deleteWithIds(toDelete);
    }
  }
}
