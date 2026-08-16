import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../data/models/media_item.dart';
import '../../../data/providers/media_providers.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final trashAsync = ref.watch(trashProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? const Color(0xFF1C1C1E).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        leading: CupertinoNavigationBarBackButton(
          color: const Color(0xFF007AFF),
          onPressed: () => context.pop(),
        ),
        middle: const Text('Baru Dihapus'),
        trailing: trashAsync.maybeWhen(
          data: (items) => items.isNotEmpty
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    _isSelecting ? 'Batal' : 'Pilih',
                    style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _isSelecting = !_isSelecting;
                      _selectedIds.clear();
                    });
                  },
                )
              : null,
          orElse: () => null,
        ),
      ),
      body: trashAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.trash, size: 70, color: CupertinoColors.systemGrey),
                  const SizedBox(height: 16),
                  Text(
                    'Tempat Sampah Kosong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tidak ada item yang baru dihapus',
                    style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.systemGrey6,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Text(
                  'Item menampilkan jumlah hari tersisa sebelum dihapus permanen (maks 30 hari).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 12),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(2),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = _selectedIds.contains(item.id);
                    final daysLeft = _calculateDaysLeft(item.deletedAt);

                    return GestureDetector(
                      onTap: () {
                        if (_isSelecting) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            if (isSelected) {
                              _selectedIds.remove(item.id);
                            } else {
                              _selectedIds.add(item.id);
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
                                child: const Center(child: CupertinoActivityIndicator(radius: 8)),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$daysLeft hari',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (_isSelecting)
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Icon(
                                isSelected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                                color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: trashAsync.maybeWhen(
        data: (items) => items.isNotEmpty
            ? Container(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _isSelecting
                            ? (_selectedIds.isNotEmpty ? () => _restoreSelected(items) : null)
                            : () => _restoreAll(items),
                        child: Text(
                          _isSelecting ? 'Pulihkan (${_selectedIds.length})' : 'Pulihkan Semua',
                          style: const TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _isSelecting
                            ? (_selectedIds.isNotEmpty ? () => _deleteSelectedPermanently(items) : null)
                            : () => _emptyTrash(items),
                        child: Text(
                          _isSelecting ? 'Hapus (${_selectedIds.length})' : 'Kosongkan',
                          style: const TextStyle(color: CupertinoColors.destructiveRed, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  int _calculateDaysLeft(DateTime? deletedAt) {
    if (deletedAt == null) return 30;
    final diff = DateTime.now().difference(deletedAt).inDays;
    return (30 - diff).clamp(0, 30);
  }

  Future<void> _restoreSelected(List<MediaItem> items) async {
    HapticFeedback.mediumImpact();
    final repo = ref.read(mediaRepositoryProvider);
    await repo.restoreFromTrash(_selectedIds.toList());
    ref.invalidate(trashProvider);
    ref.invalidate(allMediaProvider);
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  Future<void> _restoreAll(List<MediaItem> items) async {
    HapticFeedback.mediumImpact();
    final repo = ref.read(mediaRepositoryProvider);
    await repo.restoreFromTrash(items.map((i) => i.id).toList());
    ref.invalidate(trashProvider);
    ref.invalidate(allMediaProvider);
  }

  Future<void> _deleteSelectedPermanently(List<MediaItem> items) async {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Hapus Permanen?'),
        message: const Text('Foto ini akan dihapus dari penyimpanan secara permanen. Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.heavyImpact();
              final repo = ref.read(mediaRepositoryProvider);
              await repo.deleteForever(_selectedIds.toList());
              ref.invalidate(trashProvider);
              setState(() {
                _isSelecting = false;
                _selectedIds.clear();
              });
            },
            child: const Text('Hapus Permanen'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
      ),
    );
  }

  Future<void> _emptyTrash(List<MediaItem> items) async {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Kosongkan Tempat Sampah?'),
        message: const Text('Semua foto di Baru Dihapus akan dihapus secara permanen.'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.heavyImpact();
              final repo = ref.read(mediaRepositoryProvider);
              await repo.emptyTrash();
              ref.invalidate(trashProvider);
            },
            child: const Text('Kosongkan Tempat Sampah'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
      ),
    );
  }
}
