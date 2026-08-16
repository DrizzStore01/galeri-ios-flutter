import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PermissionGate extends StatefulWidget {
  final Widget child;

  const PermissionGate({super.key, required this.child});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> with WidgetsBindingObserver {
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    if (mounted) {
      setState(() {
        _hasPermission = state.isAuth || state.hasAccess;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    if (mounted) {
      if (state.isAuth || state.hasAccess) {
        setState(() {
          _hasPermission = true;
        });
      } else {
        PhotoManager.openSetting();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_hasPermission) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.photo_fill_on_rectangle_fill,
                size: 80,
                color: Color(0xFF007AFF),
              ),
              const SizedBox(height: 24),
              Text(
                'Akses Galeri Diperlukan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aplikasi ini membutuhkan izin akses ke foto & video pada perangkat Anda agar dapat ditampilkan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              CupertinoButton.filled(
                onPressed: _requestPermission,
                child: const Text('Izinkan Akses'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
