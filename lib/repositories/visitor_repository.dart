import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/visitor.dart';
import '../services/demo_store.dart';
import '../utils/app_config.dart';

class VisitorRepository {
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

  Future<void> checkIn(Visitor visitor) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 700));
      DemoStore.visitorCheckIn(visitor);
      return;
    }
    final now = DateTime.now();
    await _db.from('visitors').insert({
      'visitor_name': visitor.visitorName,
      'contact_number': visitor.contactNumber,
      'company': visitor.company,
      'purpose': visitor.purpose,
      'meet_employee': visitor.meetEmployee,
      'visit_date': _dateFmt.format(now),
      'check_in_time': _localTime(now),
      'created_at': _localTimestamp(now),
    });
  }

  Future<Visitor?> findActiveByContact(String contactNumber) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return DemoStore.findActiveVisitorByContact(contactNumber);
    }
    final rows = await _db
        .from('visitors')
        .select()
        .eq('contact_number', contactNumber.trim())
        .isFilter('check_out_time', null)
        .order('created_at', ascending: false)
        .limit(1);
    if (rows.isEmpty) return null;
    return Visitor.fromMap(rows.first);
  }

  Future<void> checkOut(String visitorId) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      DemoStore.visitorCheckOut(visitorId);
      return;
    }
    await _db.from('visitors').update({
      'check_out_time': _localTime(DateTime.now()),
    }).eq('id', visitorId);
  }
}
