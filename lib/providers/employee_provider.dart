import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../models/employee.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/employee_repository.dart';

enum EmployeeStatus { initial, loading, verified, error }

class EmployeeProvider extends ChangeNotifier {
  final _employeeRepo = EmployeeRepository();
  final _attendanceRepo = AttendanceRepository();

  EmployeeStatus _status = EmployeeStatus.initial;
  Employee? _employee;
  Attendance? _todayAttendance;
  String _errorMessage = '';
  bool _isProcessing = false;

  // ── Getters ────────────────────────────────────────────────────────────────

  EmployeeStatus get status => _status;
  Employee? get employee => _employee;
  Attendance? get todayAttendance => _todayAttendance;
  String get errorMessage => _errorMessage;
  bool get isProcessing => _isProcessing;

  /// True when no sign-in record exists for today.
  bool get canSignIn =>
      _status == EmployeeStatus.verified &&
      (_todayAttendance == null || !_todayAttendance!.hasSignedIn);

  /// True when signed in today but not yet signed out.
  bool get canSignOut =>
      _status == EmployeeStatus.verified &&
      _todayAttendance != null &&
      _todayAttendance!.hasSignedIn &&
      !_todayAttendance!.hasSignedOut;

  // ── Search (used by autocomplete — does not change provider state) ─────────

  Future<List<Employee>> searchEmployees(String query) =>
      _employeeRepo.searchByName(query);

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Looks up an employee by [name] and loads today's attendance.
  Future<bool> validateEmployee(String name) async {
    _setStatus(EmployeeStatus.loading);

    try {
      _employee = await _employeeRepo.findByName(name.trim());

      if (_employee == null) {
        _setError('Employee not found. Please check your name and try again.');
        return false;
      }

      _todayAttendance =
          await _attendanceRepo.getTodayAttendance(_employee!.employeeId);
      _setStatus(EmployeeStatus.verified);
      return true;
    } catch (e) {
      _setError('Database error: ${e.toString()}');
      return false;
    }
  }

  /// Records a sign-in for the current employee.
  Future<bool> signIn() async {
    if (_employee == null) return false;
    return _runAction(() async {
      await _attendanceRepo.signIn(
          _employee!.employeeId, _employee!.employeeName);
      _todayAttendance =
          await _attendanceRepo.getTodayAttendance(_employee!.employeeId);
    });
  }

  /// Records a sign-out for the current employee's today record.
  Future<bool> signOut() async {
    if (_employee == null || _todayAttendance == null) return false;
    return _runAction(() async {
      await _attendanceRepo.signOut(_todayAttendance!.id);
      _todayAttendance =
          await _attendanceRepo.getTodayAttendance(_employee!.employeeId);
    });
  }

  /// Resets provider state — call when leaving the employee screen.
  void reset() {
    _status = EmployeeStatus.initial;
    _employee = null;
    _todayAttendance = null;
    _errorMessage = '';
    _isProcessing = false;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<bool> _runAction(Future<void> Function() action) async {
    _isProcessing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await action();
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  void _setStatus(EmployeeStatus status) {
    _status = status;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _status = EmployeeStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
