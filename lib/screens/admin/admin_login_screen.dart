import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_auth_provider.dart';
import '../../repositories/admin_repository.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _repo = AdminRepository();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await _repo.validateAdminCredentials(_passCtrl.text);
      if (!mounted) return;
      if (ok) {
        context.read<AdminAuthProvider>().authenticate();
        context.go('/admin');
      } else {
        setState(() {
          _loading = false;
          _error = 'Invalid password. Please try again.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Connection error. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscure,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    labelText: 'Admin Password',
                                    prefixIcon: const Icon(
                                        Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _login(),
                                  validator: (v) =>
                                      (v == null || v.isEmpty)
                                          ? 'Enter password'
                                          : null,
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 14),
                                  _ErrorRow(message: _error!),
                                ],
                                const SizedBox(height: 24),
                                GradientButton(
                                  label: 'Login',
                                  icon: Icons.login_rounded,
                                  color: AppColors.admin,
                                  isLoading: _loading,
                                  onPressed: _loading ? null : _login,
                                  height: 48,
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.tint(AppColors.admin),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.admin.withAlpha(60),
              width: 1.5,
            ),
          ),
          child: const Icon(Icons.admin_panel_settings_rounded,
              color: AppColors.admin, size: 38),
        ),
        const SizedBox(height: 18),
        const Text(
          'Admin Login',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter your admin password to access the dashboard',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE).withAlpha(220),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEF9A9A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFC62828), size: 16),
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
