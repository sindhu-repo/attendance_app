class Attendance {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime attendanceDate;
  final String? signInTime;
  final String? signOutTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.attendanceDate,
    this.signInTime,
    this.signOutTime,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasSignedIn => signInTime != null && signInTime!.isNotEmpty;
  bool get hasSignedOut => signOutTime != null && signOutTime!.isNotEmpty;

  factory Attendance.fromMap(Map<String, dynamic> map) {
    final rawDate = map['attendance_date'];
    final DateTime attendanceDate = rawDate is DateTime
        ? rawDate
        : DateTime.parse(rawDate.toString());

    return Attendance(
      id: map['id'] as String,
      employeeId: map['employee_id'] as String,
      employeeName: map['employee_name'] as String,
      attendanceDate: attendanceDate,
      signInTime: _parseTime(map['sign_in_time']),
      signOutTime: _parseTime(map['sign_out_time']),
      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),
    );
  }

  // Time fields are stored as local HH:mm:ss strings — return as-is.
  // Falls back to ISO parsing for any legacy records stored as full timestamps.
  static String? _parseTime(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty) return null;
    // Already HH:mm:ss — return directly.
    if (str.length == 8 && str.contains(':')) return str;
    // Legacy full timestamp — extract local HH:mm:ss.
    try {
      final dt = DateTime.parse(str).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      final s = dt.second.toString().padLeft(2, '0');
      return '$h:$m:$s';
    } catch (_) {
      return str;
    }
  }

  // Safely parse DateTime from either a DateTime object or ISO string
  static DateTime? _parseDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return null;
    }
  }
}
