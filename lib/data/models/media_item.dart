import 'package:hive/hive.dart';
import 'package:photo_manager/photo_manager.dart';

part 'media_item.g.dart';

@HiveType(typeId: 0)
enum MediaType {
  @HiveField(0)
  image,
  @HiveField(1)
  video,
}

@HiveType(typeId: 1)
class MediaItem {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String assetId;
  @HiveField(2)
  final MediaType type;
  @HiveField(3)
  final String title;
  @HiveField(4)
  final String? path;
  @HiveField(5)
  final String? thumbnailPath;
  @HiveField(6)
  final Duration? duration;
  @HiveField(7)
  final DateTime dateCreated;
  @HiveField(8)
  final DateTime dateModified;
  @HiveField(9)
  final int width;
  @HiveField(10)
  final int height;
  @HiveField(11)
  final int size;
  @HiveField(12)
  final bool isFavorite;
  @HiveField(13)
  final bool isDeleted;
  @HiveField(14)
  final DateTime? deletedAt;
  @HiveField(15)
  final List<String> albumIds;

  MediaItem({
    required this.id,
    required this.assetId,
    required this.type,
    required this.title,
    this.path,
    this.thumbnailPath,
    this.duration,
    required this.dateCreated,
    required this.dateModified,
    required this.width,
    required this.height,
    required this.size,
    this.isFavorite = false,
    this.isDeleted = false,
    this.deletedAt,
    this.albumIds = const [],
  });

  MediaItem copyWith({
    String? id,
    String? assetId,
    MediaType? type,
    String? title,
    String? path,
    String? thumbnailPath,
    Duration? duration,
    DateTime? dateCreated,
    DateTime? dateModified,
    int? width,
    int? height,
    int? size,
    bool? isFavorite,
    bool? isDeleted,
    DateTime? deletedAt,
    List<String>? albumIds,
  }) {
    return MediaItem(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      type: type ?? this.type,
      title: title ?? this.title,
      path: path ?? this.path,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      duration: duration ?? this.duration,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      width: width ?? this.width,
      height: height ?? this.height,
      size: size ?? this.size,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      albumIds: albumIds ?? this.albumIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'type': type.index,
      'title': title,
      'path': path,
      'thumbnailPath': thumbnailPath,
      'duration': duration?.inMilliseconds,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
      'width': width,
      'height': height,
      'size': size,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'albumIds': albumIds,
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      assetId: json['assetId'],
      type: MediaType.values[json['type']],
      title: json['title'],
      path: json['path'],
      thumbnailPath: json['thumbnailPath'],
      duration: json['duration'] != null ? Duration(milliseconds: json['duration']) : null,
      dateCreated: DateTime.parse(json['dateCreated']),
      dateModified: DateTime.parse(json['dateModified']),
      width: json['width'],
      height: json['height'],
      size: json['size'],
      isFavorite: json['isFavorite'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      albumIds: List<String>.from(json['albumIds'] ?? []),
    );
  }

  static Future<MediaItem> fromAssetEntity(AssetEntity asset) async {
    return MediaItem(
      id: asset.id,
      assetId: asset.id,
      type: asset.type == AssetType.video ? MediaType.video : MediaType.image,
      title: asset.title ?? 'Unknown',
      duration: asset.duration > 0 ? Duration(seconds: asset.duration) : null,
      dateCreated: asset.createDateTime,
      dateModified: asset.modifiedDateTime,
      width: asset.width,
      height: asset.height,
      size: 0, // Requires additional async call to fetch size if needed
      isFavorite: asset.isFavorite,
    );
  }
}
