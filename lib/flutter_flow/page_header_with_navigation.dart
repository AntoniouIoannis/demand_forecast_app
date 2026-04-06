import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Reusable header with back button (left) and home button (right)
class PageHeaderWithNavigation extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onHomePressed;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;

  const PageHeaderWithNavigation({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.onHomePressed,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0.0,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? FlutterFlowTheme.of(context).primary;
    final textColor = titleColor ?? FlutterFlowTheme.of(context).info;

    return AppBar(
      backgroundColor: bgColor,
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: textColor),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title,
        style: FlutterFlowTheme.of(context).headlineSmall.override(
              fontFamily: 'Inter Tight',
              color: textColor,
            ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.home, color: textColor),
          onPressed: onHomePressed ??
              () {
                context.goNamed('HomePage');
              },
        ),
      ],
    );
  }
}
