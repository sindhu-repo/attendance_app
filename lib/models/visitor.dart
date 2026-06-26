class Visitor {
  final String? id;
  final String visitorName;
  final String contactNumber;
  final String company;
  final String purpose;
  final String meetEmployee;
  final String? checkInTime;
  final String? checkOutTime;
  final DateTime? visitDate;
  final DateTime? createdAt;

  const Visitor({
    this.id,
    required this.visitorName,
    required this.contactNumber,
    required this.company,
    required this.purpose,
    required this.meetEmployee,
    this.checkInTime,
    this.checkOutTime,
    this.visitDate,
    this.createdAt,
  });

  factory Visitor.fromMap(Map<String, dynamic> map) {
    final rawDate = map['visit_date'];
    return Visitor(
      id: map['id']?.toString(),
      visitorName: map['visitor_name'] as String? ?? '',
      contactNumber: map['contact_number'] as String? ?? '',
      company: map['company'] as String? ?? '',
      purpose: map['purpose'] as String? ?? '',
      meetEmployee: map['meet_employee'] as String? ?? '',
      checkInTime: _parseTime(map['check_in_time']),
      checkOutTime: _parseTime(map['check_out_time']),
      visitDate: rawDate is DateTime
          ? rawDate
          : rawDate != null
              ? DateTime.tryParse(rawDate.toString())
              : null,
      createdAt: map['created_at'] != null
          ? (map['created_at'] is DateTime
              ? map['created_at'] as DateTime
              : DateTime.tryParse(map['created_at'].toString()))
          : null,
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
}
