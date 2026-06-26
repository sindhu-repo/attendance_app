import 'package:flutter/foundation.dart';

import '../models/employee.dart';
import '../models/visitor.dart';
import '../repositories/employee_repository.dart';
import '../repositories/visitor_repository.dart';

enum VisitorCheckInStatus { initial, loading, success, error }

enum VisitorCheckOutStatus { initial, looking, found, notFound, checkingOut, done, error }

class VisitorProvider extends ChangeNotifier {
  final _repo = VisitorRepository();
  final _employeeRepo = EmployeeRepository();

  // ── Check-in state ────────────────────────────────────────────────────────
  VisitorCheckInStatus _checkInStatus = VisitorCheckInStatus.initial;
  String _checkInError = '';

  // ── Check-out state ───────────────────────────────────────────────────────
  VisitorCheckOutStatus _checkOutStatus = VisitorCheckOutStatus.initial;
  Visitor? _foundVisitor;
  String _checkOutError = '';

  // ── Employee list (shared) ────────────────────────────────────────────────
  List<String> _employeeNames = [];
  bool _loadingEmployees = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  VisitorCheckInStatus get checkInStatus => _checkInStatus;
  VisitorCheckOutStatus get checkOutStatus => _checkOutStatus;
  String get errorMessage => _checkInError;
  String get checkOutError => _checkOutError;
  bool get isLoading => _checkInStatus == VisitorCheckInStatus.loading;
  bool get isCheckingOut =>
      _checkOutStatus == VisitorCheckOutStatus.checkingOut ||
      _checkOutStatus == VisitorCheckOutStatus.looking;
  List<String> get employeeNames => _employeeNames;
  bool get loadingEmployees => _loadingEmployees;
  Visitor? get foundVisitor => _foundVisitor;

  // ── Employee list ─────────────────────────────────────────────────────────

  Future<void> loadEmployees() async {
    if (_employeeNames.isNotEmpty) return;
    _loadingEmployees = true;
    notifyListeners();
    try {
      final employees = await _employeeRepo.getAll();
      employees.sort((a, b) {
        int rank(Employee e) {
          final d = (e.designation ?? '').toUpperCase();
          if (d == 'CEO') return 0;
          if (d == 'CBO') return 1;
          return 2;
        }
        final diff = rank(a) - rank(b);
        if (diff != 0) return diff;
        return a.employeeName.compareTo(b.employeeName);
      });
      _employeeNames = employees.map((e) => e.employeeName).toList();
    } catch (_) {
      _employeeNames = [];
    }
    _loadingEmployees = false;
    notifyListeners();
  }

  // ── Check-in ──────────────────────────────────────────────────────────────

  Future<bool> checkIn({
    required String name,
    required String contactNumber,
    required String company,
    required String purpose,
    required String meetEmployee,
  }) async {
    _checkInStatus = VisitorCheckInStatus.loading;
    _checkInError = '';
    notifyListeners();

    try {
      await _repo.checkIn(
        Visitor(
          visitorName: name.trim(),
          contactNumber: contactNumber.trim(),
          company: company.trim(),
          purpose: purpose.trim(),
          meetEmployee: meetEmployee.trim(),
        ),
      );
      _checkInStatus = VisitorCheckInStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _checkInStatus = VisitorCheckInStatus.error;
      _checkInError = 'Check-in failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ── Check-out ─────────────────────────────────────────────────────────────

  Future<void> lookupVisitor(String contactNumber) async {
    _checkOutStatus = VisitorCheckOutStatus.looking;
    _foundVisitor = null;
    _checkOutError = '';
    notifyListeners();

    try {
      final visitor = await _repo.findActiveByContact(contactNumber);
      if (visitor == null) {
        _checkOutStatus = VisitorCheckOutStatus.notFound;
      } else {
        _foundVisitor = visitor;
        _checkOutStatus = VisitorCheckOutStatus.found;
      }
    } catch (e) {
      _checkOutStatus = VisitorCheckOutStatus.error;
      _checkOutError = 'Lookup failed: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<bool> checkOut() async {
    if (_foundVisitor?.id == null) return false;
    _checkOutStatus = VisitorCheckOutStatus.checkingOut;
    notifyListeners();

    try {
      await _repo.checkOut(_foundVisitor!.id!);
      _checkOutStatus = VisitorCheckOutStatus.done;
      notifyListeners();
      return true;
    } catch (e) {
      _checkOutStatus = VisitorCheckOutStatus.error;
      _checkOutError = 'Check-out failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void resetCheckIn() {
    _checkInStatus = VisitorCheckInStatus.initial;
    _checkInError = '';
    notifyListeners();
  }

  void resetCheckout() {
    _checkOutStatus = VisitorCheckOutStatus.initial;
    _checkOutError = '';
    _foundVisitor = null;
    notifyListeners();
  }

  void reset() {
    resetCheckIn();
    resetCheckout();
  }
}
