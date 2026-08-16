import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../data/providers/media_providers.dart';

class PhotoEditorScreen extends ConsumerStatefulWidget {
  final AssetEntity asset;

  const PhotoEditorScreen({
    super.key,
    required this.asset,
  });

  @override
  ConsumerState<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends ConsumerState<PhotoEditorScreen> {
  Uint8List? _originalBytes;
  File? _currentFile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showOriginal = false;

  // Edit adjustments
  double _brightness = 0.0;   // -0.5 to 0.5
  double _contrast = 0.0;     // -0.5 to 0.5
  double _saturation = 0.0;   // -1.0 to 1.0
  double _warmth = 0.0;       // -0.5 to 0.5
  int _rotationQuarter = 0;   // 0, 1, 2, 3 (x 90 deg)
  bool _flipHorizontal = false;
  String _selectedFilter = 'none';

  int _selectedTabIndex = 0; // 0: Penyesuaian, 1: Filter, 2: Crop, 3: Putar
  int _adjustmentIndex = 0;  // 0: Kecerahan, 1: Kontras, 2: Saturasi, 3: Kehangatan

  final List<Map<String, dynamic>> _adjustmentTools = [
    {'name': 'Kecerahan', 'icon': CupertinoIcons.sun_max_fill},
    {'name': 'Kontras', 'icon': CupertinoIcons.circle_righthalf_fill},
    {'name': 'Saturasi', 'icon': CupertinoIcons.drop_fill},
    {'name': 'Kehangatan', 'icon': CupertinoIcons.flame_fill},
  ];

  final List<Map<String, dynamic>> _filters = [
    {'id': 'none', 'name': 'Asli'},
    {'id': 'vivid', 'name': 'Vivid'},
    {'id': 'vivid_warm', 'name': 'Vivid Hangat'},
    {'id': 'vivid_cool', 'name': 'Vivid Sejuk'},
    {'id': 'dramatic', 'name': 'Dramatis'},
    {'id': 'mono', 'name': 'Mono'},
    {'id': 'silvertone', 'name': 'Silvertone'},
    {'id': 'noir', 'name': 'Noir'},
  ];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final file = await widget.asset.originFile;
      final bytes = await widget.asset.originBytes;
      if (mounted) {
        setState(() {
          _currentFile = file;
          _originalBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cropImage() async {
    if (_currentFile == null) return;

    HapticFeedback.mediumImpact();
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _currentFile!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Pangkas Foto',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: const Color(0xFF007AFF),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
    );

    if (croppedFile != null) {
      final croppedBytes = await croppedFile.readAsBytes();
      setState(() {
        _currentFile = File(croppedFile.path);
        _originalBytes = croppedBytes;
      });
    }
  }

  void _rotateClockwise() {
    HapticFeedback.lightImpact();
    setState(() {
      _rotationQuarter = (_rotationQuarter + 1) % 4;
    });
  }

  void _toggleFlip() {
    HapticFeedback.lightImpact();
    setState(() {
      _flipHorizontal = !_flipHorizontal;
    });
  }

  void _resetAdjustments() {
    HapticFeedback.mediumImpact();
    setState(() {
      _brightness = 0.0;
      _contrast = 0.0;
      _saturation = 0.0;
      _warmth = 0.0;
      _rotationQuarter = 0;
      _flipHorizontal = false;
      _selectedFilter = 'none';
    });
  }

  Future<void> _saveEditedPhoto() async {
    if (_originalBytes == null) return;

    setState(() => _isSaving = true);
    HapticFeedback.heavyImpact();

    try {
      // Simpan langsung ke device media gallery
      final filename = 'IMG_EDIT_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await PhotoManager.editor.saveImage(
        _originalBytes!,
        title: filename,
        filename: filename,
      );

      ref.invalidate(allMediaProvider);
      ref.invalidate(albumsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil disimpan ke Galeri!'),
            backgroundColor: Color(0xFF007AFF),
            duration: Duration(seconds: 2),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan foto: $e'),
            backgroundColor: CupertinoColors.destructiveRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<double> _buildColorMatrix() {
    if (_showOriginal) {
      return _identityMatrix();
    }

    // Baseline matrix
    double b = _brightness * 255;
    double c = 1.0 + _contrast;
    double s = 1.0 + _saturation;
    double w = _warmth;

    // Filter presets
    if (_selectedFilter == 'vivid') {
      s += 0.4;
      c += 0.15;
    } else if (_selectedFilter == 'vivid_warm') {
      s += 0.4;
      c += 0.15;
      w += 0.25;
    } else if (_selectedFilter == 'vivid_cool') {
      s += 0.4;
      c += 0.15;
      w -= 0.25;
    } else if (_selectedFilter == 'dramatic') {
      c += 0.35;
      s -= 0.1;
    } else if (_selectedFilter == 'mono') {
      s = 0.0;
    } else if (_selectedFilter == 'silvertone') {
      s = 0.0;
      b += 15;
      c += 0.2;
    } else if (_selectedFilter == 'noir') {
      s = 0.0;
      c += 0.5;
      b -= 10;
    }

    // Lum coefficients for saturation
    const lr = 0.2126;
    const lg = 0.7152;
    const lb = 0.0722;

    double invS = 1.0 - s;
    double rS = invS * lr + s;
    double gS = invS * lg;
    double bS = invS * lb;

    // Apply warmth (adds red/yellow, reduces blue)
    double rW = 1.0 + w * 0.2;
    double bW = 1.0 - w * 0.2;

    return [
      (rS * c) * rW, (gS * c), (bS * c), 0, b,
      (rS * c), (invS * lg + s) * c, (bS * c), 0, b,
      (rS * c), (gS * c), (invS * lb + s) * c * bW, 0, b,
      0, 0, 0, 1, 0,
    ];
  }

  List<double> _identityMatrix() {
    return [
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Batal', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        centerTitle: true,
        title: _hasAnyEdits()
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _resetAdjustments,
                child: const Text(
                  'Atur Ulang',
                  style: TextStyle(color: Color(0xFFFF9F0A), fontSize: 14, fontWeight: FontWeight.w600),
                ),
              )
            : null,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CupertinoActivityIndicator(color: Colors.white),
            )
          else
            TextButton(
              onPressed: _saveEditedPhoto,
              child: const Text(
                'Selesai',
                style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator(color: Colors.white, radius: 14))
          : Column(
              children: [
                // Preview Area
                Expanded(
                  child: GestureDetector(
                    onLongPressStart: (_) {
                      HapticFeedback.selectionClick();
                      setState(() => _showOriginal = true);
                    },
                    onLongPressEnd: (_) => setState(() => _showOriginal = false),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_originalBytes != null)
                            Transform.rotate(
                              angle: _rotationQuarter * (3.141592653589793 / 2),
                              child: Transform.flip(
                                flipX: _flipHorizontal,
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.matrix(_buildColorMatrix()),
                                  child: Image.memory(
                                    _originalBytes!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            )
                          else
                            const Icon(CupertinoIcons.photo, color: Colors.white24, size: 80),

                          if (_showOriginal)
                            Positioned(
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'ASLI',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Control panel
                Container(
                  color: const Color(0xFF121212),
                  padding: const EdgeInsets.only(bottom: 24, top: 12),
                  child: Column(
                    children: [
                      // Sub-panel for active tool
                      _buildToolPanel(),
                      const SizedBox(height: 12),

                      // Bottom main tab selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTabIcon(
                            index: 0,
                            icon: CupertinoIcons.slider_horizontal_3,
                            label: 'Sesuaikan',
                          ),
                          _buildTabIcon(
                            index: 1,
                            icon: CupertinoIcons.sparkles,
                            label: 'Filter',
                          ),
                          _buildTabIcon(
                            index: 2,
                            icon: CupertinoIcons.crop,
                            label: 'Pangkas',
                            onTap: _cropImage,
                          ),
                          _buildTabIcon(
                            index: 3,
                            icon: CupertinoIcons.rotate_right,
                            label: 'Putar',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  bool _hasAnyEdits() {
    return _brightness != 0.0 ||
        _contrast != 0.0 ||
        _saturation != 0.0 ||
        _warmth != 0.0 ||
        _rotationQuarter != 0 ||
        _flipHorizontal ||
        _selectedFilter != 'none';
  }

  Widget _buildTabIcon({
    required int index,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (onTap != null) {
          onTap();
        } else {
          setState(() => _selectedTabIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF007AFF) : CupertinoColors.systemGrey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF007AFF) : CupertinoColors.systemGrey,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolPanel() {
    if (_selectedTabIndex == 0) {
      // Penyesuaian (Sliders)
      return Column(
        children: [
          // Value Indicator
          Text(
            _getAdjustmentValueString(),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CupertinoSlider(
              value: _getCurrentAdjustmentValue(),
              min: -0.5,
              max: 0.5,
              activeColor: const Color(0xFF007AFF),
              onChanged: (val) {
                setState(() {
                  _setCurrentAdjustmentValue(val);
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          // Tool icon picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_adjustmentTools.length, (i) {
              final tool = _adjustmentTools[i];
              final isCurrent = _adjustmentIndex == i;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _adjustmentIndex = i);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCurrent ? const Color(0xFF007AFF).withValues(alpha: 0.25) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tool['icon'] as IconData,
                    color: isCurrent ? const Color(0xFF007AFF) : CupertinoColors.systemGrey,
                    size: 20,
                  ),
                ),
              );
            }),
          ),
        ],
      );
    } else if (_selectedTabIndex == 1) {
      // Filters
      return SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = _selectedFilter == filter['id'];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = filter['id'] as String);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF2C2C2E),
                      ),
                      child: Center(
                        child: Text(
                          (filter['name'] as String).substring(0, 1),
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF007AFF) : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filter['name'] as String,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF007AFF) : CupertinoColors.systemGrey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else if (_selectedTabIndex == 3) {
      // Rotation / Flip
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: _rotateClockwise,
            child: const Row(
              children: [
                Icon(CupertinoIcons.rotate_right, color: Color(0xFF007AFF)),
                SizedBox(width: 6),
                Text('Putar 90°', style: TextStyle(color: Color(0xFF007AFF))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: _toggleFlip,
            child: const Row(
              children: [
                Icon(CupertinoIcons.arrow_left_right, color: Color(0xFF007AFF)),
                SizedBox(width: 6),
                Text('Cermin', style: TextStyle(color: Color(0xFF007AFF))),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox(height: 40);
  }

  double _getCurrentAdjustmentValue() {
    switch (_adjustmentIndex) {
      case 0:
        return _brightness;
      case 1:
        return _contrast;
      case 2:
        return _saturation;
      case 3:
        return _warmth;
      default:
        return 0.0;
    }
  }

  void _setCurrentAdjustmentValue(double val) {
    switch (_adjustmentIndex) {
      case 0:
        _brightness = val;
        break;
      case 1:
        _contrast = val;
        break;
      case 2:
        _saturation = val;
        break;
      case 3:
        _warmth = val;
        break;
    }
  }

  String _getAdjustmentValueString() {
    final val = (_getCurrentAdjustmentValue() * 100).round();
    final name = _adjustmentTools[_adjustmentIndex]['name'];
    return '$name: ${val > 0 ? "+$val" : val}';
  }
}
