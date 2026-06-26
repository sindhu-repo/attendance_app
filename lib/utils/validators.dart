class AppValidators {
  static String? employeeId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Employee ID is required';
    }
    if (value.trim().length < 2) {
      return 'Employee ID must be at least 2 characters';
    }
    return null;
  }

  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? employeeName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Employee name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? visitorName(String? value) => required(value, 'Visitor name');
  static String? contactNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Contact number is required';
    final digits = value.trim().replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (digits.length < 7 || digits.length > 15) return 'Enter a valid contact number';
    if (!RegExp(r'^[0-9]+$').hasMatch(digits)) return 'Contact number must contain only digits';
    return null;
  }
  static String? company(String? value) => required(value, 'Company / Organization');
  static String? purpose(String? value) {
    if (value == null || value.trim().isEmpty) return 'Purpose of visit is required';
    final len = value.trim().length;
    if (len < 10) return 'Purpose must be at least 10 characters';
    if (len > 50) return 'Purpose must be no more than 50 characters';
    return null;
  }
}
