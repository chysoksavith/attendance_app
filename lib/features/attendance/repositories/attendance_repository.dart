import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/attendance_model.dart';
import '../models/attendance_settings_model.dart';

/// Handles attendance-related API calls. Thin repository layer with
/// request -> response translation.
class AttendanceRepository {
  final ApiClient _client;

  AttendanceRepository({required this._client});

  /// Fetch company attendance configuration rules
  Future<AttendanceSettingsModel> getSettings() async {
    final response = await _client.get(ApiConstants.attendanceSettings);
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return AttendanceSettingsModel.fromJson(data);
  }

  /// Fetch paginated list of attendances for the authenticated user
  Future<List<AttendanceModel>> getAttendances({int page = 1}) async {
    final response = await _client.get(
      '${ApiConstants.attendances}?page=$page',
    );
    final envelope = response['data'] as Map<String, dynamic>?;
    final list =
        (envelope?['data'] as List<dynamic>?) ??
        (response['data'] as List<dynamic>?) ??
        [];

    return list
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Find today's attendance record
  Future<AttendanceModel?> getTodayAttendance() async {
    final list = await getAttendances(page: 1);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    try {
      return list.firstWhere((record) => record.date == today);
    } catch (_) {
      return null;
    }
  }

  /// Clock in / Check in
  Future<AttendanceModel> checkIn({
    double? latitude,
    double? longitude,
    String? photoPath,
    String? wifiBssid,
    String? deviceId,
    String? note,
    bool isMocked = false,
  }) async {
    final body = <String, dynamic>{'is_mocked': isMocked};
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (photoPath != null) body['photo_path'] = photoPath;
    if (wifiBssid != null) body['wifi_bssid'] = wifiBssid;
    if (deviceId != null) body['device_id'] = deviceId;
    if (note != null) body['note'] = note;

    final response = await _client.post(ApiConstants.attendances, body: body);

    final data = response['data'] as Map<String, dynamic>;
    return AttendanceModel.fromJson(data);
  }

  /// Clock out / Check out
  Future<AttendanceModel> checkOut(
    int attendanceId, {
    double? latitude,
    double? longitude,
    String? photoPath,
    String? wifiBssid,
    String? deviceId,
    String? note,
    bool isMocked = false,
  }) async {
    final body = <String, dynamic>{'is_mocked': isMocked};
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (photoPath != null) body['photo_path'] = photoPath;
    if (wifiBssid != null) body['wifi_bssid'] = wifiBssid;
    if (deviceId != null) body['device_id'] = deviceId;
    if (note != null) body['note'] = note;

    final response = await _client.put(
      '${ApiConstants.attendances}/$attendanceId',
      body: body,
    );

    final data = response['data'] as Map<String, dynamic>;
    return AttendanceModel.fromJson(data);
  }
}
