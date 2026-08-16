import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../data/models/album_model.dart';
import '../../../data/providers/media_providers.dart';

class AlbumDetailScreen extends ConsumerStatefulWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  ConsumerState<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(mediaByAlbumProvider(widget.album.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.8),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: FlexibleSpaceBar(
                  title: Text(
                    widget.album.name,
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  centerTitle: false,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Color(0xFF007AFF)),
              onPressed: () => context.pop(),
            ),
          ),
          mediaAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Album kosong', style: TextStyle(color: CupertinoColors.systemGrey)),
                  ),
                );
              }
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        context.push('/viewer', extra: item);
                      },
                      child: FutureBuilder<Uint8List?>(
                        future: AssetEntity.fromId(item.assetId).then(
                          (entity) => entity?.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          }
                          return Container(
                            color: CupertinoColors.systemGrey5,
                            child: const Center(
                              child: CupertinoActivityIndicator(radius: 8),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
