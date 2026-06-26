import '../models/employee.dart';
import '../services/demo_store.dart';
import '../services/powersync_database.dart';
import '../utils/app_config.dart';

class EmployeeRepository {
  Future<List<Employee>> searchByName(String query) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return DemoStore.searchByName(query);
    }

    final rows = await powerSyncDb.getAll(
      'SELECT employee_id, employee_name, department, designation FROM employees WHERE LOWER(employee_name) LIKE ? LIMIT 10',
      ['%${query.trim().toLowerCase()}%'],
    );
    return rows.map((r) => Employee.fromMap(r)).toList();
  }

  Future<List<Employee>> getAll() async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return DemoStore.searchByName('');
    }

    final rows = await powerSyncDb.getAll(
      'SELECT employee_id, employee_name, department, designation FROM employees',
    );
    return rows.map((r) => Employee.fromMap(r)).toList();
  }

  Future<Employee?> findByName(String name) async {
    if (AppConfig.demoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return DemoStore.searchByName(name).firstOrNull;
    }

    final rows = await powerSyncDb.getAll(
      'SELECT employee_id, employee_name, department, designation '
      'FROM employees '
      'WHERE LOWER(employee_name) LIKE ? '
      'LIMIT 1',
      ['%${name.trim().toLowerCase()}%'],
    );
    if (rows.isEmpty) return null;
    return Employee.fromMap(rows.first);
  }
}
