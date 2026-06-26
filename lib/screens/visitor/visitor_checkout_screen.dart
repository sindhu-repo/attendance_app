import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/visitor_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';

class VisitorCheckOutScreen extends StatefulWidget {
  const VisitorCheckOutScreen({super.key});

  @override
  State<VisitorCheckOutScreen> createState() => _VisitorCheckOutScreenState();
}

class _VisitorCheckOutScreenState extends State<VisitorCheckOutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactCtrl = TextEditingController();

  @override
  void dispose() {
    _contactCtrl.dispose();
    super.dispose();
  }

  void _goBack(VisitorProvider p) {
    if (p.checkOutStatus == VisitorCheckOutStatus.found) {
      // Stay on screen, reset to lookup form
      p.resetCheckout();
    } else {
      p.resetCheckout();
      context.go('/visitor');
    }
  }

  Future<void> _lookup(VisitorProvider p) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await p.lookupVisitor(_contactCtrl.text.trim());
  }

  Future<void> _checkOut(VisitorProvider p) async {
    final ok = await p.checkOut();
    if (!mounted) return;
    if (ok) {
      p.resetCheckout();
      context.go('/success', extra: AppStrings.visitorCheckOutSuccess);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(p.checkOutError),
          backgroundColor: AppColors.signOut,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VisitorProvider>(
      builder: (context, provider, _) {
        final isCompact = Responsive.isCompact(context);
        final isFound =
            provider.checkOutStatus == VisitorCheckOutStatus.found;
        final isBusy =
            provider.checkOutStatus == VisitorCheckOutStatus.looking ||
                provider.checkOutStatus == VisitorCheckOutStatus.checkingOut;

        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) provider.resetCheckout();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: LoadingOverlay(
              isLoading: isBusy,
              child: Stack(
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
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TopBar(
                              onBack: () => _goBack(provider),
                              isFound: isFound,
                              compact: isCompact,
                            ),
                            SizedBox(height: isCompact ? 10 : 18),
                            isFound
                                ? _FoundCard(
                                    provider: provider,
                                    onCheckOut: () => _checkOut(provider),
                                    onRetry: () => provider.resetCheckout(),
                                  )
                                : Form(
                                    key: _formKey,
                                    child: _LookupCard(
                                      contactCtrl: _contactCtrl,
                                      provider: provider,
                                      onLookup: () => _lookup(provider),
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
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Top bar
// ════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onBack,
    required this.isFound,
    required this.compact,
  });
  final VoidCallback onBack;
  final bool isFound;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onBack,
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
            color: AppColors.tint(AppColors.signOut),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.logout_rounded,
              color: AppColors.signOut, size: compact ? 18 : 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Visitor Check Out',
                style: TextStyle(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!compact)
                Text(
                  isFound
                      ? 'Confirm your check out below'
                      : 'Enter your mobile number to check out',
                  style: const TextStyle(
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
//  Lookup card — phone entry
// ════════════════════════════════════════════════════════════════════════════

class _LookupCard extends StatelessWidget {
  const _LookupCard({
    required this.contactCtrl,
    required this.provider,
    required this.onLookup,
  });

  final TextEditingController contactCtrl;
  final VisitorProvider provider;
  final VoidCallback onLookup;

  @override
  Widget build(BuildContext context) {
    final isNotFound =
        provider.checkOutStatus == VisitorCheckOutStatus.notFound;
    final isError = provider.checkOutStatus == VisitorCheckOutStatus.error;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: contactCtrl,
              label: 'Mobile Number',
              hint: 'Enter the number used during check-in',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofocus: true,
              prefixIcon: const Icon(Icons.phone_outlined),
              validator: AppValidators.contactNumber,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onEditingComplete: onLookup,
            ),
            if (isNotFound) ...[
              const SizedBox(height: 12),
              _Banner(
                message:
                    'No active check-in found for this number. Please verify and try again.',
                icon: Icons.search_off_rounded,
                color: AppColors.signOut,
              ),
            ],
            if (isError) ...[
              const SizedBox(height: 12),
              _Banner(
                message: provider.checkOutError,
                icon: Icons.error_outline_rounded,
                color: AppColors.signOut,
              ),
            ],
            const SizedBox(height: 20),
            GradientButton(
              label: 'Look Up',
              icon: Icons.search_rounded,
              color: AppColors.visitor,
              isLoading:
                  provider.checkOutStatus == VisitorCheckOutStatus.looking,
              onPressed: onLookup,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Found card — visitor details + check out button
// ════════════════════════════════════════════════════════════════════════════

class _FoundCard extends StatelessWidget {
  const _FoundCard({
    required this.provider,
    required this.onCheckOut,
    required this.onRetry,
  });

  final VisitorProvider provider;
  final VoidCallback onCheckOut;
  final VoidCallback onRetry;

  String _fmtTime(String raw) {
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = provider.foundVisitor!;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Visitor hero ───────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.tint(AppColors.visitor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppColors.visitor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.visitorName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (v.company.isNotEmpty)
                        Text(
                          v.company,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            // ── Details ────────────────────────────────────────────────────
            if (v.checkInTime != null)
              _DetailRow(
                icon: Icons.login_rounded,
                label: 'Checked in',
                value: _fmtTime(v.checkInTime!),
                color: AppColors.success,
              ),
            if (v.meetEmployee.isNotEmpty) ...[
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.badge_outlined,
                label: 'Meeting',
                value: v.meetEmployee,
                color: AppColors.visitor,
              ),
            ],
            if (v.purpose.isNotEmpty) ...[
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.notes_rounded,
                label: 'Purpose',
                value: v.purpose,
                color: AppColors.visitor,
              ),
            ],
            const SizedBox(height: 20),
            GradientButton(
              label: 'Check Out',
              icon: Icons.logout_rounded,
              color: AppColors.signOut,
              isLoading: provider.checkOutStatus ==
                  VisitorCheckOutStatus.checkingOut,
              onPressed: onCheckOut,
              height: 44,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: onRetry,
                child: const Text(
                  'Not you? Try a different number',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Shared sub-widgets
// ════════════════════════════════════════════════════════════════════════════

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textPrimary),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.message,
    required this.icon,
    required this.color,
  });
  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bg = Color.lerp(color, Colors.white, 0.88)!;
    final border = Color.lerp(color, Colors.white, 0.55)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg.withAlpha(220),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: color, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
