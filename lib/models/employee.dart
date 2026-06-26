class Employee {
  final String employeeId;
  final String employeeName;
  final String? department;
  final String? designation;

  const Employee({
    required this.employeeId,
    required this.employeeName,
    this.department,
    this.designation,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      employeeId: map['employee_id'] as String,
      employeeName: map['employee_name'] as String,
      department: map['department'] as String?,
      designation: map['designation'] as String?,
    );
  }

  @override
  String toString() =>
      'Employee(id: $employeeId, name: $employeeName, dept: $department)';
}
