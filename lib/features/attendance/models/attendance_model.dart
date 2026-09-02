double? _toDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val);
  return null;
}

int? _toInt(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val);
  return null;
}

bool _toBool(dynamic val, {bool defaultValue = false}) {
  if (val == null) return defaultValue;
  if (val is bool) return val;
  if (val is num) return val != 0;
  if (val is String) {
    return val == '1' || val.toLowerCase() == 'true';
  }
  return defaultValue;
}

class CheckPointModel {
  final DateTime? at;
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;
  final String? photoUrl;
  final String? ip;
  final String? wifiBssid;
  final bool isMocked;

  const CheckPointModel({
    this.at,
    this.latitude,
    this.longitude,
    this.distanceMeters,
    this.photoUrl,
    this.ip,
    this.wifiBssid,
    this.isMocked = false,
  });

  factory CheckPointModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CheckPointModel();

    return CheckPointModel(
      at: json['at'] != null ? DateTime.tryParse(json['at'].toString()) : null,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      distanceMeters: _toDouble(json['distance_meters']),
      photoUrl: json['photo_url']?.toString(),
      ip: json['ip']?.toString(),
      wifiBssid: json['wifi_bssid']?.toString(),
      isMocked: _toBool(json['is_mocked']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'at': at?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'distance_meters': distanceMeters,
      'photo_url': photoUrl,
      'ip': ip,
      'wifi_bssid': wifiBssid,
      'is_mocked': isMocked,
    };
  }
}

class AttendanceStatusModel {
  final String value;
  final String label;
  final String color;

  const AttendanceStatusModel({
    this.value = 'absent',
    this.label = 'Absent',
    this.color = 'neutral',
  });

  factory AttendanceStatusModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return AttendanceStatusModel(
        value: json['value']?.toString() ?? 'absent',
        label: json['label']?.toString() ?? 'Absent',
        color: json['color']?.toString() ?? 'neutral',
      );
    }
    if (json is String) {
      return AttendanceStatusModel(
        value: json,
        label: json.isNotEmpty ? json[0].toUpperCase() + json.substring(1) : '',
        color: 'neutral',
      );
    }
    return const AttendanceStatusModel();
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'label': label, 'color': color};
  }
}

/// Mirrors the ERP's `Api\V1\AttendanceResource` response shape.
class AttendanceModel {
  final int id;
  final int? shiftId;
  final int? companyLocationId;
  final String? date;
  final CheckPointModel checkIn;
  final CheckPointModel checkOut;
  final AttendanceStatusModel status;
  final int lateMinutes;
  final int earlyLeaveMinutes;
  final int overtimeMinutes;
  final bool isOvertimeApproved;
  final int? workMinutes;
  final bool isWithinGeofence;
  final String? source;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AttendanceModel({
    required this.id,
    this.shiftId,
    this.companyLocationId,
    this.date,
    this.checkIn = const CheckPointModel(),
    this.checkOut = const CheckPointModel(),
    this.status = const AttendanceStatusModel(),
    this.lateMinutes = 0,
    this.earlyLeaveMinutes = 0,
    this.overtimeMinutes = 0,
    this.isOvertimeApproved = false,
    this.workMinutes,
    this.isWithinGeofence = false,
    this.source,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: _toInt(json['id']) ?? 0,
      shiftId: _toInt(json['shift_id']),
      companyLocationId: _toInt(json['company_location_id']),
      date: json['date']?.toString(),
      checkIn: CheckPointModel.fromJson(
        json['check_in'] as Map<String, dynamic>?,
      ),
      checkOut: CheckPointModel.fromJson(
        json['check_out'] as Map<String, dynamic>?,
      ),
      status: AttendanceStatusModel.fromJson(json['status']),
      lateMinutes: _toInt(json['late_minutes']) ?? 0,
      earlyLeaveMinutes: _toInt(json['early_leave_minutes']) ?? 0,
      overtimeMinutes: _toInt(json['overtime_minutes']) ?? 0,
      isOvertimeApproved: _toBool(json['is_overtime_approved']),
      workMinutes: _toInt(json['work_minutes']),
      isWithinGeofence: _toBool(json['is_within_geofence']),
      source: json['source']?.toString(),
      note: json['note']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shift_id': shiftId,
      'company_location_id': companyLocationId,
      'date': date,
      'check_in': checkIn.toJson(),
      'check_out': checkOut.toJson(),
      'status': status.toJson(),
      'late_minutes': lateMinutes,
      'early_leave_minutes': earlyLeaveMinutes,
      'overtime_minutes': overtimeMinutes,
      'is_overtime_approved': isOvertimeApproved,
      'work_minutes': workMinutes,
      'is_within_geofence': isWithinGeofence,
      'source': source,
      'note': note,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isCheckedIn => checkIn.at != null;
  bool get isCheckedOut => checkOut.at != null;

  String get formattedDuration {
    if (workMinutes == null || workMinutes! <= 0) {
      if (checkIn.at != null && checkOut.at == null) {
        final duration = DateTime.now().difference(checkIn.at!);
        final hours = duration.inHours;
        final minutes = duration.inMinutes.remainder(60);
        return '${hours}h ${minutes}m';
      }
      return '0h 0m';
    }
    final hours = workMinutes! ~/ 60;
    final minutes = workMinutes! % 60;
    return '${hours}h ${minutes}m';
  }
}
