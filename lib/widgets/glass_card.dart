import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Frosted-glass card.  Place it on top of [AppBackground] so the blur
/// composites against the colorful orbs beneath.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.radius = 20.0,
    this.padding,
    this.opacity = 0.78,
    this.sigma = 22.0,
    this.onTap,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double opacity;
  final double sigma;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppColors.glassShadow(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((opacity * 255).round()),
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: Colors.white.withAlpha(178), // ~70%
                    width: 1.5,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
