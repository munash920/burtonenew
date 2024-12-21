import 'package:flutter/material.dart';

class NotionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool hover;

  const NotionCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.hover = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);
    final hoverColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: hover ? hoverColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor ?? defaultBgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
