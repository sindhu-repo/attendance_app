import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_colors.dart';
import '../utils/responsive.dart';
import '../widgets/app_background.dart';

/// Full-screen success animation. Auto-navigates to home after 3 s.
class SuccessScreen extends StatefulWidget {
  final String message;
  const SuccessScreen({super.key, required this.message});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalMs = 3000;

  late final AnimationController _ctrl;

  late final Animation<double> _bgFade;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _circleScale;
  late final Animation<double> _checkProgress;
  late final Animation<double> _textFade;
  late final Animation<double> _textSlide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _bgFade = _curve(0.00, 0.14);

    _ringScale = Tween<double>(begin: 0.55, end: 1.55)
        .animate(_interval(0.06, 0.48, curve: Curves.easeOut));
    _ringOpacity =
        Tween<double>(begin: 0.55, end: 0).animate(_interval(0.06, 0.48));

    _circleScale = Tween<double>(begin: 0, end: 1)
        .animate(_interval(0.08, 0.46, curve: Curves.elasticOut));

    _checkProgress = Tween<double>(begin: 0, end: 1)
        .animate(_interval(0.42, 0.74, curve: Curves.easeInOut));

    _textFade = _curve(0.65, 0.92);
    _textSlide = Tween<double>(begin: 22, end: 0)
        .animate(_interval(0.65, 0.92, curve: Curves.easeOut));

    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: _totalMs), () {
        if (mounted) context.go('/home');
      });
    });
  }

  CurvedAnimation _interval(double begin, double end,
          {Curve curve = Curves.easeInOut}) =>
      CurvedAnimation(
          parent: _ctrl, curve: Interval(begin, end, curve: curve));

  Animation<double> _curve(double begin, double end) =>
      Tween<double>(begin: 0, end: 1).animate(_interval(begin, end));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);
    final isCompact = Responsive.isCompact(context);
    final circleSize = isCompact ? 100.0 : isWide ? 164.0 : 132.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const AppBackground(),
            FadeTransition(
              opacity: _bgFade,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Animated circle + checkmark ──────────────────
                      AnimatedBuilder(
                        animation: _ctrl,
                        builder: (_, _) => SizedBox(
                          width: circleSize * 1.6,
                          height: circleSize * 1.6,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ripple ring
                              Transform.scale(
                                scale: _ringScale.value,
                                child: Opacity(
                                  opacity: _ringOpacity.value,
                                  child: Container(
                                    width: circleSize,
                                    height: circleSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.success, width: 3),
                                    ),
                                  ),
                                ),
                              ),
                              // Main solid circle
                              Transform.scale(
                                scale: _circleScale.value,
                                child: Container(
                                  width: circleSize,
                                  height: circleSize,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    boxShadow: AppColors.buttonShadow(
                                        AppColors.success),
                                  ),
                                  child: CustomPaint(
                                    painter: _CheckmarkPainter(
                                      progress: _checkProgress.value,
                                      strokeWidth: circleSize * 0.075,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isCompact ? 16 : 28),

                      // ── Text ─────────────────────────────────────────
                      AnimatedBuilder(
                        animation: _ctrl,
                        builder: (_, _) => Opacity(
                          opacity: _textFade.value,
                          child: Transform.translate(
                            offset: Offset(0, _textSlide.value),
                            child: Column(
                              children: [
                                Text(
                                  widget.message,
                                  style: (isWide
                                          ? Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                          : Theme.of(context)
                                              .textTheme
                                              .headlineSmall)
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'All done',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ── Checkmark painter ─────────────────────────────────────────────────────────

class _CheckmarkPainter extends CustomPainter {
  const _CheckmarkPainter({required this.progress, required this.strokeWidth});
  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final p0 = Offset(size.width * 0.22, size.height * 0.52);
    final p1 = Offset(size.width * 0.43, size.height * 0.70);
    final p2 = Offset(size.width * 0.79, size.height * 0.31);

    final seg1 = (p1 - p0).distance;
    final seg2 = (p2 - p1).distance;
    final drawn = (seg1 + seg2) * progress;

    final path = Path()..moveTo(p0.dx, p0.dy);
    if (drawn <= seg1) {
      final pt = Offset.lerp(p0, p1, drawn / seg1)!;
      path.lineTo(pt.dx, pt.dy);
    } else {
      path.lineTo(p1.dx, p1.dy);
      final t = ((drawn - seg1) / seg2).clamp(0.0, 1.0);
      final pt = Offset.lerp(p1, p2, t)!;
      path.lineTo(pt.dx, pt.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) =>
      old.progress != progress || old.strokeWidth != strokeWidth;
}
