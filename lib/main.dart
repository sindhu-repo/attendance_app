import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/employee_provider.dart';
import 'providers/visitor_provider.dart';
import 'services/powersync_database.dart';
import 'services/supabase_connector.dart';
import 'utils/app_config.dart';
import 'utils/app_theme.dart';
import 'utils/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qpssatisjoiqnxqzkstg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwc3NhdGlzam9pcW54cXprc3RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE5MjYyOTIsImV4cCI6MjA5NzUwMjI5Mn0.NP8RtLvHWvD4jH1cyiUrSJGn0TduqZwhQLB_XMVkluo',
  );

  if (!AppConfig.demoMode) {
    await openPowerSyncDatabase();
    try {
      if (Supabase.instance.client.auth.currentUser == null) {
        await Supabase.instance.client.auth.signInAnonymously();
      }
    } catch (e) {
      debugPrint('[Auth] sign-in failed (offline?): $e');
    }
    // Always connect — PowerSync returns null credentials gracefully when
    // no session exists and resumes sync once auth recovers.
    await powerSyncDb.connect(connector: SupabaseConnector());
  }

  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => VisitorProvider()),
      ],
      child: MaterialApp.router(
        title: 'Attendance Manager',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  
}


