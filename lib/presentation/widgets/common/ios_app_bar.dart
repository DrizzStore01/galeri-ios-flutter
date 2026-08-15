import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSAppBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool largeTitle;

  const IOSAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.trailing,
    this.largeTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (largeTitle) {
      return SliverPersistentHeader(
        pinned: true,
        delegate: _SliverIOSAppBarDelegate(
          title: title,
          leading: leading,
          trailing: trailing,
        ),
      );
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white.withOpacity(0.7),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 44,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.41,
                      ),
                    ),
                  ),
                  if (leading != null)
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(child: leading!),
                    ),
                  if (trailing != null)
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(child: trailing!),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44.0);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;
}

class _SliverIOSAppBarDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final Widget? leading;
  final Widget? trailing;

  _SliverIOSAppBarDelegate({
    required this.title,
    this.leading,
    this.trailing,
  });

  @override
  double get minExtent => 44.0 + MediaQueryData.fromWindow(window).padding.top;
  
  @override
  double get maxExtent => 96.0 + MediaQueryData.fromWindow(window).padding.top;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double opacity = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final double titleScale = 1.0 - (opacity * 0.3);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white.withOpacity(0.7 + (opacity * 0.2)),
          child: SafeArea(
            bottom: false,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (leading != null)
                  Positioned(
                    left: 8,
                    top: 0,
                    height: 44,
                    child: Center(child: leading!),
                  ),
                if (trailing != null)
                  Positioned(
                    right: 8,
                    top: 0,
                    height: 44,
                    child: Center(child: trailing!),
                  ),
                Positioned(
                  left: 16,
                  bottom: 8 + (opacity * 16),
                  child: Transform.scale(
                    scale: titleScale,
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.37,
                        color: Colors.black.withOpacity(1.0 - (opacity * 0.5)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 44,
                  child: Center(
                    child: Opacity(
                      opacity: opacity,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.41,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SliverIOSAppBarDelegate oldDelegate) {
    return title != oldDelegate.title ||
        leading != oldDelegate.leading ||
        trailing != oldDelegate.trailing;
  }
}
