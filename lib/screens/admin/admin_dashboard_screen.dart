import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/employee_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_background.dart';
import 'tabs/attendance_report_tab.dart';
import 'tabs/employee_management_tab.dart';
import 'tabs/visitor_report_tab.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String adminName;
  const AdminDashboardScreen({super.key, required this.adminName});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.read<EmployeeProvider>().reset();
          context.go('/employee');
        }
      },
      child: ChangeNotifierProvider(
        create: (_) => AdminProvider(),
        child: _AdminDashboardContent(adminName: adminName),
      ),
    );
  }
}

class _AdminDashboardContent extends StatefulWidget {
  final String adminName;
  const _AdminDashboardContent({required this.adminName});

  @override
  State<_AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<_AdminDashboardContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 8),
                _buildTabBar(),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      AttendanceReportTab(),
                      EmployeeManagementTab(),
                      VisitorReportTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.tint(AppColors.admin),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: AppColors.admin, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  widget.adminName,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go('/employee'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(160),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.white.withAlpha(200), width: 1.2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded,
                        size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text('Exit',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withAlpha(230), width: 1.5),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.admin,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              indicator: BoxDecoration(
                color: AppColors.admin.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                    icon: Icon(Icons.bar_chart_rounded, size: 18),
                    text: 'Attendance Reports'),
                Tab(
                    icon: Icon(Icons.people_rounded, size: 18),
                    text: 'Employee Management'),
                Tab(
                    icon: Icon(Icons.person_pin_rounded, size: 18),
                    text: 'Visitor Reports'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
