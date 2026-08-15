import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/album_model.dart';
import '../../../data/providers/media_providers.dart';

class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);

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
                    'Album',
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
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.add, color: Color(0xFF007AFF)),
                onPressed: () {},
              ),
            ],
          ),
          albumsAsync.when(
            data: (albums) {
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
                                child: Image.network(
                                  'https://picsum.photos/seed/${album.id}/200/200',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              album.name,
                              style: TextStyle(
                                fontFamily: 'SF Pro Text',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
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
