import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/media_item.dart';
import '../../../data/providers/media_providers.dart';

class PhotoViewerScreen extends ConsumerStatefulWidget {
  final MediaItem initialItem;

  const PhotoViewerScreen({super.key, required this.initialItem});

  @override
  ConsumerState<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends ConsumerState<PhotoViewerScreen> {
  bool _showUI = true;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
  }

  void _showBottomSheet(MediaItem currentItem) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext ctx) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              final entity = await AssetEntity.fromId(currentItem.assetId);
              final file = await entity?.file;
              if (file != null) {
                await Share.shareXFiles([XFile(file.path)], text: currentItem.title);
              }
            },
            child: const Text('Share'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/backup');
            },
            child: const Text('Cadangkan ke Cloud'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              final entity = await AssetEntity.fromId(currentItem.assetId);
              if (entity != null) {
                context.push('/editor', extra: entity);
              }
            },
            child: const Text('Edit Foto'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              final items = ref.read(allMediaProvider).asData?.value ?? [];
              final assets = <AssetEntity>[];
              for (final item in items) {
                final entity = await AssetEntity.fromId(item.assetId);
                if (entity != null) assets.add(entity);
              }
              if (assets.isNotEmpty && mounted) {
                context.push('/slideshow', extra: assets);
              }
            },
            child: const Text('Slide Show'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          isDefaultAction: true,
          child: const Text('Batal'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(allMediaProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          children: [
            mediaAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Foto tidak ditemukan', style: TextStyle(color: Colors.white)),
                  );
                }

                final initialIndex = items.indexWhere((i) => i.id == widget.initialItem.id);
                final resolvedIndex = initialIndex >= 0 ? initialIndex : 0;

                return PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  pageController: PageController(initialPage: resolvedIndex),
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: items.length,
                  builder: (BuildContext ctx, int index) {
                    final item = items[index];
                    return PhotoViewGalleryPageOptions.customChild(
                      child: FutureBuilder<Uint8List?>(
                        future: AssetEntity.fromId(item.assetId).then(
                          (e) => e?.originBytes,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.contain,
                            );
                          }
                          return const Center(
                            child: CupertinoActivityIndicator(color: Colors.white),
                          );
                        },
                      ),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 3,
                    );
                  },
                  loadingBuilder: (context, event) => const Center(
                    child: CupertinoActivityIndicator(color: Colors.white),
                  ),
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                );
              },
              loading: () => const Center(
                child: CupertinoActivityIndicator(color: Colors.white),
              ),
              error: (e, st) => Center(
                child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
              ),
            ),

            // Top overlay bar
            AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          mediaAsync.maybeWhen(
                            data: (items) => Text(
                              '${_currentIndex + 1} / ${items.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            orElse: () => const SizedBox(),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(CupertinoIcons.share, color: Colors.white),
                                onPressed: () async {
                                  final items = mediaAsync.asData?.value;
                                  if (items != null && items.isNotEmpty) {
                                    final currentItem = items[_currentIndex.clamp(0, items.length - 1)];
                                    final entity = await AssetEntity.fromId(currentItem.assetId);
                                    final file = await entity?.file;
                                    if (file != null) {
                                      await Share.shareXFiles([XFile(file.path)]);
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(CupertinoIcons.ellipsis, color: Colors.white),
                                onPressed: () {
                                  final items = mediaAsync.asData?.value;
                                  if (items != null && items.isNotEmpty) {
                                    _showBottomSheet(items[_currentIndex.clamp(0, items.length - 1)]);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom action toolbar
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(CupertinoIcons.heart, color: Colors.white),
                            onPressed: () async {
                              final items = mediaAsync.asData?.value;
                              if (items != null && items.isNotEmpty) {
                                final currentItem = items[_currentIndex.clamp(0, items.length - 1)];
                                final repo = ref.read(mediaRepositoryProvider);
                                await repo.toggleFavorite(currentItem.id);
                                ref.invalidate(allMediaProvider);
                                ref.invalidate(favoritesProvider);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.slider_horizontal_3, color: Colors.white),
                            onPressed: () async {
                              final items = mediaAsync.asData?.value;
                              if (items != null && items.isNotEmpty) {
                                final currentItem = items[_currentIndex.clamp(0, items.length - 1)];
                                final entity = await AssetEntity.fromId(currentItem.assetId);
                                if (entity != null) {
                                  context.push('/editor', extra: entity);
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.trash, color: Colors.white),
                            onPressed: () async {
                              final items = mediaAsync.asData?.value;
                              if (items != null && items.isNotEmpty) {
                                final currentItem = items[_currentIndex.clamp(0, items.length - 1)];
                                final repo = ref.read(mediaRepositoryProvider);
                                await repo.moveToTrash([currentItem.id]);
                                ref.invalidate(allMediaProvider);
                                ref.invalidate(trashProvider);
                                if (mounted) context.pop();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
