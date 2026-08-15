import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoEditorScreen extends ConsumerStatefulWidget {
  final AssetEntity asset;

  const PhotoEditorScreen({
    Key? key,
    required this.asset,
  }) : super(key: key);

  @override
  ConsumerState<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends ConsumerState<PhotoEditorScreen> {
  double _brightness = 0.0;
  double _contrast = 0.0;
  double _saturation = 0.0;
  bool _showOriginal = false;
  int _selectedTab = 0; // 0: Kecerahan, 1: Kontras, 2: Saturasi, 3: Filter, 4: Crop, 5: Putar

  final List<String> _tabs = [
    'Kecerahan',
    'Kontras',
    'Saturasi',
    'Filter',
    'Crop',
    'Putar'
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cupertinoOverrideTheme: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: CupertinoColors.activeBlue,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: TextButton(
            onPressed: () => context.pop(),
            child: const Text('Batal', style: TextStyle(color: CupertinoColors.systemGrey)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save logic
                context.pop();
              },
              child: const Text('Selesai', style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onLongPressStart: (_) => setState(() => _showOriginal = true),
                onLongPressEnd: (_) => setState(() => _showOriginal = false),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Fake image preview
                      Container(
                        color: Colors.grey.shade900,
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        child: const Icon(CupertinoIcons.photo, size: 100, color: Colors.white24),
                      ),
                      if (_showOriginal)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('Asli', style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 160,
              color: Colors.black,
              child: Column(
                children: [
                  Expanded(child: _buildTabContent()),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedTab == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTab = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            alignment: Alignment.center,
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white54,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildSlider(
          value: _brightness,
          onChanged: (val) => setState(() => _brightness = val),
        );
      case 1:
        return _buildSlider(
          value: _contrast,
          onChanged: (val) => setState(() => _contrast = val),
        );
      case 2:
        return _buildSlider(
          value: _saturation,
          onChanged: (val) => setState(() => _saturation = val),
        );
      case 3:
        return _buildFilters();
      case 4:
        return const Center(child: Text('Crop Functionality Placeholder', style: TextStyle(color: Colors.white)));
      case 5:
        return _buildRotationControls();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSlider({required double value, required ValueChanged<double> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: CupertinoSlider(
        value: value,
        min: -1.0,
        max: 1.0,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFilters() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          width: 60,
          margin: const EdgeInsets.only(right: 12, top: 16, bottom: 16),
          color: Colors.grey.shade800,
          child: const Center(child: Text('Filter', style: TextStyle(color: Colors.white, fontSize: 12))),
        );
      },
    );
  }

  Widget _buildRotationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(CupertinoIcons.rotate_left, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.rotate_right, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.arrow_left_right_square, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.arrow_up_down_square, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}
