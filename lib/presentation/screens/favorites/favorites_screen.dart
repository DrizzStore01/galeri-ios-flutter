import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/media_item.dart';
import '../../../data/providers/media_providers.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _isSelecting = false;
  final Set<String> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesProvider);

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
                    'Favorit',
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
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1C1C1E)
                  : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.heart_slash, color: Color(0xFF007AFF)),
                    onPressed: _selectedItems.isEmpty ? null : () {},
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
