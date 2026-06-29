import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/employee.dart';
import '../../../providers/admin_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../admin_widgets.dart';

class EmployeeManagementTab extends StatefulWidget {
  const EmployeeManagementTab({super.key});

  @override
  State<EmployeeManagementTab> createState() => _EmployeeManagementTabState();
}

class _EmployeeManagementTabState extends State<EmployeeManagementTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadEmployees();
    });
  }

  void _showDialog(AdminProvider p, Employee? existing) {
    showDialog(
      context: context,
      builder: (_) => _EmployeeDialog(
        existing: existing,
        onSave: (id, name, dept, desig, role, email, mobile) async {
          final ok = existing == null
              ? await p.addEmployee(
                  employeeId: id,
                  employeeName: name,
                  department: dept,
                  designation: desig,
                  role: role,
                  email: email,
                  mobileNumber: mobile,
                )
              : await p.updateEmployee(
                  originalId: existing.employeeId,
                  employeeId: id,
                  employeeName: name,
                  department: dept,
                  designation: desig,
                  role: role,
                  email: email,
                  mobileNumber: mobile,
                );
          if (!ok && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(p.employeeError),
              backgroundColor: AppColors.signOut,
            ));
          }
          return ok;
        },
      ),
    );
  }

  void _confirmDelete(AdminProvider p, Employee emp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
            'Delete "${emp.employeeName}" (${emp.employeeId})?\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await p.deleteEmployee(emp.employeeId);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(p.employeeError),
                  backgroundColor: AppColors.signOut,
                ));
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.signOut)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (_, p, _) {
        return Stack(
          children: [
            _buildContent(p),
            Positioned(
              right: 24,
              bottom: 24,
              child: FloatingActionButton(
                onPressed: () => _showDialog(p, null),
                backgroundColor: AppColors.admin,
                foregroundColor: Colors.white,
                tooltip: 'Add Employee',
                child: const Icon(Icons.add_rounded),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(AdminProvider p) {
    switch (p.employeeStatus) {
      case AdminStatus.idle:
      case AdminStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case AdminStatus.error:
        return AdminEmptyHint(
            icon: Icons.error_outline_rounded,
            message: p.employeeError,
            isError: true);
      case AdminStatus.loaded:
        if (p.employees.isEmpty) {
          return const AdminEmptyHint(
              icon: Icons.people_outline_rounded,
              message: 'No employees found.\nTap + to add one.');
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
          itemCount: p.employees.length,
          itemBuilder: (_, i) {
            final emp = p.employees[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.tint(
                            emp.isAdmin ? AppColors.admin : AppColors.employee),
                        child: Text(
                          emp.employeeName[0].toUpperCase(),
                          style: TextStyle(
                            color: emp.isAdmin
                                ? AppColors.admin
                                : AppColors.employee,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    emp.employeeName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (emp.isAdmin) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.tint(AppColors.admin),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Admin',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.admin,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              [
                                emp.employeeId,
                                if (emp.department != null) emp.department!,
                              ].join(' · '),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        color: AppColors.textSecondary,
                        tooltip: 'Edit',
                        onPressed: () =>
                            _showDialog(context.read<AdminProvider>(), emp),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, size: 18),
                        color: AppColors.signOut,
                        tooltip: 'Delete',
                        onPressed: () =>
                            _confirmDelete(context.read<AdminProvider>(), emp),
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
}

// ── Add / Edit dialog ─────────────────────────────────────────────────────────

class _EmployeeDialog extends StatefulWidget {
  const _EmployeeDialog({this.existing, required this.onSave});
  final Employee? existing;
  final Future<bool> Function(
      String id, String name, String? dept, String? desig, String role,
      String? email, String? mobile) onSave;

  @override
  State<_EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<_EmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _idCtrl =
      TextEditingController(text: widget.existing?.employeeId ?? '');
  late final _firstNameCtrl = TextEditingController(
      text: widget.existing != null
          ? _splitName(widget.existing!.employeeName).first
          : '');
  late final _lastNameCtrl = TextEditingController(
      text: widget.existing != null
          ? _splitName(widget.existing!.employeeName).last
          : '');
  late final _deptCtrl =
      TextEditingController(text: widget.existing?.department ?? '');
  late final _desigCtrl =
      TextEditingController(text: widget.existing?.designation ?? '');
  late final _emailCtrl =
      TextEditingController(text: widget.existing?.email ?? '');
  late final _mobileCtrl =
      TextEditingController(text: widget.existing?.mobileNumber ?? '');
  late String _role = widget.existing?.role ?? 'employee';
  bool _saving = false;

  static ({String first, String last}) _splitName(String fullName) {
    final parts = fullName.trim().split(' ');
    final first = parts.first;
    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    return (first: first, last: last);
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _deptCtrl.dispose();
    _desigCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final fullName = lastName.isEmpty ? firstName : '$firstName $lastName';
    final ok = await widget.onSave(
      _idCtrl.text.trim(),
      fullName,
      _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
      _desigCtrl.text.trim().isEmpty ? null : _desigCtrl.text.trim(),
      _role,
      _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      _mobileCtrl.text.trim().isEmpty ? null : _mobileCtrl.text.trim(),
    );
    if (ok && mounted) Navigator.of(context).pop();
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Employee' : 'Edit Employee'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration:
                    const InputDecoration(labelText: 'Role', isDense: true),
                items: const [
                  DropdownMenuItem(
                      value: 'employee', child: Text('Employee')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'employee'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idCtrl,
                decoration: const InputDecoration(
                  labelText: 'Employee ID *',
                  isDense: true,
                ),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'First Name *', isDense: true),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Last Name *', isDense: true),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                    labelText: 'Email', isDense: true),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) return null;
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(val)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mobileCtrl,
                decoration: const InputDecoration(
                    labelText: 'Mobile Number', isDense: true),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) return null;
                  if (!RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(val)) {
                    return 'Enter a valid mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deptCtrl,
                decoration:
                    const InputDecoration(labelText: 'Department', isDense: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desigCtrl,
                decoration:
                    const InputDecoration(labelText: 'Designation', isDense: true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AdminButton(
          label: 'Save',
          icon: Icons.check_rounded,
          color: AppColors.admin,
          isLoading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }
}
