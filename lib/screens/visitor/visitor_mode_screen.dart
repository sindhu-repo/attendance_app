import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';

class VisitorModeScreen extends StatelessWidget {
  const VisitorModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = Responsive.isCompact(context);
    final isWide = Responsive.isWide(context);

    final double cardH;
    if (isCompact) {
      cardH = (size.height - 96).clamp(140.0, 260.0);
    } else if (isWide) {
      cardH = (size.height * 0.42).clamp(220.0, 380.0);
    } else {
      cardH = (size.height * 0.62).clamp(300.0, 480.0);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppBackground(),
          SafeArea(
            child: Responsive.constrain(
              context,
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.hPad(context),
                  vertical: Responsive.vPad(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(compact: isCompact),
                    SizedBox(height: isCompact ? 10 : 18),
                    SizedBox(
                      height: cardH,
                      child: isWide
                          ? Row(
                              children: [
                                Expanded(
                                  child: _ModeCard(
                                    label: 'Check In',
                                    subtitle: 'Register your visit',
                                    icon: Icons.login_rounded,
                                    color: AppColors.success,
                                    onTap: () => context.go('/visitor/checkin'),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _ModeCard(
                                    label: 'Check Out',
                                    subtitle: 'End your visit',
                                    icon: Icons.logout_rounded,
                                    color: AppColors.signOut,
                                    onTap: () => context.go('/visitor/checkout'),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: _ModeCard(
                                    label: 'Check In',
                                    subtitle: 'Register your visit',
                                    icon: Icons.login_rounded,
                                    color: AppColors.success,
                                    onTap: () => context.go('/visitor/checkin'),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Expanded(
                                  child: _ModeCard(
                                    label: 'Check Out',
                                    subtitle: 'End your visit',
                                    icon: Icons.logout_rounded,
                                    color: AppColors.signOut,
                                    onTap: () => context.go('/visitor/checkout'),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Top bar
// ════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(160),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Colors.white.withAlpha(200), width: 1.2),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.textPrimary),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.tint(AppColors.visitor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.people_rounded,
              color: AppColors.visitor, size: compact ? 18 : 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Visitor',
                style: TextStyle(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!compact)
                const Text(
                  'Select an option to continue',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Mode card
// ════════════════════════════════════════════════════════════════════════════

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      onTap: onTap,
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
