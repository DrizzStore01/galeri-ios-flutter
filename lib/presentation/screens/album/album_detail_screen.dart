import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/album_model.dart';
import '../../../data/models/media_item.dart';
import '../../../data/providers/media_providers.dart';

class AlbumDetailScreen extends ConsumerStatefulWidget {
  final AlbumModel album;

  const AlbumDetailScreen({Key? key, required this.album}) : super(key: key);

  @override
  ConsumerState<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(mediaByAlbumProvider(widget.album.id));

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1C1C1E).withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: FlexibleSpaceBar(
                  title: Text(
                    widget.album.name,
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://picsum.photos/seed/${item.id}/200/200',
                          fit: BoxFit.cover,
                        ),
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
