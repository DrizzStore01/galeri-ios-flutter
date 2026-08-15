import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T?> showIOSBottomSheet<T>({
  required BuildContext context,
  required List<IOSBottomSheetAction> actions,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => IOSBottomSheet(actions: actions),
  );
}

class IOSBottomSheetAction {
  final String label;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback onTap;

  IOSBottomSheetAction({
    required this.label,
    this.icon,
    this.isDestructive = false,
    required this.onTap,
  });
}

class IOSBottomSheet extends StatelessWidget {
  final List<IOSBottomSheetAction> actions;

  const IOSBottomSheet({Key? key, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.8),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey3,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      ...List.generate(actions.length, (index) {
                        final action = actions[index];
                        return Column(
                          children: [
                            if (index > 0)
                              const Divider(height: 1, indent: 0, color: CupertinoColors.separator),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (action.icon != null) ...[
                                    Icon(
                                      action.icon,
                                      color: action.isDestructive
                                          ? CupertinoColors.destructiveRed
                                          : CupertinoColors.activeBlue,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    action.label,
                                    style: TextStyle(
                                      color: action.isDestructive
                                          ? CupertinoColors.destructiveRed
                                          : CupertinoColors.activeBlue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                action.onTap();
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: double.infinity,
                  color: CupertinoColors.systemBackground.resolveFrom(context).withOpacity(0.8),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
