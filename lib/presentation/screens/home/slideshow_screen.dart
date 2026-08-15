import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:go_router/go_router.dart';

class SlideshowScreen extends ConsumerStatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;

  const SlideshowScreen({
    Key? key,
    required this.assets,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  ConsumerState<SlideshowScreen> createState() => _SlideshowScreenState();
}

class _SlideshowScreenState extends ConsumerState<SlideshowScreen> with SingleTickerProviderStateMixin {
  late int _currentIndex;
  bool _isPlaying = true;
  Timer? _timer;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _startSlideshow();
  }

  void _startSlideshow() {
    _progressController.forward(from: 0.0);
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isPlaying) {
        _nextSlide();
      }
    });
  }

  void _stopSlideshow() {
    _timer?.cancel();
    _progressController.stop();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startSlideshow();
      } else {
        _stopSlideshow();
      }
    });
  }

  void _nextSlide() {
    if (_currentIndex < widget.assets.length - 1) {
      setState(() => _currentIndex++);
      _progressController.forward(from: 0.0);
    } else {
      _stopSlideshow();
      if (mounted) context.pop();
    }
  }

  void _prevSlide() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _progressController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _stopSlideshow();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assets.isEmpty) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _buildMediaItem(widget.assets[_currentIndex]),
            ),
            
            // Progress bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressController.value,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 2,
                  );
                },
              ),
            ),

            // Controls
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.backward_fill, color: Colors.white),
                      onPressed: _prevSlide,
                    ),
                    IconButton(
                      icon: Icon(_isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill, color: Colors.white, size: 40),
                      onPressed: _togglePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.forward_fill, color: Colors.white),
                      onPressed: _nextSlide,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaItem(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      key: ValueKey(asset.id),
      future: asset.originBytes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.contain,
          );
        }
        return const Center(child: Icon(CupertinoIcons.photo, color: Colors.white24, size: 64));
      },
    );
  }
}
