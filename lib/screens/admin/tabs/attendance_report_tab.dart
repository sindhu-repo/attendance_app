import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/file_saver.dart';
import '../../../widgets/glass_card.dart';
import '../admin_widgets.dart';

class AttendanceReportTab extends StatefulWidget {
  const AttendanceReportTab({super.key});

  @override
  State<AttendanceReportTab> createState() => _AttendanceReportTabState();
}

class _AttendanceReportTabState extends State<AttendanceReportTab> {
  static final _dateFmt = DateFormat('yyyy-MM-dd');
  static final _displayFmt = DateFormat('dd MMM yyyy');

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  final _filterCtrl = TextEditingController();

  @override
  void dispose() {
    _filterCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
        if (_startDate.isAfter(_endDate)) _startDate = _endDate;
      }
    });
  }

  void _search() {
    context.read<AdminProvider>().loadAttendanceReport(
          startDate: _dateFmt.format(_startDate),
          endDate: _dateFmt.format(_endDate),
          employeeQuery: _filterCtrl.text.trim().isEmpty
              ? null
              : _filterCtrl.text.trim(),
        );
  }

  Future<void> _exportToExcel(List<Map<String, dynamic>> records) async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Attendance'];
    sheet.appendRow([
      TextCellValue('Employee ID'),
      TextCellValue('Employee Name'),
      TextCellValue('Date'),
      TextCellValue('Sign In'),
      TextCellValue('Sign Out'),
    ]);
    for (final r in records) {
      sheet.appendRow([
        TextCellValue(r['employee_id']?.toString() ?? ''),
        TextCellValue(r['employee_name']?.toString() ?? ''),
        TextCellValue(r['attendance_date']?.toString() ?? ''),
        TextCellValue(r['sign_in_time']?.toString() ?? ''),
        TextCellValue(r['sign_out_time']?.toString() ?? '-'),
      ]);
    }
    final filename =
        'attendance_${_dateFmt.format(_startDate)}_to_${_dateFmt.format(_endDate)}.xlsx';
    final savedPath = await saveExcelFile(filename, workbook.encode()!);
    if (savedPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Saved to: $savedPath'),
        duration: const Duration(seconds: 6),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (_, p, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AdminDateTile(
                              label: 'From',
                              date: _displayFmt.format(_startDate),
                              onTap: () => _pickDate(true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AdminDateTile(
                              label: 'To',
                              date: _displayFmt.format(_endDate),
                              onTap: () => _pickDate(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _filterCtrl,
                        decoration: const InputDecoration(
                          labelText:
                              'Filter by name or Employee ID (optional)',
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AdminButton(
                              label: 'Search',
                              icon: Icons.search_rounded,
                              color: AppColors.admin,
                              isLoading: p.attendanceStatus ==
                                  AdminStatus.loading,
                              onPressed: _search,
                            ),
                          ),
                          if (p.attendanceStatus == AdminStatus.loaded &&
                              p.attendanceRecords.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            AdminButton(
                              label: 'Export',
                              icon: Icons.download_rounded,
                              color: AppColors.success,
                              onPressed: () =>
                                  _exportToExcel(p.attendanceRecords),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildResults(p)),
          ],
        );
      },
    );
  }

  Widget _buildResults(AdminProvider p) {
    switch (p.attendanceStatus) {
      case AdminStatus.idle:
        return const AdminEmptyHint(
            icon: Icons.search_rounded,
            message: 'Select a date range and tap Search');
      case AdminStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case AdminStatus.error:
        return AdminEmptyHint(
            icon: Icons.error_outline_rounded,
            message: p.attendanceError,
            isError: true);
      case AdminStatus.loaded:
        if (p.attendanceRecords.isEmpty) {
          return const AdminEmptyHint(
              icon: Icons.inbox_rounded,
              message: 'No records found for this period');
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GlassCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                      AppColors.admin.withAlpha(18)),
                  columnSpacing: 24,
                  dataRowMinHeight: 36,
                  dataRowMaxHeight: 40,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.admin,
                  ),
                  dataTextStyle: const TextStyle(
                      fontSize: 12, color: AppColors.textPrimary),
                  columns: const [
                    DataColumn(label: Text('EMP ID')),
                    DataColumn(label: Text('NAME')),
                    DataColumn(label: Text('DATE')),
                    DataColumn(label: Text('SIGN IN')),
                    DataColumn(label: Text('SIGN OUT')),
                  ],
                  rows: p.attendanceRecords.map((r) {
                    return DataRow(cells: [
                      DataCell(Text(r['employee_id']?.toString() ?? '')),
                      DataCell(Text(r['employee_name']?.toString() ?? '')),
                      DataCell(
                          Text(r['attendance_date']?.toString() ?? '')),
                      DataCell(Text(r['sign_in_time']?.toString() ?? '')),
                      DataCell(
                          Text(r['sign_out_time']?.toString() ?? '—')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        );
    }
  }
}
