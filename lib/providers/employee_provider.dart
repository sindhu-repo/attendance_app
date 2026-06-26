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
  Employee? _pendingEmployee; // set when user picks from autocomplete dropdown
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

  /// Called when the user taps a specific employee in the autocomplete dropdown.
  /// Stores the exact employee so [validateEmployee] can skip the re-lookup.
  void selectEmployee(Employee employee) {
    _pendingEmployee = employee;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Looks up an employee by [nameOrId] and loads today's attendance.
  /// If the user selected from the autocomplete dropdown, uses that employee
  /// directly instead of re-querying (avoids wrong match on duplicate names).
  Future<bool> validateEmployee(String nameOrId) async {
    _setStatus(EmployeeStatus.loading);

    try {
      if (_pendingEmployee != null) {
        _employee = _pendingEmployee;
        _pendingEmployee = null;
      } else {
        _employee = await _employeeRepo.findByName(nameOrId.trim());
      }

      if (_employee == null) {
        _setError('Employee not found. Please check your name or ID and try again.');
        return false;
      }

      _todayAttendance =
          await _attendanceRepo.getTodayAttendance(_employee!.employeeId);
      _setStatus(EmployeeStatus.verified);
      return true;
    } catch (e) {
      _pendingEmployee = null;
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
    _pendingEmployee = null;
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
