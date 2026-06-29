class Employee {
  final String employeeId;
  final String employeeName;
  final String? department;
  final String? designation;
  final String role;

  bool get isAdmin => role == 'admin';

  const Employee({
    required this.employeeId,
    required this.employeeName,
    this.department,
    this.designation,
    this.role = 'employee',
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      employeeId: map['employee_id'] as String,
      employeeName: map['employee_name'] as String,
      department: map['department'] as String?,
      designation: map['designation'] as String?,
      role: map['role'] as String? ?? 'employee',
    );
  }

  Employee copyWith({
    String? employeeId,
    String? employeeName,
    String? department,
    String? designation,
    String? role,
  }) {
    return Employee(
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      role: role ?? this.role,
    );
  }

  @override
  String toString() =>
      'Employee(id: $employeeId, name: $employeeName, dept: $department, role: $role)';
}
