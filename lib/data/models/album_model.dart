import 'package:hive/hive.dart';

part 'album_model.g.dart';

@HiveType(typeId: 2)
enum AlbumType {
  @HiveField(0)
  recents,
  @HiveField(1)
  favorites,
  @HiveField(2)
  videos,
  @HiveField(3)
  screenshots,
  @HiveField(4)
  custom,
}

@HiveType(typeId: 3)
class AlbumModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String assetPathId;
  @HiveField(3)
  final String? coverAssetId;
  @HiveField(4)
  final int count;
  @HiveField(5)
  final AlbumType type;

  AlbumModel({
    required this.id,
    required this.name,
    required this.assetPathId,
    this.coverAssetId,
    required this.count,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assetPathId': assetPathId,
      'coverAssetId': coverAssetId,
      'count': count,
      'type': type.index,
    };
  }

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'],
      name: json['name'],
      assetPathId: json['assetPathId'],
      coverAssetId: json['coverAssetId'],
      count: json['count'],
      type: AlbumType.values[json['type']],
    );
  }
}
