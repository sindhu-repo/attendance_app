import 'package:flutter/material.dart';

/// Central helper for responsive layout decisions.
///
/// Breakpoints
/// ──────────────────────────────────────────────────
///  phone          : width < 600
///  tablet         : 600 ≤ width < 1024
///  desktop        : width ≥ 1024
///  compactHeight  : height < 500  (typical phone landscape)
class Responsive {
  Responsive._();

  static const double kTablet = 600;
  static const double kDesktop = 1024;
  static const double kCompactHeight = 500;

  // ── Size / orientation accessors ──────────────────────────────────────────

  static double width(BuildContext ctx) => MediaQuery.sizeOf(ctx).width;
  static double height(BuildContext ctx) => MediaQuery.sizeOf(ctx).height;
  static bool isPortrait(BuildContext ctx) =>
      MediaQuery.orientationOf(ctx) == Orientation.portrait;
  static bool isLandscape(BuildContext ctx) =>
      MediaQuery.orientationOf(ctx) == Orientation.landscape;

  // ── Form-factor booleans ─────────────────────────────────────────────────

  static bool isPhone(BuildContext ctx) => width(ctx) < kTablet;
  static bool isTablet(BuildContext ctx) =>
      width(ctx) >= kTablet && width(ctx) < kDesktop;
  static bool isDesktop(BuildContext ctx) => width(ctx) >= kDesktop;

  /// Tablet or larger — includes phones in landscape (width ≥ 600).
  static bool isWide(BuildContext ctx) => width(ctx) >= kTablet;

  /// Very limited vertical space — phone in landscape mode.
  static bool isCompact(BuildContext ctx) => height(ctx) < kCompactHeight;

  // ── Adaptive values ───────────────────────────────────────────────────────

  /// Horizontal padding scaled for the current screen width.
  static double hPad(BuildContext ctx) {
    final w = width(ctx);
    if (w >= kDesktop) return w * 0.12;
    if (w >= kTablet) return 40.0;
    return 20.0;
  }

  /// Vertical padding — reduced on compact-height screens.
  static double vPad(BuildContext ctx) => isCompact(ctx) ? 12.0 : 24.0;

  /// Max width for forms / content — prevents overly-wide lines on desktop.
  static double maxFormWidth(BuildContext ctx) {
    if (isDesktop(ctx)) return 880.0;
    if (isTablet(ctx)) return 680.0;
    return double.infinity;
  }

  /// Icon size for card/illustration icons.
  static double iconSize(BuildContext ctx) => isCompact(ctx) ? 40.0 : 56.0;

  /// Spacing between major vertical sections.
  static double sectionGap(BuildContext ctx) => isCompact(ctx) ? 12.0 : 24.0;

  // ── Layout helpers ────────────────────────────────────────────────────────

  /// Constrains [child] to [maxFormWidth] and centers it on wide screens.
  static Widget constrain(BuildContext ctx, Widget child) {
    final max = maxFormWidth(ctx);
    if (max == double.infinity) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
    );
  }

  /// Returns [two] when the screen is wide enough for a side-by-side layout,
  /// otherwise returns [one].
  static Widget oneOrTwo({
    required BuildContext ctx,
    required Widget one,
    required Widget two,
  }) =>
      isWide(ctx) ? two : one;
}
