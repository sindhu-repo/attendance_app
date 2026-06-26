import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Full-width solid button.  Pass [color] for the background tint.
/// Renders as a high-contrast block that stands out against glass cards.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.color,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = AppDimensions.buttonHeight,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: enabled ? color : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled ? AppColors.buttonShadow(color) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white24,
          highlightColor: Colors.white12,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
