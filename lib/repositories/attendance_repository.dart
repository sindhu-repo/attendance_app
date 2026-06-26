import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/attendance.dart';
import '../services/demo_store.dart';
import '../services/powersync_database.dart';
import '../utils/app_config.dart';

const _uuid = Uuid();

// Returns local time as HH:mm:ss — no date, no milliseconds.
String _localTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  final s = dt.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}

// Returns local datetime as yyyy-MM-ddTHH:mm:ss — no timezone offset, no milliseconds.
String _localTimestamp(DateTime dt) =>
    DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dt);

class AttendanceRepository {
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  Future<Attendance?> getTodayAttendance(String employeeId) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      return DemoStore.getTodayAttendance(employeeId);
    }

    final today = _dateFmt.format(DateTime.now());
    final row = await powerSyncDb.getOptional(
      'SELECT * FROM attendance WHERE employee_id = ? AND attendance_date = ? LIMIT 1',
      [employeeId, today],
    );
    if (row == null) return null;
    return Attendance.fromMap(row);
  }

  Future<void> signIn(String employeeId, String employeeName) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      DemoStore.recordSignIn(employeeId, employeeName);
      return;
    }

    final now = DateTime.now();
    await powerSyncDb.execute(
      'INSERT OR IGNORE INTO attendance (id, employee_id, employee_name, attendance_date, sign_in_time, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        _uuid.v4(),
        employeeId,
        employeeName,
        _dateFmt.format(now),
        _localTime(now),
        _localTimestamp(now),
        _localTimestamp(now),
      ],
    );
  }

  Future<void> signOut(String id) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      DemoStore.recordSignOut(id);
      return;
    }

    final now = DateTime.now();
    await powerSyncDb.execute(
      'UPDATE attendance SET sign_out_time = ?, updated_at = ? WHERE id = ?',
      [_localTime(now), _localTimestamp(now), id],
    );
  }
}
