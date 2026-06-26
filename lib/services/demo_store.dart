import 'package:intl/intl.dart';
import '../models/attendance.dart';
import '../models/employee.dart';
import '../models/visitor.dart';

/// In-memory data store used when [AppConfig.demoMode] is true.
///
/// Mirrors the seed rows from setup.sql so every screen can be
/// exercised without a running PostgreSQL server.
class DemoStore {
  DemoStore._();

  static final _timeFmt = DateFormat('HH:mm:ss');
  static final _stampFmt = DateFormat('yyyy-MM-dd HH:mm:ss');

  // ── Employees ─────────────────────────────────────────────────────────────

  static final Map<String, Employee> _employees = {
    'EMP001': const Employee(employeeId: 'EMP001', employeeName: 'John Smith',     department: 'Engineering',    designation: 'CEO'),
    'EMP002': const Employee(employeeId: 'EMP002', employeeName: 'Jane Doe',       department: 'Marketing',      designation: 'CBO'),
    'EMP003': const Employee(employeeId: 'EMP003', employeeName: 'Bob Johnson',    department: 'Finance'),
    'EMP004': const Employee(employeeId: 'EMP004', employeeName: 'Alice Williams', department: 'Human Resources'),
    'EMP005': const Employee(employeeId: 'EMP005', employeeName: 'Charlie Brown',  department: 'Operations'),
    'EMP006': const Employee(employeeId: 'EMP006', employeeName: 'Diana Prince',   department: 'Engineering'),
    'EMP007': const Employee(employeeId: 'EMP007', employeeName: 'Ethan Hunt',     department: 'Sales'),
    'EMP008': const Employee(employeeId: 'EMP008', employeeName: 'Fiona Green',    department: 'Customer Support'),
    'EMP009': const Employee(employeeId: 'EMP009', employeeName: 'George Miller',  department: 'IT'),
    'EMP010': const Employee(employeeId: 'EMP010', employeeName: 'Helen Troy',     department: 'Administration'),
  };

  static Employee? findEmployee(String id) => _employees[id.trim().toUpperCase()];

  static Employee? findByName(String name) {
    final query = name.trim().toLowerCase();
    try {
      return _employees.values.firstWhere(
        (e) => e.employeeName.toLowerCase() == query,
      );
    } catch (_) {
      return null;
    }
  }

  static List<Employee> searchByName(String query) {
    final q = query.trim().toLowerCase();
    return _employees.values
        .where((e) => e.employeeName.toLowerCase().contains(q))
        .toList();
  }

  // ── Attendance (session-scoped, resets on app restart) ───────────────────

  static final Map<String, Attendance> _attendance = {};
  static int _nextAttendanceId = 1;

  static Attendance? getTodayAttendance(String employeeId) =>
      _attendance[employeeId.toUpperCase()];

  static void recordSignIn(String employeeId, String employeeName) {
    _attendance[employeeId.toUpperCase()] = Attendance(
      id: 'demo-att-${_nextAttendanceId++}',
      employeeId: employeeId,
      employeeName: employeeName,
      attendanceDate: DateTime.now(),
      signInTime: _timeFmt.format(DateTime.now()),
    );
  }

  static void recordSignOut(String attendanceId) {
    final entry = _attendance.entries.firstWhere(
      (e) => e.value.id == attendanceId,
    );
    final old = entry.value;
    _attendance[entry.key] = Attendance(
      id: old.id,
      employeeId: old.employeeId,
      employeeName: old.employeeName,
      attendanceDate: old.attendanceDate,
      signInTime: old.signInTime,
      signOutTime: _timeFmt.format(DateTime.now()),
    );
  }

  // ── Visitors (session-scoped, resets on app restart) ─────────────────────

  static final List<Visitor> _visitors = [];
  static int _nextVisitorId = 100;

  static void visitorCheckIn(Visitor visitor) {
    final now = DateTime.now();
    _visitors.add(Visitor(
      id: 'demo-vis-${_nextVisitorId++}',
      visitorName: visitor.visitorName,
      contactNumber: visitor.contactNumber,
      company: visitor.company,
      purpose: visitor.purpose,
      meetEmployee: visitor.meetEmployee,
      visitDate: now,
      checkInTime: _stampFmt.format(now),
    ));
  }

  static Visitor? findActiveVisitorByContact(String contactNumber) {
    final contact = contactNumber.trim();
    try {
      return _visitors.lastWhere(
        (v) => v.contactNumber == contact && v.checkOutTime == null,
      );
    } catch (_) {
      return null;
    }
  }

  static void visitorCheckOut(String id) {
    final idx = _visitors.indexWhere((v) => v.id == id);
    if (idx < 0) return;
    final old = _visitors[idx];
    _visitors[idx] = Visitor(
      id: old.id,
      visitorName: old.visitorName,
      contactNumber: old.contactNumber,
      company: old.company,
      purpose: old.purpose,
      meetEmployee: old.meetEmployee,
      visitDate: old.visitDate,
      checkInTime: old.checkInTime,
      checkOutTime: _stampFmt.format(DateTime.now()),
    );
  }
}
