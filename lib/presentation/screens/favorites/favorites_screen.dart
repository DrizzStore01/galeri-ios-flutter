import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../data/models/media_item.dart';
import '../../../data/providers/media_providers.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _isSelecting = false;
  final Set<String> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final appBarColor = isDark
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.8);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: appBarColor,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: FlexibleSpaceBar(
                  title: Text(
                    'Favorit',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  centerTitle: false,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSelecting = !_isSelecting;
                    _selectedItems.clear();
                  });
                },
                child: Text(
                  _isSelecting ? 'Batal' : 'Pilih',
                  style: const TextStyle(
                    color: Color(0xFF007AFF),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              ref.invalidate(favoritesProvider);
            },
          ),
          favoritesAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.heart, size: 64, color: Color(0xFF8E8E93)),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada foto favorit',
                          style: TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
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
                    final isSelected = _selectedItems.contains(item.id);

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _isSelecting = true;
                          _selectedItems.add(item.id);
                        });
                      },
                      onTap: () {
                        if (_isSelecting) {
                          setState(() {
                            if (isSelected) {
                              _selectedItems.remove(item.id);
                            } else {
                              _selectedItems.add(item.id);
                            }
                          });
                        } else {
                          context.push('/viewer', extra: item);
                        }
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FutureBuilder<Uint8List?>(
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
                          if (_isSelecting)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Icon(
                                isSelected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                                color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                              ),
                            ),
                        ],
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
      bottomNavigationBar: _isSelecting
          ? Container(
              height: 60,
              color: bgColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.heart_slash, color: Color(0xFF007AFF)),
                    onPressed: _selectedItems.isEmpty
                        ? null
                        : () async {
                            final repo = ref.read(mediaRepositoryProvider);
                            for (final id in _selectedItems) {
                              await repo.toggleFavorite(id);
                            }
                            ref.invalidate(favoritesProvider);
                            ref.invalidate(allMediaProvider);
                            setState(() {
                              _isSelecting = false;
                              _selectedItems.clear();
                            });
                          },
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
