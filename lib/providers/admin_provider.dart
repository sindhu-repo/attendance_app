import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import '../repositories/admin_repository.dart';

enum AdminStatus { idle, loading, loaded, error }

class AdminProvider extends ChangeNotifier {
  final _repo = AdminRepository();

  AdminStatus _attendanceStatus = AdminStatus.idle;
  List<Map<String, dynamic>> _attendanceRecords = [];
  String _attendanceError = '';

  AdminStatus _visitorStatus = AdminStatus.idle;
  List<Map<String, dynamic>> _visitorRecords = [];
  String _visitorError = '';

  AdminStatus _employeeStatus = AdminStatus.idle;
  List<Employee> _employees = [];
  String _employeeError = '';

  AdminStatus get attendanceStatus => _attendanceStatus;
  List<Map<String, dynamic>> get attendanceRecords =>
      List.unmodifiable(_attendanceRecords);
  String get attendanceError => _attendanceError;

  AdminStatus get visitorStatus => _visitorStatus;
  List<Map<String, dynamic>> get visitorRecords =>
      List.unmodifiable(_visitorRecords);
  String get visitorError => _visitorError;

  AdminStatus get employeeStatus => _employeeStatus;
  List<Employee> get employees => List.unmodifiable(_employees);
  String get employeeError => _employeeError;

  Future<void> loadAttendanceReport({
    required String startDate,
    required String endDate,
    String? employeeQuery,
  }) async {
    _attendanceStatus = AdminStatus.loading;
    _attendanceError = '';
    notifyListeners();
    try {
      _attendanceRecords = await _repo.getAttendanceReport(
        startDate: startDate,
        endDate: endDate,
        employeeQuery: employeeQuery,
      );
      _attendanceStatus = AdminStatus.loaded;
    } catch (e) {
      _attendanceError = e.toString();
      _attendanceStatus = AdminStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadVisitorReport({
    required String startDate,
    required String endDate,
  }) async {
    _visitorStatus = AdminStatus.loading;
    _visitorError = '';
    notifyListeners();
    try {
      _visitorRecords = await _repo.getVisitorReport(
        startDate: startDate,
        endDate: endDate,
      );
      _visitorStatus = AdminStatus.loaded;
    } catch (e) {
      _visitorError = e.toString();
      _visitorStatus = AdminStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadEmployees() async {
    _employeeStatus = AdminStatus.loading;
    _employeeError = '';
    notifyListeners();
    try {
      _employees = await _repo.getAllEmployees();
      _employeeStatus = AdminStatus.loaded;
    } catch (e) {
      _employeeError = e.toString();
      _employeeStatus = AdminStatus.error;
    }
    notifyListeners();
  }

  Future<bool> addEmployee({
    required String employeeId,
    required String employeeName,
    String? department,
    String? designation,
    String role = 'employee',
  }) async {
    try {
      await _repo.addEmployee(
        employeeId: employeeId,
        employeeName: employeeName,
        department: department,
        designation: designation,
        role: role,
      );
      await loadEmployees();
      return true;
    } catch (e) {
      _employeeError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmployee({
    required String originalId,
    required String employeeId,
    required String employeeName,
    String? department,
    String? designation,
    required String role,
  }) async {
    try {
      await _repo.updateEmployee(
        originalId: originalId,
        employeeId: employeeId,
        employeeName: employeeName,
        department: department,
        designation: designation,
        role: role,
      );
      await loadEmployees();
      return true;
    } catch (e) {
      _employeeError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEmployee(String employeeId) async {
    try {
      await _repo.deleteEmployee(employeeId);
      await loadEmployees();
      return true;
    } catch (e) {
      _employeeError = e.toString();
      notifyListeners();
      return false;
    }
  }
}
