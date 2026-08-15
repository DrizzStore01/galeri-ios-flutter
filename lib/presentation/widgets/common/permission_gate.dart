import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionGate extends StatefulWidget {
  final Widget child;

  const PermissionGate({Key? key, required this.child}) : super(key: key);

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
    final status = await Permission.storage.status;
    final photosStatus = await Permission.photos.status;
    
    setState(() {
      _hasPermission = status.isGranted || photosStatus.isGranted;
      _isLoading = false;
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      final storageStatus = await Permission.storage.request();
      setState(() {
        _hasPermission = storageStatus.isGranted;
      });
      if (storageStatus.isPermanentlyDenied) {
        openAppSettings();
      }
    } else {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
    }

    if (_hasPermission) {
      return widget.child;
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.camera_fill, size: 80, color: CupertinoColors.systemGrey),
              const SizedBox(height: 24),
              const Text(
                'Akses Galeri',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aplikasi ini membutuhkan akses ke galeri untuk menampilkan foto dan video Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
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
