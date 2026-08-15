import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaThumbnail extends StatefulWidget {
  final AssetEntity asset;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDuration;
  final bool showFavorite;
  final int size;

  const MediaThumbnail({
    Key? key,
    required this.asset,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.showDuration = true,
    this.showFavorite = true,
    this.size = 200,
  }) : super(key: key);

  @override
  State<MediaThumbnail> createState() => _MediaThumbnailState();
}

class _MediaThumbnailState extends State<MediaThumbnail> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Uint8List? _thumbnailData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_animationController);
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant MediaThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.asset.id != oldWidget.asset.id) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    final data = await widget.asset.thumbnailDataWithSize(ThumbnailSize(widget.size, widget.size));
    if (mounted) {
      setState(() {
        _thumbnailData = data;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) {
        _animationController.forward();
        widget.onLongPress?.call();
      },
      onLongPressEnd: (_) => _animationController.reverse(),
      onLongPressCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_thumbnailData != null)
              Image.memory(
                _thumbnailData!,
                fit: BoxFit.cover,
              )
            else
              Container(color: CupertinoColors.systemGrey5),
            
            if (widget.asset.type == AssetType.video && widget.showDuration)
              Positioned(
                bottom: 4,
                right: 4,
                child: Text(
                  _formatDuration(widget.asset.duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            if (widget.asset.isFavorite && widget.showFavorite)
              const Positioned(
                bottom: 4,
                left: 4,
                child: Icon(CupertinoIcons.heart_fill, color: Colors.white, size: 16),
              ),

            if (widget.isSelected)
              Container(
                color: Colors.white.withOpacity(0.4),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.activeBlue),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
