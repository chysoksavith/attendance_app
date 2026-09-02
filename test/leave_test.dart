import 'package:flutter_test/flutter_test.dart';
import 'package:attendance/core/network/api_client.dart';
import 'package:attendance/core/storage/token_storage.dart';
import 'package:attendance/features/leave/models/leave_balance_model.dart';
import 'package:attendance/features/leave/providers/leave_provider.dart';
import 'package:attendance/features/leave/repositories/leave_repository.dart';

class FakeLeaveRepository extends LeaveRepository {
  FakeLeaveRepository()
    : super(client: ApiClient(tokenStorage: TokenStorage()));

  bool shouldFail = false;
  List<LeaveBalanceModel> mockBalances = [];

  @override
  Future<List<LeaveBalanceModel>> getLeaveBalances({int? year}) async {
    if (shouldFail) {
      throw Exception('Network connection timed out.');
    }
    return mockBalances;
  }
}

void main() {
  group('Leave Models', () {
    test('LeaveBalanceModel parses JSON accurately', () {
      final json = {
        'id': 1,
        'user_id': 10,
        'leave_type_id': 2,
        'year': 2026,
        'allocated_days': 18.0,
        'used_days': 3.0,
        'pending_days': 1.0,
        'carryover_days': 0.0,
        'adjustment_days': 0.0,
        'remaining_days': 14.0,
        'total_entitled_days': 18.0,
        'expires_at': '2026-12-31',
        'leave_type': {
          'id': 2,
          'name': 'Annual Leave',
          'slug': 'annual-leave',
          'description': 'Regular paid annual leave',
          'is_paid': true,
          'requires_approval': true,
          'requires_attachment': false,
        },
      };

      final model = LeaveBalanceModel.fromJson(json);
      expect(model.id, 1);
      expect(model.userId, 10);
      expect(model.year, 2026);
      expect(model.remainingDays, 14.0);
      expect(model.formattedRemainingDays, '14');
      expect(model.leaveTypeName, 'Annual Leave');
      expect(model.leaveType?.isPaid, true);
    });

    test('LeaveBalanceModel handles fractional days', () {
      final json = {
        'id': 2,
        'user_id': 10,
        'leave_type_id': 3,
        'year': 2026,
        'allocated_days': 7.0,
        'used_days': 1.5,
        'pending_days': 0.0,
        'carryover_days': 0.0,
        'adjustment_days': 0.0,
        'remaining_days': 5.5,
        'total_entitled_days': 7.0,
      };

      final model = LeaveBalanceModel.fromJson(json);
      expect(model.remainingDays, 5.5);
      expect(model.formattedRemainingDays, '5.5');
    });
  });

  group('LeaveProvider State Machine', () {
    late FakeLeaveRepository repository;
    late LeaveProvider provider;

    setUp(() {
      repository = FakeLeaveRepository();
      provider = LeaveProvider(repository: repository);
    });

    test('initial state is correct', () {
      expect(provider.state, LeaveViewState.initial);
      expect(provider.balances.isEmpty, true);
      expect(provider.errorMessage, isNull);
    });

    test('fetches balances successfully', () async {
      repository.mockBalances = [
        const LeaveBalanceModel(
          id: 1,
          userId: 10,
          leaveTypeId: 1,
          year: 2026,
          allocatedDays: 18,
          usedDays: 2,
          pendingDays: 0,
          carryoverDays: 0,
          adjustmentDays: 0,
          remainingDays: 16,
          totalEntitledDays: 18,
          leaveType: LeaveTypeModel(
            id: 1,
            name: 'Annual Leave',
            slug: 'annual-leave',
          ),
        ),
      ];

      await provider.fetchBalances();

      expect(provider.state, LeaveViewState.success);
      expect(provider.balances.length, 1);
      expect(provider.balances.first.remainingDays, 16);
      expect(provider.errorMessage, isNull);
    });

    test('handles failure gracefully', () async {
      repository.shouldFail = true;

      await provider.fetchBalances();

      expect(provider.state, LeaveViewState.error);
      expect(provider.errorMessage, contains('timed out'));
      expect(provider.balances.isEmpty, true);
    });
  });
}
