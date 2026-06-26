import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_colors.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.65)),
    );
    _slide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2400), () {
        if (mounted) context.go('/home');
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 500;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppBackground(),
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, child) => Opacity(
                  opacity: _fade.value,
                  child: Transform.translate(
                    offset: Offset(0, _slide.value),
                    child: child,
                  ),
                ),
                child: isCompact
                    ? _LandscapeContent()
                    : _PortraitContent(isLarge: size.width >= 600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Portrait / tablet ─────────────────────────────────────────────────────────

class _PortraitContent extends StatelessWidget {
  const _PortraitContent({required this.isLarge});
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final logoSz = isLarge ? 148.0 : 120.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glass logo card
          GlassCard(
            radius: logoSz * 0.24,
            padding: EdgeInsets.all(logoSz * 0.24),
            child: Icon(
              Icons.business_center_rounded,
              size: logoSz * 0.50,
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: isLarge ? 40 : 28),
          // App name
          Text(
            'Attendance Manager',
            style: TextStyle(
              fontSize: isLarge ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Professional Attendance System',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          SpinKitFadingCircle(color: AppColors.accent, size: 36),
        ],
      ),
    );
  }
}

// ── Compact landscape ─────────────────────────────────────────────────────────

class _LandscapeContent extends StatelessWidget {
  const _LandscapeContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassCard(
            radius: 22,
            padding: const EdgeInsets.all(20),
            child: const Icon(Icons.business_center_rounded,
                size: 42, color: AppColors.accent),
          ),
          const SizedBox(width: 28),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attendance Manager',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Professional Attendance System',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              SpinKitFadingCircle(color: AppColors.accent, size: 28),
            ],
          ),
        ],
      ),
    );
  }
}
