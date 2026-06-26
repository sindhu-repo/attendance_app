import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/employee.dart';
import '../services/demo_store.dart';
import '../utils/app_config.dart';

class EmployeeRepository {
  final _db = Supabase.instance.client;

  Future<List<Employee>> searchByName(String query) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return DemoStore.searchByName(query);
    }
    final q = query.trim();
    final rows = await _db
        .from('employees')
        .select('employee_id, employee_name, department, designation')
        .or('employee_name.ilike.%$q%,employee_id.ilike.%$q%')
        .limit(10);
    return rows.map((r) => Employee.fromMap(r)).toList();
  }

  Future<List<Employee>> getAll() async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return DemoStore.searchByName('');
    }
    final rows = await _db
        .from('employees')
        .select('employee_id, employee_name, department, designation');
    return rows.map((r) => Employee.fromMap(r)).toList();
  }

  Future<Employee?> findByName(String input) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return DemoStore.searchByName(input).firstOrNull;
    }
    final q = input.trim();
    final rows = await _db
        .from('employees')
        .select('employee_id, employee_name, department, designation')
        .or('employee_name.ilike.%$q%,employee_id.ilike.%$q%')
        .limit(1);
    if (rows.isEmpty) return null;
    return Employee.fromMap(rows.first);
  }
}
