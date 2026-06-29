import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';

class AdminRepository {
  final _db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAttendanceReport({
    required String startDate,
    required String endDate,
    String? employeeQuery,
  }) async {
    final q = employeeQuery?.trim() ?? '';
    if (q.isNotEmpty) {
      return await _db
          .from('attendance')
          .select(
              'employee_id, employee_name, attendance_date, sign_in_time, sign_out_time')
          .gte('attendance_date', startDate)
          .lte('attendance_date', endDate)
          .or('employee_name.ilike.%$q%,employee_id.ilike.%$q%')
          .order('attendance_date', ascending: false);
    }
    return await _db
        .from('attendance')
        .select(
            'employee_id, employee_name, attendance_date, sign_in_time, sign_out_time')
        .gte('attendance_date', startDate)
        .lte('attendance_date', endDate)
        .order('attendance_date', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getVisitorReport({
    required String startDate,
    required String endDate,
  }) async {
    return await _db
        .from('visitors')
        .select(
            'visitor_name, contact_number, company, purpose, meet_employee, visit_date, check_in_time, check_out_time')
        .gte('visit_date', startDate)
        .lte('visit_date', endDate)
        .order('visit_date', ascending: false);
  }

  Future<List<Employee>> getAllEmployees() async {
    final rows = await _db
        .from('employees')
        .select(
            'employee_id, employee_name, department, designation, role, email, mobile_number')
        .order('employee_name');
    return rows.map((r) => Employee.fromMap(r)).toList();
  }

  Future<void> addEmployee({
    required String employeeId,
    required String employeeName,
    String? department,
    String? designation,
    String role = 'employee',
    String? email,
    String? mobileNumber,
  }) async {
    await _db.from('employees').insert({
      'employee_id': employeeId,
      'employee_name': employeeName,
      if (department?.isNotEmpty == true) 'department': department,
      if (designation?.isNotEmpty == true) 'designation': designation,
      'role': role,
      if (email?.isNotEmpty == true) 'email': email,
      if (mobileNumber?.isNotEmpty == true) 'mobile_number': mobileNumber,
    });
  }

  Future<void> updateEmployee({
    required String originalId,
    required String employeeId,
    required String employeeName,
    String? department,
    String? designation,
    required String role,
    String? email,
    String? mobileNumber,
  }) async {
    await _db.from('employees').update({
      'employee_id': employeeId,
      'employee_name': employeeName,
      'department': department?.isEmpty == true ? null : department,
      'designation': designation?.isEmpty == true ? null : designation,
      'role': role,
      'email': email?.isEmpty == true ? null : email,
      'mobile_number': mobileNumber?.isEmpty == true ? null : mobileNumber,
    }).eq('employee_id', originalId);
  }

  Future<void> deleteEmployee(String employeeId) async {
    await _db.from('employees').delete().eq('employee_id', employeeId);
  }

  Future<bool> validateAdminCredentials(String password) async {
    final row = await _db
        .from('admin_credentials')
        .select('id')
        .eq('password', password)
        .maybeSingle();
    return row != null;
  }
}
