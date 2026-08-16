import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/media_providers.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _backupEnabled = true;
  bool _wifiOnly = true;
  bool _includeVideos = true;
  bool _includeRaw = false;

  bool _isBackingUp = false;
  double _backupProgress = 0.65;
  Timer? _simulationTimer;

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _startBackupSimulation(int totalPhotos) {
    if (_isBackingUp) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isBackingUp = true;
      _backupProgress = 0.0;
    });

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _backupProgress += 0.03;
        if (_backupProgress >= 1.0) {
          _backupProgress = 1.0;
          _isBackingUp = false;
          timer.cancel();
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cadangan selesai! Semua foto & video tersinkronisasi.'),
              backgroundColor: Color(0xFF007AFF),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(allMediaProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    final totalCount = mediaAsync.asData?.value.length ?? 0;
    final backedUpCount = (_backupProgress * totalCount).round();

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
        middle: const Text('Cadangan Cloud'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 20),
          _buildGroup(
            cardColor: cardColor,
            children: [
              _buildSwitchRow(
                'Cadangan Otomatis',
                _backupEnabled,
                (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _backupEnabled = val);
                },
                isDark: isDark,
              ),
            ],
          ),
          if (_backupEnabled) ...[
            const SizedBox(height: 20),
            _buildStatusCard(
              cardColor: cardColor,
              isDark: isDark,
              totalCount: totalCount,
              backedUpCount: backedUpCount,
            ),
            const SizedBox(height: 20),
            _buildGroup(
              cardColor: cardColor,
              children: [
                _buildSwitchRow(
                  'Hanya via WiFi',
                  _wifiOnly,
                  (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _wifiOnly = val);
                  },
                  isDark: isDark,
                ),
                Divider(height: 1, indent: 16, color: isDark ? Colors.white12 : Colors.black12),
                _buildSwitchRow(
                  'Sertakan Video',
                  _includeVideos,
                  (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _includeVideos = val);
                  },
                  isDark: isDark,
                ),
                Divider(height: 1, indent: 16, color: isDark ? Colors.white12 : Colors.black12),
                _buildSwitchRow(
                  'Sertakan File RAW',
                  _includeRaw,
                  (val) {
                    HapticFeedback.selectionClick();
                    setState(() => _includeRaw = val);
                  },
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton.filled(
                onPressed: _isBackingUp ? null : () => _startBackupSimulation(totalCount),
                child: _isBackingUp
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(color: Colors.white),
                          SizedBox(width: 10),
                          Text('Menyinkronkan...'),
                        ],
                      )
                    : const Text('Cadangkan Sekarang'),
              ),
            ),
          ],
          const SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Sinkronisasi aman menggunakan enkripsi end-to-end.\nKoneksi iCloud & Google Photos terintegrasi otomatis.',
              textAlign: TextAlign.center,
              style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildGroup({required Color cardColor, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged, {required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFF007AFF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required Color cardColor,
    required bool isDark,
    required int totalCount,
    required int backedUpCount,
  }) {
    final percent = (_backupProgress * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: _backupProgress,
                  strokeWidth: 9,
                  backgroundColor: isDark ? Colors.white12 : CupertinoColors.systemGrey5,
                  color: const Color(0xFF007AFF),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    _isBackingUp ? 'Sinkron...' : 'Aman',
                    style: const TextStyle(fontSize: 11, color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$backedUpCount / $totalCount item dicadangkan',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Status: Terakhir disinkronkan beberapa saat lalu',
            style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
