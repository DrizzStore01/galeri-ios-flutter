import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
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
  late int _currentIndex;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final items = ref.read(allMediaProvider).asData?.value ?? [];
      final idx = items.indexWhere((i) => i.id == widget.initialItem.id);
      _currentIndex = idx >= 0 ? idx : 0;
      _pageController = PageController(initialPage: _currentIndex);
      _initialized = true;
    }
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
          if (currentItem.type == MediaType.image)
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(ctx);
                final entity = await AssetEntity.fromId(currentItem.assetId);
                if (entity != null && mounted) {
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

                return PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  pageController: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: items.length,
                  builder: (BuildContext ctx, int index) {
                    final item = items[index];
                    final isCurrent = index == _currentIndex;

                    if (item.type == MediaType.video) {
                      return PhotoViewGalleryPageOptions.customChild(
                        child: _IOSVideoPlayerWidget(
                          assetId: item.assetId,
                          isCurrent: isCurrent,
                        ),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.contained,
                      );
                    }

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
                            data: (items) {
                              if (items.isEmpty) return const SizedBox();
                              final safeIdx = _currentIndex.clamp(0, items.length - 1);
                              final currentItem = items[safeIdx];
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${safeIdx + 1} dari ${items.length}',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  if (currentItem.type == MediaType.video)
                                    const Text(
                                      'Video',
                                      style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 11),
                                    ),
                                ],
                              );
                            },
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
                                HapticFeedback.mediumImpact();
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
                                if (entity != null && mounted) {
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
                                HapticFeedback.mediumImpact();
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

class _IOSVideoPlayerWidget extends StatefulWidget {
  final String assetId;
  final bool isCurrent;

  const _IOSVideoPlayerWidget({
    required this.assetId,
    required this.isCurrent,
  });

  @override
  State<_IOSVideoPlayerWidget> createState() => _IOSVideoPlayerWidgetState();
}

class _IOSVideoPlayerWidgetState extends State<_IOSVideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final entity = await AssetEntity.fromId(widget.assetId);
      final file = await entity?.file;
      if (file != null && mounted) {
        _controller = VideoPlayerController.file(file);
        await _controller!.initialize();
        _controller!.addListener(() {
          if (mounted) setState(() {});
        });
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant _IOSVideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isCurrent && oldWidget.isCurrent) {
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    HapticFeedback.selectionClick();
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Text('Gagal memutar video', style: TextStyle(color: Colors.white70)),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CupertinoActivityIndicator(color: Colors.white),
      );
    }

    final isPlaying = _controller!.value.isPlaying;
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),

          // Center Play/Pause button
          GestureDetector(
            onTap: _togglePlay,
            child: AnimatedOpacity(
              opacity: isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
          ),

          // Bottom scrubber
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Icon(
                      isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CupertinoSlider(
                      value: duration.inMilliseconds > 0
                          ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
                          : 0.0,
                      onChanged: (val) {
                        final newPos = Duration(milliseconds: (val * duration.inMilliseconds).toInt());
                        _controller!.seekTo(newPos);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDuration(position)} / ${_formatDuration(duration)}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
