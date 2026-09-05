import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/location_service.dart';
import '../models/attendance_model.dart';
import '../models/attendance_settings_model.dart';
import '../repositories/attendance_repository.dart';

enum AttendanceViewState { initial, loading, success, error }

/// State management for employee attendance.
class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository repository;
  final int lockDurationSeconds;

  AttendanceProvider({required this.repository, this.lockDurationSeconds = 60});

  AttendanceRepository get _repository => repository;

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

  Timer? _lockTimer;
  DateTime? _lockUntil;
  bool _cooldownUnlocked = false;

  // -- Computed Getters ------------------------------------------------------

  bool get isCheckedIn => _todayAttendance?.isCheckedIn ?? false;
  bool get isCheckedOut => _todayAttendance?.isCheckedOut ?? false;
  bool get canClockIn => !isCheckedIn;
  bool get canClockOut => isCheckedIn && !isCheckedOut;
  bool get isCompleted => isCheckedIn && isCheckedOut;

  /// Number of seconds remaining in clock-in lock/cooldown. 0 if not locked.
  int get lockRemainingSeconds {
    if (lockDurationSeconds <= 0 || _cooldownUnlocked) return 0;

    // 1. Check active timer lock
    if (_lockUntil != null) {
      final diff = _lockUntil!.difference(DateTime.now()).inSeconds;
      if (diff > 0) {
        return diff;
      } else {
        _lockUntil = null;
        _lockTimer?.cancel();
        _lockTimer = null;
        return 0;
      }
    }

    // 2. Check if today's check-in was within the lock duration window
    final checkInAt = _todayAttendance?.checkIn.at;
    if (checkInAt != null && !isCheckedOut) {
      final elapsed = DateTime.now().difference(checkInAt).inSeconds;
      if (elapsed >= 0 && elapsed < lockDurationSeconds) {
        _lockUntil = checkInAt.add(Duration(seconds: lockDurationSeconds));
        _startLockTicker();
        return lockDurationSeconds - elapsed;
      }
    }

    return 0;
  }

  bool get isClockLocked => lockRemainingSeconds > 0;

  void _startLockTicker() {
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockUntil == null || DateTime.now().isAfter(_lockUntil!)) {
        _lockUntil = null;
        timer.cancel();
        _lockTimer = null;
        notifyListeners();
      } else {
        notifyListeners();
      }
    });
  }

  /// Manually unlock cooldown (useful for testing or overrides)
  void unlockCooldownForTesting() {
    _lockTimer?.cancel();
    _lockTimer = null;
    _lockUntil = null;
    _cooldownUnlocked = true;
    notifyListeners();
  }

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
        if (_todayAttendance != null &&
            _todayAttendance!.isCheckedIn &&
            !_todayAttendance!.isCheckedOut &&
            lockDurationSeconds > 0) {
          final checkInAt = _todayAttendance!.checkIn.at;
          if (checkInAt != null) {
            final elapsed = DateTime.now().difference(checkInAt).inSeconds;
            if (elapsed >= 0 && elapsed < lockDurationSeconds) {
              _lockUntil = checkInAt.add(
                Duration(seconds: lockDurationSeconds),
              );
              _startLockTicker();
            }
          }
        }
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

      if (lockDurationSeconds > 0) {
        _cooldownUnlocked = false;
        _lockUntil = DateTime.now().add(Duration(seconds: lockDurationSeconds));
        _startLockTicker();
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

    if (isClockLocked) {
      _errorMessage =
          'Please wait ${lockRemainingSeconds}s before clocking out.';
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
      // Clear any pending lock timer on check-out
      _lockTimer?.cancel();
      _lockTimer = null;
      _lockUntil = null;

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

  @override
  void dispose() {
    _lockTimer?.cancel();
    _lockTimer = null;
    super.dispose();
  }
}
