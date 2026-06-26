import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/visitor.dart';
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

// Returns UTC timestamp without milliseconds: 2026-06-25T12:23:16Z
String _utcTimestamp(DateTime dt) =>
    '${dt.toUtc().toIso8601String().split('.').first}Z';

class VisitorRepository {
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  Future<void> checkIn(Visitor visitor) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 700));
      DemoStore.visitorCheckIn(visitor);
      return;
    }

    final now = DateTime.now();
    await powerSyncDb.execute(
      'INSERT INTO visitors (id, visitor_name, contact_number, company, purpose, meet_employee, visit_date, check_in_time, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        _uuid.v4(),
        visitor.visitorName,
        visitor.contactNumber,
        visitor.company,
        visitor.purpose,
        visitor.meetEmployee,
        _dateFmt.format(now),
        _localTime(now),
        _utcTimestamp(now),
      ],
    );
  }

  Future<Visitor?> findActiveByContact(String contactNumber) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return DemoStore.findActiveVisitorByContact(contactNumber);
    }

    final row = await powerSyncDb.getOptional(
      'SELECT * FROM visitors WHERE contact_number = ? AND check_out_time IS NULL ORDER BY created_at DESC LIMIT 1',
      [contactNumber.trim()],
    );
    if (row == null) return null;
    return Visitor.fromMap(row);
  }

  Future<void> checkOut(String visitorId) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      DemoStore.visitorCheckOut(visitorId);
      return;
    }

    await powerSyncDb.execute(
      'UPDATE visitors SET check_out_time = ? WHERE id = ?',
      [_localTime(DateTime.now()), visitorId],
    );
  }
}
