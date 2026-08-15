import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  bool _isSelecting = false;
  final List<String> _dummyItems = List.generate(10, (index) => 'item_$index');
  final Set<String> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = _dummyItems.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        middle: const Text('Baru Dihapus'),
        trailing: _isSelecting
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Batal'),
                onPressed: () {
                  setState(() {
                    _isSelecting = false;
                    _selectedItems.clear();
                  });
                },
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Pilih'),
                onPressed: () => setState(() => _isSelecting = true),
              ),
      ),
      body: isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.trash, size: 64, color: CupertinoColors.systemGrey),
                  SizedBox(height: 16),
                  Text('Tempat Sampah Kosong', style: TextStyle(fontSize: 18, color: CupertinoColors.systemGrey)),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: CupertinoColors.systemGrey6,
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    'Item akan dihapus permanen setelah 30 hari',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 13),
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
                    itemCount: _dummyItems.length,
                    itemBuilder: (context, index) {
                      final item = _dummyItems[index];
                      final isSelected = _selectedItems.contains(item);
                      return GestureDetector(
                        onTap: _isSelecting
                            ? () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedItems.remove(item);
                                  } else {
                                    _selectedItems.add(item);
                                  }
                                });
                              }
                            : null,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: Colors.grey.shade300,
                              child: const Icon(CupertinoIcons.photo, color: Colors.white),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('29 hari', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                            ),
                            if (_isSelecting)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Icon(
                                  isSelected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                                  color: isSelected ? CupertinoColors.activeBlue : Colors.white,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _isSelecting && !isEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Pulihkan', style: TextStyle(color: CupertinoColors.activeBlue)),
                      onPressed: _selectedItems.isNotEmpty ? () {} : null,
                    ),
                    CupertinoButton(
                      child: const Text('Hapus', style: TextStyle(color: CupertinoColors.destructiveRed)),
                      onPressed: _selectedItems.isNotEmpty
                          ? () {
                              _showDeleteConfirmation(context);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Hapus Permanen?'),
        message: const Text('Item ini akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              // Handle delete
            },
            child: const Text('Hapus Permanen'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ),
    );
  }
}
