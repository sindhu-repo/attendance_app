import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../utils/app_colors.dart';
import '../utils/app_config.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < Responsive.kCompactHeight;
    final isWide = size.width >= Responsive.kTablet;

    if (isCompact) return _CompactLandscapeHome(size: size);
    if (isWide) return _WideHome(size: size);
    return const _PortraitPhoneHome();
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  1.  Phone landscape
// ════════════════════════════════════════════════════════════════════════════

class _CompactLandscapeHome extends StatelessWidget {
  const _CompactLandscapeHome({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    final cardH = (size.height - 96).clamp(160.0, 320.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Column(
                children: [
                  const _CompactHeader(),
                  if (AppConfig.demoMode) ...[
                    const SizedBox(height: 8),
                    const _DemoBanner(compact: true),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    height: cardH,
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModuleCard(
                            label: 'Employee',
                            subtitle: 'Sign In / Sign Out',
                            icon: Icons.badge_rounded,
                            route: '/employee',
                            color: AppColors.employee,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ModuleCard(
                            label: 'Visitor',
                            subtitle: 'Check In / Check Out',
                            icon: Icons.people_rounded,
                            route: '/visitor',
                            color: AppColors.visitor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  2.  Tablet / desktop
// ════════════════════════════════════════════════════════════════════════════

class _WideHome extends StatelessWidget {
  const _WideHome({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    final isDesktop = size.width >= Responsive.kDesktop;
    final hPad = isDesktop ? size.width * 0.10 : 40.0;
    final cardH = (size.height * 0.40).clamp(220.0, 380.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  const _FullHeader(),
                  const SizedBox(height: 20),
                  if (AppConfig.demoMode) ...[
                    const _DemoBanner(),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    height: cardH,
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModuleCard(
                            label: 'Employee',
                            subtitle: 'Sign In / Sign Out',
                            icon: Icons.badge_rounded,
                            route: '/employee',
                            color: AppColors.employee,
                          ),
                        ),
                        SizedBox(width: isDesktop ? 32 : 24),
                        Expanded(
                          child: _ModuleCard(
                            label: 'Visitor',
                            subtitle: 'Check In / Check Out',
                            icon: Icons.people_rounded,
                            route: '/visitor',
                            color: AppColors.visitor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  3.  Phone portrait
// ════════════════════════════════════════════════════════════════════════════

class _PortraitPhoneHome extends StatelessWidget {
  const _PortraitPhoneHome();

  @override
  Widget build(BuildContext context) {
    final cardH = (MediaQuery.sizeOf(context).height * 0.34).clamp(180.0, 280.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  const _FullHeader(),
                  const SizedBox(height: 20),
                  if (AppConfig.demoMode) ...[
                    const _DemoBanner(),
                    const SizedBox(height: 14),
                  ],
                  SizedBox(
                    height: cardH,
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModuleCard(
                            label: 'Employee',
                            subtitle: 'Sign In / Sign Out',
                            icon: Icons.badge_rounded,
                            route: '/employee',
                            color: AppColors.employee,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ModuleCard(
                            label: 'Visitor',
                            subtitle: 'Check In / Check Out',
                            icon: Icons.people_rounded,
                            route: '/visitor',
                            color: AppColors.visitor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Shared sub-widgets
// ════════════════════════════════════════════════════════════════════════════

// ── Full header (portrait / wide) ─────────────────────────────────────────

class _FullHeader extends StatefulWidget {
  const _FullHeader();

  @override
  State<_FullHeader> createState() => _FullHeaderState();
}

class _FullHeaderState extends State<_FullHeader> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _greeting() {
    final h = _now.hour;
    if (h < 12) return 'Good Morning!';
    if (h < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, MMMM d, yyyy').format(_now);
    final clock = DateFormat('HH:mm:ss').format(_now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.business_center_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              AppStrings.appName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          _greeting(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        // ── Live clock ──────────────────────────────────────────────────────
        Text(
          clock,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Compact header (landscape) ────────────────────────────────────────────

class _CompactHeader extends StatelessWidget {
  const _CompactHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.business_center_rounded,
            color: AppColors.accent, size: 20),
        const SizedBox(width: 8),
        Text(
          AppStrings.appName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
        const Spacer(),
        Text(
          DateFormat('EEE, MMM d').format(DateTime.now()),
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Demo banner ───────────────────────────────────────────────────────────

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 14, vertical: compact ? 8 : 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7).withAlpha(210),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFFFCD34D).withAlpha(180), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: Color(0xFFB45309), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  compact
                      ? 'Demo Mode active — no real DB connected.'
                      : 'Demo Mode — running with mock data. '
                          'Set AppConfig.demoMode = false when your database is ready.',
                  style: const TextStyle(
                      color: Color(0xFFB45309), fontSize: 12),
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Module card ────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      onTap: () => context.go(route),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final compact = constraints.maxHeight < 200;
          final iconBoxPad = compact ? 10.0 : 18.0;
          final iconSz = compact ? 28.0 : 44.0;

          return Padding(
            padding: EdgeInsets.all(compact ? 14.0 : 26.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tinted icon container
                Container(
                  padding: EdgeInsets.all(iconBoxPad),
                  decoration: BoxDecoration(
                    color: AppColors.tint(color),
                    borderRadius:
                        BorderRadius.circular(compact ? 14 : 18),
                  ),
                  child: Icon(icon, size: iconSz, color: color),
                ),
                SizedBox(height: compact ? 8 : 14),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: compact ? 16.0 : 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!compact) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
