import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../data/models/album_model.dart';
import '../../../data/providers/media_providers.dart';

class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);
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
                    'Album',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  centerTitle: false,
                ),
              ),
            ),
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              ref.invalidate(albumsProvider);
            },
          ),
          albumsAsync.when(
            data: (albums) {
              if (albums.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Belum ada album', style: TextStyle(color: CupertinoColors.systemGrey)),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final album = albums[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/album_detail', extra: album);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _AlbumCoverWidget(coverAssetId: album.coverAssetId),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              album.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'SF Pro Text',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              '${album.count}',
                              style: const TextStyle(
                                fontFamily: 'SF Pro Text',
                                fontSize: 14,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: albums.length,
                  ),
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

class _AlbumCoverWidget extends StatelessWidget {
  final String? coverAssetId;

  const _AlbumCoverWidget({this.coverAssetId});

  @override
  Widget build(BuildContext context) {
    if (coverAssetId == null) {
      return Container(
        color: CupertinoColors.systemGrey5,
        child: const Icon(CupertinoIcons.photo_on_rectangle, color: CupertinoColors.systemGrey, size: 40),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: AssetEntity.fromId(coverAssetId!).then(
        (entity) => entity?.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
          );
        }
        return Container(
          color: CupertinoColors.systemGrey5,
          child: const Center(child: CupertinoActivityIndicator(radius: 8)),
        );
      },
    );
  }
}
