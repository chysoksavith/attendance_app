import 'package:flutter_test/flutter_test.dart';
import 'package:attendance/core/network/api_client.dart';
import 'package:attendance/core/storage/token_storage.dart';
import 'package:attendance/features/attendance/models/attendance_model.dart';
import 'package:attendance/features/attendance/models/attendance_settings_model.dart';
import 'package:attendance/features/attendance/providers/attendance_provider.dart';
import 'package:attendance/features/attendance/repositories/attendance_repository.dart';

class FakeAttendanceRepository extends AttendanceRepository {
  FakeAttendanceRepository()
    : super(client: ApiClient(tokenStorage: TokenStorage()));

  bool shouldFail = false;
  AttendanceModel? mockRecord;

  @override
  Future<AttendanceSettingsModel> getSettings() async {
    return const AttendanceSettingsModel(
      requireGeofence: true,
      requirePhoto: false,
    );
  }

  @override
  Future<List<AttendanceModel>> getAttendances({int page = 1}) async {
    return mockRecord != null ? [mockRecord!] : [];
  }

  @override
  Future<AttendanceModel> checkIn({
    double? latitude,
    double? longitude,
    String? photoPath,
    String? wifiBssid,
    String? deviceId,
    String? note,
    bool isMocked = false,
  }) async {
    if (shouldFail) {
      throw Exception('Location outside allowed geofence boundary.');
    }
    final record = AttendanceModel(
      id: 1,
      date: DateTime.now().toIso8601String().substring(0, 10),
      checkIn: CheckPointModel(
        at: DateTime.now(),
        latitude: latitude ?? 11.5564,
        longitude: longitude ?? 104.9282,
      ),
      status: const AttendanceStatusModel(
        value: 'present',
        label: 'Present',
        color: 'success',
      ),
    );
    mockRecord = record;
    return record;
  }

  @override
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
    if (shouldFail) {
      throw Exception('Already checked out.');
    }
    final record = AttendanceModel(
      id: attendanceId,
      date: DateTime.now().toIso8601String().substring(0, 10),
      checkIn: mockRecord?.checkIn ?? CheckPointModel(at: DateTime.now()),
      checkOut: CheckPointModel(
        at: DateTime.now(),
        latitude: latitude ?? 11.5564,
        longitude: longitude ?? 104.9282,
      ),
      workMinutes: 480,
      status: const AttendanceStatusModel(
        value: 'present',
        label: 'Present',
        color: 'success',
      ),
    );
    mockRecord = record;
    return record;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Attendance Models', () {
    test('AttendanceModel parses JSON correctly', () {
      final json = {
        'id': 10,
        'date': '2026-09-01',
        'check_in': {
          'at': '2026-09-01T08:00:00.000Z',
          'latitude': 11.5564,
          'longitude': 104.9282,
          'is_mocked': false,
        },
        'check_out': {
          'at': '2026-09-01T17:00:00.000Z',
          'latitude': 11.5564,
          'longitude': 104.9282,
          'is_mocked': false,
        },
        'status': {'value': 'present', 'label': 'Present', 'color': 'success'},
        'work_minutes': 540,
        'late_minutes': 0,
        'early_leave_minutes': 0,
        'is_within_geofence': true,
      };

      final model = AttendanceModel.fromJson(json);
      expect(model.id, 10);
      expect(model.date, '2026-09-01');
      expect(model.isCheckedIn, true);
      expect(model.isCheckedOut, true);
      expect(model.formattedDuration, '9h 0m');
      expect(model.status.label, 'Present');
    });

    test('AttendanceSettingsModel parses JSON defaults correctly', () {
      final json = {
        'require_geofence': true,
        'require_photo': false,
        'block_mock_location': true,
        'allow_wifi_bypass': true,
      };

      final settings = AttendanceSettingsModel.fromJson(json);
      expect(settings.requireGeofence, true);
      expect(settings.requirePhoto, false);
      expect(settings.blockMockLocation, true);
      expect(settings.allowWifiBypass, true);
    });
  });

  group('AttendanceProvider State Machine', () {
    late FakeAttendanceRepository repository;
    late AttendanceProvider provider;

    setUp(() {
      repository = FakeAttendanceRepository();
      provider = AttendanceProvider(repository: repository);
    });

    test('initial state is correct', () {
      expect(provider.state, AttendanceViewState.initial);
      expect(provider.canClockIn, true);
      expect(provider.canClockOut, false);
      expect(provider.isCheckedIn, false);
      expect(provider.isCheckedOut, false);
    });

    test('successful check-in updates state and enables check-out', () async {
      final success = await provider.checkIn(
        latitude: 11.5564,
        longitude: 104.9282,
      );

      expect(success, true);
      expect(provider.isCheckedIn, true);
      expect(provider.isCheckedOut, false);
      expect(provider.canClockIn, false);
      expect(provider.canClockOut, true);
      expect(provider.isClockLocked, true);
      expect(provider.lockRemainingSeconds, greaterThan(0));
      expect(provider.history.length, 1);
    });

    test('cooldown lock prevents immediate check-out until unlocked', () async {
      await provider.checkIn(latitude: 11.5564, longitude: 104.9282);

      // Attempting check-out during cooldown should fail
      expect(provider.isClockLocked, true);
      final blockedSuccess = await provider.checkOut(
        latitude: 11.5564,
        longitude: 104.9282,
      );
      expect(blockedSuccess, false);
      expect(provider.errorMessage, contains('Please wait'));
      expect(provider.isCheckedOut, false);

      // Once unlocked, check-out succeeds
      provider.unlockCooldownForTesting();
      expect(provider.isClockLocked, false);

      final success = await provider.checkOut(
        latitude: 11.5564,
        longitude: 104.9282,
      );
      expect(success, true);
      expect(provider.isCheckedIn, true);
      expect(provider.isCheckedOut, true);
      expect(provider.canClockIn, false);
      expect(provider.canClockOut, false);
      expect(provider.isCompleted, true);
    });

    test('zero duration lock provider allows immediate check-out', () async {
      final noLockProvider = AttendanceProvider(
        repository: repository,
        lockDurationSeconds: 0,
      );
      await noLockProvider.checkIn(latitude: 11.5564, longitude: 104.9282);
      expect(noLockProvider.isClockLocked, false);
      expect(noLockProvider.lockRemainingSeconds, 0);

      final success = await noLockProvider.checkOut(
        latitude: 11.5564,
        longitude: 104.9282,
      );
      expect(success, true);
      expect(noLockProvider.isCompleted, true);
    });

    test('failure updates errorMessage without crashing', () async {
      repository.shouldFail = true;
      final success = await provider.checkIn(
        latitude: 11.5564,
        longitude: 104.9282,
      );

      expect(success, false);
      expect(provider.errorMessage, contains('geofence'));
      expect(provider.isCheckedIn, false);
    });
  });
}
