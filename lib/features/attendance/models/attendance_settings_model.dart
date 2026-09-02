class AttendanceSettingsModel {
  final bool requireGeofence;
  final bool requirePhoto;
  final bool blockMockLocation;
  final bool allowWifiBypass;

  const AttendanceSettingsModel({
    this.requireGeofence = true,
    this.requirePhoto = false,
    this.blockMockLocation = true,
    this.allowWifiBypass = true,
  });

  factory AttendanceSettingsModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic v, {bool defaultValue = true}) {
      if (v == null) return defaultValue;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v == '1' || v.toLowerCase() == 'true';
      return defaultValue;
    }

    return AttendanceSettingsModel(
      requireGeofence: parseBool(json['require_geofence'], defaultValue: true),
      requirePhoto: parseBool(json['require_photo'], defaultValue: false),
      blockMockLocation: parseBool(
        json['block_mock_location'],
        defaultValue: true,
      ),
      allowWifiBypass: parseBool(json['allow_wifi_bypass'], defaultValue: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'require_geofence': requireGeofence,
      'require_photo': requirePhoto,
      'block_mock_location': blockMockLocation,
      'allow_wifi_bypass': allowWifiBypass,
    };
  }
}
