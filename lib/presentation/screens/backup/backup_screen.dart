import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _backupEnabled = false;
  bool _wifiOnly = true;
  bool _includeVideos = true;
  bool _includeRaw = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS secondary background
      appBar: const CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        border: null,
        middle: Text('Cadangan'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildGroup(
            children: [
              _buildSwitchRow('Cadangan Otomatis', _backupEnabled, (val) {
                setState(() => _backupEnabled = val);
              }),
            ],
          ),
          if (_backupEnabled) ...[
            const SizedBox(height: 20),
            _buildStatusCard(),
            const SizedBox(height: 20),
            _buildGroup(
              children: [
                _buildSwitchRow('Hanya via WiFi', _wifiOnly, (val) => setState(() => _wifiOnly = val)),
                const Divider(height: 1, indent: 16),
                _buildSwitchRow('Sertakan Video', _includeVideos, (val) => setState(() => _includeVideos = val)),
                const Divider(height: 1, indent: 16),
                _buildSwitchRow('Sertakan File RAW', _includeRaw, (val) => setState(() => _includeRaw = val)),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton.filled(
                child: const Text('Cadangkan Sekarang'),
                onPressed: () {},
              ),
            ),
          ],
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Koneksi ke Google Photos / iCloud coming soon',
              textAlign: TextAlign.center,
              style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 17)),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: 0.65,
                  strokeWidth: 8,
                  backgroundColor: CupertinoColors.systemGrey5,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const Text('65%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('1,245 / 1,912 foto dicadangkan', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text('Total ukuran: 4.2 GB', style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 13)),
          const Text('Terakhir: Hari ini 10:42', style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 13)),
        ],
      ),
    );
  }
}
