import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attendance.dart';
import '../services/demo_store.dart';
import '../utils/app_config.dart';

class AttendanceRepository {
  final _db = Supabase.instance.client;
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  static String _localTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String _localTimestamp(DateTime dt) =>
      DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt);

  Future<Attendance?> getTodayAttendance(String employeeId) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      return DemoStore.getTodayAttendance(employeeId);
    }
    final today = _dateFmt.format(DateTime.now());
    final rows = await _db
        .from('attendance')
        .select()
        .eq('employee_id', employeeId)
        .eq('attendance_date', today)
        .limit(1);
    if (rows.isEmpty) return null;
    return Attendance.fromMap(rows.first);
  }

  Future<void> signIn(String employeeId, String employeeName) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      DemoStore.recordSignIn(employeeId, employeeName);
      return;
    }
    final now = DateTime.now();
    await _db.from('attendance').insert({
      'employee_id': employeeId,
      'employee_name': employeeName,
      'attendance_date': _dateFmt.format(now),
      'sign_in_time': _localTime(now),
      'created_at': _localTimestamp(now),
      'updated_at': _localTimestamp(now),
    });
  }

  Future<void> signOut(String id) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      DemoStore.recordSignOut(id);
      return;
    }
    final now = DateTime.now();
    await _db.from('attendance').update({
      'sign_out_time': _localTime(now),
      'updated_at': _localTimestamp(now),
    }).eq('id', id);
  }
}
