import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/file_saver.dart';
import '../../../widgets/glass_card.dart';
import '../admin_widgets.dart';

class VisitorReportTab extends StatefulWidget {
  const VisitorReportTab({super.key});

  @override
  State<VisitorReportTab> createState() => _VisitorReportTabState();
}

class _VisitorReportTabState extends State<VisitorReportTab> {
  static final _dateFmt = DateFormat('yyyy-MM-dd');
  static final _displayFmt = DateFormat('dd MMM yyyy');

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

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
    context.read<AdminProvider>().loadVisitorReport(
          startDate: _dateFmt.format(_startDate),
          endDate: _dateFmt.format(_endDate),
        );
  }

  Future<void> _exportToExcel(List<Map<String, dynamic>> records) async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Visitors'];
    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Contact'),
      TextCellValue('Company'),
      TextCellValue('Purpose'),
      TextCellValue('Meeting'),
      TextCellValue('Date'),
      TextCellValue('Check In'),
      TextCellValue('Check Out'),
    ]);
    for (final r in records) {
      sheet.appendRow([
        TextCellValue(r['visitor_name']?.toString() ?? ''),
        TextCellValue(r['contact_number']?.toString() ?? ''),
        TextCellValue(r['company']?.toString() ?? ''),
        TextCellValue(r['purpose']?.toString() ?? ''),
        TextCellValue(r['meet_employee']?.toString() ?? ''),
        TextCellValue(r['visit_date']?.toString() ?? ''),
        TextCellValue(r['check_in_time']?.toString() ?? ''),
        TextCellValue(r['check_out_time']?.toString() ?? '-'),
      ]);
    }
    final filename =
        'visitors_${_dateFmt.format(_startDate)}_to_${_dateFmt.format(_endDate)}.xlsx';
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AdminButton(
                              label: 'Search',
                              icon: Icons.search_rounded,
                              color: AppColors.admin,
                              isLoading:
                                  p.visitorStatus == AdminStatus.loading,
                              onPressed: _search,
                            ),
                          ),
                          if (p.visitorStatus == AdminStatus.loaded &&
                              p.visitorRecords.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            AdminButton(
                              label: 'Export',
                              icon: Icons.download_rounded,
                              color: AppColors.success,
                              onPressed: () =>
                                  _exportToExcel(p.visitorRecords),
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
    switch (p.visitorStatus) {
      case AdminStatus.idle:
        return const AdminEmptyHint(
            icon: Icons.search_rounded,
            message: 'Select a date range and tap Search');
      case AdminStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case AdminStatus.error:
        return AdminEmptyHint(
            icon: Icons.error_outline_rounded,
            message: p.visitorError,
            isError: true);
      case AdminStatus.loaded:
        if (p.visitorRecords.isEmpty) {
          return const AdminEmptyHint(
              icon: Icons.inbox_rounded,
              message: 'No visitor records for this period');
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
                  columnSpacing: 20,
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
                    DataColumn(label: Text('NAME')),
                    DataColumn(label: Text('CONTACT')),
                    DataColumn(label: Text('COMPANY')),
                    DataColumn(label: Text('PURPOSE')),
                    DataColumn(label: Text('MEETING')),
                    DataColumn(label: Text('DATE')),
                    DataColumn(label: Text('IN')),
                    DataColumn(label: Text('OUT')),
                  ],
                  rows: p.visitorRecords.map((r) {
                    return DataRow(cells: [
                      DataCell(Text(r['visitor_name']?.toString() ?? '')),
                      DataCell(
                          Text(r['contact_number']?.toString() ?? '')),
                      DataCell(Text(r['company']?.toString() ?? '')),
                      DataCell(Text(r['purpose']?.toString() ?? '')),
                      DataCell(
                          Text(r['meet_employee']?.toString() ?? '')),
                      DataCell(Text(r['visit_date']?.toString() ?? '')),
                      DataCell(Text(r['check_in_time']?.toString() ?? '')),
                      DataCell(
                          Text(r['check_out_time']?.toString() ?? '—')),
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
