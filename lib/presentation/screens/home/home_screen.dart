import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:intl/intl.dart';
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
    const _UtilitiesTab(),
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
          HapticFeedback.selectionClick();
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
            label: 'Utilitas',
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
  bool _isSearching = false;
  String _searchQuery = '';
  final Set<String> _selectedItems = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: _isSearching ? 120 : 100,
            floating: false,
            pinned: true,
            backgroundColor: appBarColor,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: FlexibleSpaceBar(
                  title: _isSearching
                      ? null
                      : Text(
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
            bottom: _isSearching
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: CupertinoSearchTextField(
                        controller: _searchController,
                        placeholder: 'Cari foto atau tanggal...',
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.toLowerCase();
                          });
                        },
                      ),
                    ),
                  )
                : null,
            actions: [
              IconButton(
                icon: Icon(
                  _isSearching ? CupertinoIcons.xmark_circle_fill : CupertinoIcons.search,
                  color: const Color(0xFF007AFF),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                      _searchController.clear();
                    }
                  });
                },
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              ref.invalidate(allMediaProvider);
            },
          ),
          mediaAsync.when(
            data: (items) {
              final filteredItems = _searchQuery.isEmpty
                  ? items
                  : items.where((item) {
                      final titleMatch = item.title.toLowerCase().contains(_searchQuery);
                      final dateStr = DateFormat('d MMMM yyyy').format(item.dateCreated).toLowerCase();
                      return titleMatch || dateStr.contains(_searchQuery);
                    }).toList();

              if (filteredItems.isEmpty) {
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
                          _searchQuery.isNotEmpty ? 'Foto tidak ditemukan' : 'Tidak ada foto',
                          style: TextStyle(
                            fontFamily: 'SF Pro Text',
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
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
                    final item = filteredItems[index];
                    final isSelected = _selectedItems.contains(item.id);

                    return GestureDetector(
                      onLongPress: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _isSelecting = true;
                          _selectedItems.add(item.id);
                        });
                      },
                      onTap: () {
                        if (_isSelecting) {
                          HapticFeedback.selectionClick();
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
                          _RealThumbnailWidget(assetId: item.assetId),
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
                                    child: Text(
                                      item.duration != null
                                          ? '${item.duration!.inMinutes}:${(item.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                                          : '0:30',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
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
                  childCount: filteredItems.length,
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
                    onPressed: _selectedItems.isEmpty
                        ? null
                        : () async {
                            HapticFeedback.mediumImpact();
                            final repo = ref.read(mediaRepositoryProvider);
                            for (final id in _selectedItems) {
                              await repo.toggleFavorite(id);
                            }
                            ref.invalidate(allMediaProvider);
                            ref.invalidate(favoritesProvider);
                            setState(() {
                              _isSelecting = false;
                              _selectedItems.clear();
                            });
                          },
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.trash, color: Color(0xFF007AFF)),
                    onPressed: _selectedItems.isEmpty
                        ? null
                        : () async {
                            HapticFeedback.mediumImpact();
                            final repo = ref.read(mediaRepositoryProvider);
                            await repo.moveToTrash(_selectedItems.toList());
                            ref.invalidate(allMediaProvider);
                            ref.invalidate(trashProvider);
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

class _RealThumbnailWidget extends StatelessWidget {
  final String assetId;

  const _RealThumbnailWidget({required this.assetId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: AssetEntity.fromId(assetId).then(
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
    );
  }
}

class _UtilitiesTab extends StatelessWidget {
  const _UtilitiesTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
                    'Utilitas',
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
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.trash_fill,
                  iconColor: CupertinoColors.systemRed,
                  title: 'Baru Dihapus',
                  subtitle: 'Item yang dihapus dalam 30 hari terakhir',
                  cardColor: cardColor,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push('/trash');
                  },
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.cloud_upload_fill,
                  iconColor: CupertinoColors.activeBlue,
                  title: 'Cadangan Cloud',
                  subtitle: 'Sinkronisasi foto & video ke cloud',
                  cardColor: cardColor,
                  isDark: isDark,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push('/backup');
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Icon(CupertinoIcons.photo_fill_on_rectangle_fill, size: 50, color: Color(0xFF007AFF)),
                      const SizedBox(height: 10),
                      Text(
                        'Galeri iOS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Versi 1.0.0 (Build 1)',
                        style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color cardColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey3, size: 18),
          ],
        ),
      ),
    );
  }
}
