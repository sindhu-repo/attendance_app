import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

class VisitorCheckInScreen extends StatefulWidget {
  const VisitorCheckInScreen({super.key});

  @override
  State<VisitorCheckInScreen> createState() => _VisitorCheckInScreenState();
}

class _VisitorCheckInScreenState extends State<VisitorCheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  String? _selectedEmployee;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitorProvider>().loadEmployees();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _purposeCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  void _goBack(VisitorProvider p) {
    p.resetCheckIn();
    context.go('/visitor');
  }

  Future<void> _submit(VisitorProvider p) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await p.checkIn(
      name: _nameCtrl.text,
      contactNumber: _contactCtrl.text,
      company: _companyCtrl.text,
      purpose: _purposeCtrl.text,
      meetEmployee: _selectedEmployee ?? '',
    );
    if (!mounted) return;

    if (ok) {
      p.resetCheckIn();
      context.go('/success', extra: AppStrings.visitorCheckInSuccess);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(p.errorMessage),
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
        final isWide = Responsive.isWide(context);
        final isCompact = Responsive.isCompact(context);

        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) provider.resetCheckIn();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: LoadingOverlay(
              isLoading: provider.isLoading,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const AppBackground(),
                  SafeArea(
                    child: Responsive.constrain(
                      context,
                      ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.hPad(context),
                            vertical: Responsive.vPad(context),
                          ),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _TopBar(
                                  onBack: () => _goBack(provider),
                                  compact: isCompact,
                                ),
                                SizedBox(height: isCompact ? 8 : 12),
                                isWide
                                    ? _WideLayout(
                                        nameCtrl: _nameCtrl,
                                        contactCtrl: _contactCtrl,
                                        companyCtrl: _companyCtrl,
                                        purposeCtrl: _purposeCtrl,
                                        provider: provider,
                                        selectedEmployee: _selectedEmployee,
                                        onEmployeeSelected: (v) =>
                                            setState(() => _selectedEmployee = v),
                                        onSubmit: () => _submit(provider),
                                      )
                                    : _NarrowLayout(
                                        nameCtrl: _nameCtrl,
                                        contactCtrl: _contactCtrl,
                                        companyCtrl: _companyCtrl,
                                        purposeCtrl: _purposeCtrl,
                                        provider: provider,
                                        selectedEmployee: _selectedEmployee,
                                        onEmployeeSelected: (v) =>
                                            setState(() => _selectedEmployee = v),
                                        onSubmit: () => _submit(provider),
                                      ),
                              ],
                            ),
                          ),
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
  const _TopBar({required this.onBack, required this.compact});
  final VoidCallback onBack;
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
            color: AppColors.tint(AppColors.visitor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.login_rounded,
              color: AppColors.visitor, size: compact ? 18 : 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Visitor Check In',
                style: TextStyle(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!compact)
                const Text(
                  'Fill in your details below',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Narrow layout
// ════════════════════════════════════════════════════════════════════════════

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.nameCtrl,
    required this.contactCtrl,
    required this.companyCtrl,
    required this.purposeCtrl,
    required this.provider,
    required this.selectedEmployee,
    required this.onEmployeeSelected,
    required this.onSubmit,
  });

  final TextEditingController nameCtrl;
  final TextEditingController contactCtrl;
  final TextEditingController companyCtrl;
  final TextEditingController purposeCtrl;
  final VisitorProvider provider;
  final String? selectedEmployee;
  final ValueChanged<String?> onEmployeeSelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: _FormFields(
          nameCtrl: nameCtrl,
          contactCtrl: contactCtrl,
          companyCtrl: companyCtrl,
          purposeCtrl: purposeCtrl,
          provider: provider,
          selectedEmployee: selectedEmployee,
          onEmployeeSelected: onEmployeeSelected,
          onSubmit: onSubmit,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Wide layout
// ════════════════════════════════════════════════════════════════════════════

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.nameCtrl,
    required this.contactCtrl,
    required this.companyCtrl,
    required this.purposeCtrl,
    required this.provider,
    required this.selectedEmployee,
    required this.onEmployeeSelected,
    required this.onSubmit,
  });

  final TextEditingController nameCtrl;
  final TextEditingController contactCtrl;
  final TextEditingController companyCtrl;
  final TextEditingController purposeCtrl;
  final VisitorProvider provider;
  final String? selectedEmployee;
  final ValueChanged<String?> onEmployeeSelected;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _FormFields(
          nameCtrl: nameCtrl,
          contactCtrl: contactCtrl,
          companyCtrl: companyCtrl,
          purposeCtrl: purposeCtrl,
          provider: provider,
          selectedEmployee: selectedEmployee,
          onEmployeeSelected: onEmployeeSelected,
          onSubmit: onSubmit,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Form fields (shared)
// ════════════════════════════════════════════════════════════════════════════

class _FormFields extends StatefulWidget {
  const _FormFields({
    required this.nameCtrl,
    required this.contactCtrl,
    required this.companyCtrl,
    required this.purposeCtrl,
    required this.provider,
    required this.selectedEmployee,
    required this.onEmployeeSelected,
    required this.onSubmit,
  });

  final TextEditingController nameCtrl;
  final TextEditingController contactCtrl;
  final TextEditingController companyCtrl;
  final TextEditingController purposeCtrl;
  final VisitorProvider provider;
  final String? selectedEmployee;
  final ValueChanged<String?> onEmployeeSelected;
  final VoidCallback onSubmit;

  @override
  State<_FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends State<_FormFields> {
  final _meetFocusNode = FocusNode();
  bool _meetFocused = false;

  @override
  void initState() {
    super.initState();
    _meetFocusNode.addListener(() {
      setState(() => _meetFocused = _meetFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _meetFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final names = widget.provider.employeeNames;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: widget.nameCtrl,
          label: 'Visitor Name',
          hint: 'Full name of the visitor',
          autofocus: true,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.person_outline_rounded),
          validator: AppValidators.visitorName,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: widget.contactCtrl,
          label: 'Mobile Number',
          hint: 'e.g. +91 9876543210',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.phone_outlined),
          validator: AppValidators.contactNumber,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: widget.companyCtrl,
          label: 'Company / Organization',
          hint: "Visitor's company or organization",
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.business_outlined),
          validator: null,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: widget.purposeCtrl,
          label: 'Purpose of Visit',
          hint: 'Why is the visitor here?',
          maxLines: 3,
          textInputAction: TextInputAction.done,
          prefixIcon: const Icon(Icons.notes_rounded),
          validator: AppValidators.purpose,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: widget.selectedEmployee,
          focusNode: _meetFocusNode,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Who are you meeting today?',
            prefixIcon: const Icon(Icons.badge_outlined),
            suffixIcon: widget.provider.loadingEmployees
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          hint: (_meetFocused && !widget.provider.loadingEmployees)
              ? const Text('Select an employee')
              : null,
          items: widget.provider.loadingEmployees
              ? null
              : names
                  .map((name) =>
                      DropdownMenuItem(value: name, child: Text(name)))
                  .toList(),
          onChanged:
              widget.provider.loadingEmployees ? null : widget.onEmployeeSelected,
          validator: (_) => (widget.selectedEmployee == null || widget.selectedEmployee!.isEmpty)
              ? 'Please select whom you are meeting'
              : null,
        ),
        if (widget.provider.checkInStatus == VisitorCheckInStatus.error) ...[
          const SizedBox(height: 14),
          _ErrorBanner(message: widget.provider.errorMessage),
        ],
        const SizedBox(height: 24),
        GradientButton(
          label: 'Check In',
          icon: Icons.login_rounded,
          color: AppColors.visitor,
          isLoading: widget.provider.isLoading,
          onPressed: widget.onSubmit,
          height: 44,
        ),
      ],
    );
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
