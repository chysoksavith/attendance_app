import 'package:flutter/foundation.dart';
import '../../../core/services/location_service.dart';
import '../models/attendance_model.dart';
import '../models/attendance_settings_model.dart';
import '../repositories/attendance_repository.dart';

enum AttendanceViewState { initial, loading, success, error }

/// State management for employee attendance.
class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _repository;

  AttendanceProvider({required this._repository});

  // -- State -----------------------------------------------------------------

  AttendanceViewState _state = AttendanceViewState.initial;
  AttendanceViewState get state => _state;

  AttendanceModel? _todayAttendance;
  AttendanceModel? get todayAttendance => _todayAttendance;

  List<AttendanceModel> _history = [];
  List<AttendanceModel> get history => _history;

  AttendanceSettingsModel? _settings;
  AttendanceSettingsModel? get settings => _settings;

  bool _isClocking = false;
  bool get isClocking => _isClocking;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // -- Computed Getters ------------------------------------------------------

  bool get isCheckedIn => _todayAttendance?.isCheckedIn ?? false;
  bool get isCheckedOut => _todayAttendance?.isCheckedOut ?? false;
  bool get canClockIn => !isCheckedIn;
  bool get canClockOut => isCheckedIn && !isCheckedOut;
  bool get isCompleted => isCheckedIn && isCheckedOut;

  // -- Actions ---------------------------------------------------------------

  /// Load initial attendance data: settings, today's status, and recent history.
  Future<void> loadInitialData() async {
    _state = AttendanceViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getSettings(),
        _repository.getAttendances(page: 1),
      ]);

      _settings = results[0] as AttendanceSettingsModel;
      _history = results[1] as List<AttendanceModel>;

      final today = DateTime.now().toIso8601String().substring(0, 10);
      try {
        _todayAttendance = _history.firstWhere((r) => r.date == today);
      } catch (_) {
        _todayAttendance = null;
      }

      _state = AttendanceViewState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AttendanceViewState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Perform Check In (Clock In)
  Future<bool> checkIn({
    double? latitude,
    double? longitude,
    String? photoPath,
    String? wifiBssid,
    String? deviceId,
    String? note,
    bool? isMocked,
  }) async {
    _isClocking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var resolvedLat = latitude;
      var resolvedLng = longitude;
      var resolvedMocked = isMocked ?? false;

      // Automatically capture GPS location if not explicitly provided
      if (resolvedLat == null || resolvedLng == null) {
        try {
          final loc = await LocationService.getCurrentLocation(
            blockMockLocation: _settings?.blockMockLocation ?? true,
          );
          resolvedLat = loc.latitude;
          resolvedLng = loc.longitude;
          resolvedMocked = loc.isMocked;
        } catch (locErr) {
          final geofenceRequired = _settings?.requireGeofence ?? true;
          if (geofenceRequired) {
            _errorMessage = locErr.toString().replaceAll('Exception: ', '');
            return false;
          }
        }
      }

      final record = await _repository.checkIn(
        latitude: resolvedLat,
        longitude: resolvedLng,
        photoPath: photoPath,
        wifiBssid: wifiBssid,
        deviceId: deviceId,
        note: note,
        isMocked: resolvedMocked,
      );

      _todayAttendance = record;
      // Update or prepend to history
      _history.removeWhere((r) => r.id == record.id);
      _history.insert(0, record);

      _state = AttendanceViewState.success;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isClocking = false;
      notifyListeners();
    }
  }

  /// Perform Check Out (Clock Out)
  Future<bool> checkOut({
    double? latitude,
    double? longitude,
    String? photoPath,
    String? wifiBssid,
    String? deviceId,
    String? note,
    bool? isMocked,
  }) async {
    if (_todayAttendance == null) {
      _errorMessage = 'No active check-in record found to check out.';
      notifyListeners();
      return false;
    }

    _isClocking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var resolvedLat = latitude;
      var resolvedLng = longitude;
      var resolvedMocked = isMocked ?? false;

      // Automatically capture GPS location if not explicitly provided
      if (resolvedLat == null || resolvedLng == null) {
        try {
          final loc = await LocationService.getCurrentLocation(
            blockMockLocation: _settings?.blockMockLocation ?? true,
          );
          resolvedLat = loc.latitude;
          resolvedLng = loc.longitude;
          resolvedMocked = loc.isMocked;
        } catch (locErr) {
          final geofenceRequired = _settings?.requireGeofence ?? true;
          if (geofenceRequired) {
            _errorMessage = locErr.toString().replaceAll('Exception: ', '');
            return false;
          }
        }
      }

      final record = await _repository.checkOut(
        _todayAttendance!.id,
        latitude: resolvedLat,
        longitude: resolvedLng,
        photoPath: photoPath,
        wifiBssid: wifiBssid,
        deviceId: deviceId,
        note: note,
        isMocked: resolvedMocked,
      );

      _todayAttendance = record;
      // Update in history list
      final index = _history.indexWhere((r) => r.id == record.id);
      if (index >= 0) {
        _history[index] = record;
      } else {
        _history.insert(0, record);
      }

      _state = AttendanceViewState.success;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isClocking = false;
      notifyListeners();
    }
  }

  /// Refresh attendance data
  Future<void> refresh() => loadInitialData();
}
