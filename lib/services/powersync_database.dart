import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';

/// PowerSync schema — mirrors the three Supabase tables.
///
/// PowerSync always manages an `id TEXT PRIMARY KEY` (UUID) column for
/// every table automatically; list only the non-id columns here.
const schema = Schema([
  Table('employees', [
    Column.text('employee_id'),
    Column.text('employee_name'),
    Column.text('department'),
    Column.text('designation'),
  ]),
  Table('attendance', [
    Column.text('employee_id'),
    Column.text('employee_name'),
    Column.text('attendance_date'),
    Column.text('sign_in_time'),
    Column.text('sign_out_time'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ]),
  Table('visitors', [
    Column.text('visitor_name'),
    Column.text('contact_number'),
    Column.text('company'),
    Column.text('purpose'),
    Column.text('meet_employee'),
    Column.text('visit_date'),
    Column.text('check_in_time'),
    Column.text('check_out_time'),
    Column.text('created_at'),
  ]),
]);

/// Global PowerSync database instance — access it from repositories.
late PowerSyncDatabase powerSyncDb;

Future<void> openPowerSyncDatabase() async {
  late String path;
  if (kIsWeb) {
    // Web: PowerSync uses IndexedDB internally; path is just a name.
    path = 'attendance_powersync.db';
  } else {
    final dir = await getApplicationSupportDirectory();
    path = p.join(dir.path, 'attendance_powersync.db');
  }

  powerSyncDb = PowerSyncDatabase(schema: schema, path: path);
  await powerSyncDb.initialize();
}
