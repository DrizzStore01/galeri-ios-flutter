import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/media_item.dart';
import '../../../data/providers/media_providers.dart';
import '../album/album_screen.dart';
import '../favorites/favorites_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _PhotosTab(),
    const AlbumScreen(),
    const FavoritesScreen(),
    const Center(child: Text('Lainnya')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        activeColor: const Color(0xFF007AFF),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Foto',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_stack_3d_up),
            label: 'Album',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.ellipsis_circle),
            label: 'Lainnya',
          ),
        ],
      ),
    );
  }
}

class _PhotosTab extends ConsumerStatefulWidget {
  const _PhotosTab();

  @override
  ConsumerState<_PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends ConsumerState<_PhotosTab> {
  bool _isSelecting = false;
  final Set<String> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(allMediaProvider);
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
                    'Galeri',
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
              IconButton(
                icon: const Icon(CupertinoIcons.search, color: Color(0xFF007AFF)),
                onPressed: () {},
              ),
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
            onRefresh: () async {},
          ),
          mediaAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.photo,
                          size: 64,
                          color: Color(0xFF8E8E93),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada foto',
                          style: TextStyle(
                            fontFamily: 'SF Pro Text',
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://picsum.photos/seed/${item.id}/200/200',
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (item.type == MediaType.video)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    color: Colors.black.withValues(alpha: 0.5),
                                    child: const Text(
                                      '0:30',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (item.isFavorite)
                            const Positioned(
                              top: 4,
                              right: 4,
                              child: Icon(
                                CupertinoIcons.heart_fill,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          if (_isSelecting)
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Icon(
                                isSelected
                                    ? CupertinoIcons.checkmark_circle_fill
                                    : CupertinoIcons.circle,
                                color: isSelected
                                    ? const Color(0xFF007AFF)
                                    : Colors.white,
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
                    icon: const Icon(CupertinoIcons.share, color: Color(0xFF007AFF)),
                    onPressed: _selectedItems.isEmpty ? null : () {},
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.heart, color: Color(0xFF007AFF)),
                    onPressed: _selectedItems.isEmpty ? null : () {},
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.trash, color: Color(0xFF007AFF)),
                    onPressed: _selectedItems.isEmpty ? null : () {},
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
