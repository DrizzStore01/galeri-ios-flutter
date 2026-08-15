import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DateSectionHeader extends StatelessWidget {
  final String dateLabel;
  final VoidCallback? onSelectAll;
  final bool isSelecting;

  const DateSectionHeader({
    Key? key,
    required this.dateLabel,
    this.onSelectAll,
    this.isSelecting = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          if (isSelecting)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              child: const Text(
                'Pilih',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              onPressed: onSelectAll,
            ),
        ],
      ),
    );
  }
}
