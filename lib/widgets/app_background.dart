import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Full-screen background used on every screen.
/// Renders a soft blue-white gradient with three blurred color orbs for depth.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        // ── Base gradient ──────────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFEEF2FF), // Indigo-50
                Color(0xFFF5F8FF), // soft blue-white
                Color(0xFFFFFFFF), // white
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),

        // ── Top-left orb (indigo) ──────────────────────────────────────────
        Positioned(
          top: -size.height * 0.20,
          left: -size.width * 0.25,
          child: _Orb(
            diameter: size.width * 0.90,
            color: AppColors.orb1,
            opacity: 0.17,
            blur: 90,
          ),
        ),

        // ── Bottom-right orb (blue) ────────────────────────────────────────
        Positioned(
          bottom: -size.height * 0.18,
          right: -size.width * 0.20,
          child: _Orb(
            diameter: size.width * 1.0,
            color: AppColors.orb2,
            opacity: 0.12,
            blur: 90,
          ),
        ),

        // ── Mid-right orb (cyan) ───────────────────────────────────────────
        Positioned(
          top: size.height * 0.33,
          right: -size.width * 0.15,
          child: _Orb(
            diameter: size.width * 0.60,
            color: AppColors.orb3,
            opacity: 0.09,
            blur: 70,
          ),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.diameter,
    required this.color,
    required this.opacity,
    required this.blur,
  });

  final double diameter;
  final Color color;
  final double opacity;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha((opacity * 255).round()),
        ),
      ),
    );
  }
}
