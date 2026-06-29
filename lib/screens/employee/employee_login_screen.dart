import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';

class EmployeeLoginScreen extends StatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _idCtrl.dispose();
    super.dispose();
  }

  void _goHome(EmployeeProvider p) {
    p.reset();
    context.go('/home');
  }

  Future<void> _verify(EmployeeProvider p) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await p.validateEmployee(_idCtrl.text.trim());
    // Admin stays on this screen to sign in/out first;
    // the "Open Admin Dashboard" button appears below once verified.
  }

  void _goToAdmin(EmployeeProvider p) {
    context.go('/admin-login');
  }

  Future<void> _signIn(EmployeeProvider p) async {
    final ok = await p.signIn();
    if (!mounted) return;
    if (ok) {
      p.reset();
      context.go('/success', extra: AppStrings.signInSuccess);
    } else {
      _showErrorBar(p.errorMessage);
    }
  }

  Future<void> _signOut(EmployeeProvider p) async {
    final ok = await p.signOut();
    if (!mounted) return;
    if (ok) {
      p.reset();
      context.go('/success', extra: AppStrings.signOutSuccess);
    } else {
      _showErrorBar(p.errorMessage);
    }
  }

  void _showErrorBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.signOut,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, provider, _) {
        final isVerified = provider.status == EmployeeStatus.verified;
        final isLoading = provider.status == EmployeeStatus.loading ||
            provider.isProcessing;
        final isWide = Responsive.isWide(context);
        final isCompact = Responsive.isCompact(context);

        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) provider.reset();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: LoadingOverlay(
              isLoading: isLoading,
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
                              onBack: isVerified
                                  ? () => provider.reset()
                                  : () => _goHome(provider),
                              compact: isCompact,
                              subtitle: isVerified
                                  ? 'Record your attendance for today'
                                  : 'Enter your name or Employee ID to continue',
                            ),
                            SizedBox(height: isCompact ? 12 : 28),
                            if (isVerified)
                              isWide
                                  ? _WideVerifiedView(
                                      provider: provider,
                                      now: _now,
                                      onSignIn: () => _signIn(provider),
                                      onSignOut: () => _signOut(provider),
                                      isCompact: isCompact,
                                      onAdminDashboard: provider.isAdmin
                                          ? () => _goToAdmin(provider)
                                          : null,
                                    )
                                  : _NarrowVerifiedView(
                                      provider: provider,
                                      now: _now,
                                      onSignIn: () => _signIn(provider),
                                      onSignOut: () => _signOut(provider),
                                      onAdminDashboard: provider.isAdmin
                                          ? () => _goToAdmin(provider)
                                          : null,
                                    )
                            else
                              isWide
                                  ? _WideLookupView(
                                      formKey: _formKey,
                                      idCtrl: _idCtrl,
                                      provider: provider,
                                      onVerify: () => _verify(provider),
                                      isCompact: isCompact,
                                    )
                                  : _NarrowLookupView(
                                      formKey: _formKey,
                                      idCtrl: _idCtrl,
                                      provider: provider,
                                      onVerify: () => _verify(provider),
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
//  Top bar — back button + page title
// ════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.compact, required this.subtitle});
  final VoidCallback onBack;
  final bool compact;
  final String subtitle;

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
            color: AppColors.tint(AppColors.employee),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.badge_rounded,
              color: AppColors.employee, size: compact ? 18 : 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Employee Check-In',
                style: TextStyle(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!compact)
                Text(
                  subtitle,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Lookup — narrow
// ════════════════════════════════════════════════════════════════════════════

class _NarrowLookupView extends StatelessWidget {
  const _NarrowLookupView({
    required this.formKey,
    required this.idCtrl,
    required this.provider,
    required this.onVerify,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController idCtrl;
  final EmployeeProvider provider;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: _LookupForm(
              idCtrl: idCtrl, provider: provider, onVerify: onVerify),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Lookup — wide
// ════════════════════════════════════════════════════════════════════════════

class _WideLookupView extends StatelessWidget {
  const _WideLookupView({
    required this.formKey,
    required this.idCtrl,
    required this.provider,
    required this.onVerify,
    required this.isCompact,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController idCtrl;
  final EmployeeProvider provider;
  final VoidCallback onVerify;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _LookupForm(
            idCtrl: idCtrl,
            provider: provider,
            onVerify: onVerify,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Verified — narrow
// ════════════════════════════════════════════════════════════════════════════

class _NarrowVerifiedView extends StatelessWidget {
  const _NarrowVerifiedView({
    required this.provider,
    required this.now,
    required this.onSignIn,
    required this.onSignOut,
    this.onAdminDashboard,
  });

  final EmployeeProvider provider;
  final DateTime now;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final VoidCallback? onAdminDashboard;

  @override
  Widget build(BuildContext context) => _VerifiedLayout(
        provider: provider,
        now: now,
        onSignIn: onSignIn,
        onSignOut: onSignOut,
        onAdminDashboard: onAdminDashboard,
      );
}

// ════════════════════════════════════════════════════════════════════════════
//  Verified — wide
// ════════════════════════════════════════════════════════════════════════════

class _WideVerifiedView extends StatelessWidget {
  const _WideVerifiedView({
    required this.provider,
    required this.now,
    required this.onSignIn,
    required this.onSignOut,
    required this.isCompact,
    this.onAdminDashboard,
  });

  final EmployeeProvider provider;
  final DateTime now;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final bool isCompact;
  final VoidCallback? onAdminDashboard;

  @override
  Widget build(BuildContext context) => _VerifiedLayout(
        provider: provider,
        now: now,
        onSignIn: onSignIn,
        onSignOut: onSignOut,
        onAdminDashboard: onAdminDashboard,
      );
}

// ════════════════════════════════════════════════════════════════════════════
//  Option B layout — hero card + 3 chips + action button
// ════════════════════════════════════════════════════════════════════════════

class _VerifiedLayout extends StatelessWidget {
  const _VerifiedLayout({
    required this.provider,
    required this.now,
    required this.onSignIn,
    required this.onSignOut,
    this.onAdminDashboard,
  });

  final EmployeeProvider provider;
  final DateTime now;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final VoidCallback? onAdminDashboard;

  @override
  Widget build(BuildContext context) {
    final att = provider.todayAttendance;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EmployeeCard(employee: provider.employee!),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Date + Time in one glass card with separator
              Expanded(
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _InfoChipContent(
                          icon: Icons.calendar_today_rounded,
                          label: 'Date',
                          value: DateFormat('MMM dd').format(now),
                          color: AppColors.employee,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                        ),
                        _InfoChipContent(
                          icon: Icons.access_time_rounded,
                          label: 'Time',
                          value: DateFormat('hh:mm:ss a').format(now),
                          color: AppColors.employee,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Right: Attendance record card
              Expanded(
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Today's Record",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _RecordRow(
                          icon: Icons.login_rounded,
                          label: att?.hasSignedIn == true
                              ? 'In:  ${att!.signInTime}'
                              : 'Not signed in',
                          color: att?.hasSignedIn == true
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        _RecordRow(
                          icon: Icons.logout_rounded,
                          label: att?.hasSignedOut == true
                              ? 'Out: ${att!.signOutTime}'
                              : 'Not signed out',
                          color: att?.hasSignedOut == true
                              ? AppColors.signOut
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ActionButton(provider: provider, onSignIn: onSignIn, onSignOut: onSignOut),
        if (onAdminDashboard != null) ...[
          const SizedBox(height: 10),
          GradientButton(
            label: 'Open Admin Dashboard',
            icon: Icons.admin_panel_settings_rounded,
            color: AppColors.admin,
            onPressed: onAdminDashboard,
            height: 44,
          ),
        ],
      ],
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Shared sub-widgets
// ════════════════════════════════════════════════════════════════════════════


// ── Lookup form ───────────────────────────────────────────────────────────

class _LookupForm extends StatefulWidget {
  const _LookupForm({
    required this.idCtrl,
    required this.provider,
    required this.onVerify,
  });

  final TextEditingController idCtrl;
  final EmployeeProvider provider;
  final VoidCallback onVerify;

  @override
  State<_LookupForm> createState() => _LookupFormState();
}

class _LookupFormState extends State<_LookupForm> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RawAutocomplete<Employee>(
          textEditingController: widget.idCtrl,
          focusNode: _focusNode,
          optionsBuilder: (TextEditingValue value) async {
            final query = value.text.trim();
            if (query.length < 2) return const [];
            try {
              return await widget.provider.searchEmployees(query);
            } catch (_) {
              return const [];
            }
          },
          displayStringForOption: (e) => e.employeeName,
          fieldViewBuilder: (_, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Employee Name or ID',
                hintText: 'Enter your name or Employee ID',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              autofocus: true,
              onFieldSubmitted: (_) => widget.onVerify(),
              validator: AppValidators.employeeName,
            );
          },
          optionsViewBuilder: (_, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.white,
                elevation: 6,
                borderRadius: BorderRadius.circular(14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 48),
                      itemBuilder: (context, index) {
                        final emp = options.elementAt(index);
                        return ListTile(
                          leading: const Icon(Icons.person_rounded,
                              color: AppColors.employee, size: 20),
                          title: Text(emp.employeeName,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary)),
                          subtitle: Text(emp.employeeId,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          dense: true,
                          onTap: () {
                            widget.provider.selectEmployee(emp);
                            onSelected(emp);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.provider.status == EmployeeStatus.error) ...[
          const SizedBox(height: 12),
          _ErrorBanner(message: widget.provider.errorMessage),
        ],
        const SizedBox(height: 22),
        GradientButton(
          label: AppStrings.verify,
          color: AppColors.employee,
          isLoading: widget.provider.status == EmployeeStatus.loading,
          onPressed: widget.onVerify,
          height: 44,
        ),
      ],
    );
  }
}

// ── Employee profile card (solid accent — intentional) ────────────────────

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee});
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.employee,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.buttonShadow(AppColors.employee),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withAlpha(55),
            child: Text(
              employee.employeeName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.employeeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (employee.department != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    employee.department!,
                    style: TextStyle(
                        color: Colors.white.withAlpha(215), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  'ID: ${employee.employeeId}',
                  style: TextStyle(
                      color: Colors.white.withAlpha(170), fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: Colors.white, size: 22),
        ],
      ),
    );
  }
}

// ── Info chip content (used inside a shared glass card) ───────────────────

class _InfoChipContent extends StatelessWidget {
  const _InfoChipContent({
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
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.provider,
    required this.onSignIn,
    required this.onSignOut,
  });

  final EmployeeProvider provider;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    if (provider.canSignIn) {
      return GradientButton(
        label: AppStrings.signIn,
        icon: Icons.login_rounded,
        color: AppColors.employee,
        isLoading: provider.isProcessing,
        onPressed: onSignIn,
        height: 44,
      );
    }
    if (provider.canSignOut) {
      return GradientButton(
        label: AppStrings.signOut,
        icon: Icons.logout_rounded,
        color: AppColors.signOut,
        isLoading: provider.isProcessing,
        onPressed: onSignOut,
        height: 44,
      );
    }
    return const _CompletedBanner();
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE).withAlpha(220),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEF9A9A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFC62828), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      color: Color(0xFFC62828), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5).withAlpha(220),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.success.withAlpha(100)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Complete',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You have signed in and signed out today.',
                      style: TextStyle(
                          color: AppColors.success.withAlpha(200),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
