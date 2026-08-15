import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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

  void _showBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext ctx) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Share'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tambah ke Album'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Jadikan Wallpaper'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Salin'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
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
                return PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext ctx, int index) {
                    final item = items[index];
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(
                        'https://picsum.photos/seed/${item.id}/800/800',
                      ),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  },
                  itemCount: items.length,
                  loadingBuilder: (context, event) => const Center(
                    child: CupertinoActivityIndicator(color: Colors.white),
                  ),
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                  pageController: _pageController,
                );
              },
              loading: () => const Center(
                child: CupertinoActivityIndicator(color: Colors.white),
              ),
              error: (e, st) => Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: _showUI ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(CupertinoIcons.share, color: Colors.white),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(CupertinoIcons.ellipsis, color: Colors.white),
                                onPressed: _showBottomSheet,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(CupertinoIcons.heart, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.slider_horizontal_3,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.info_circle,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.trash, color: Colors.white),
                            onPressed: () {},
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
