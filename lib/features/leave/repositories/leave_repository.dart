import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/leave_balance_model.dart';

class LeaveRepository {
  final ApiClient client;

  LeaveRepository({required this.client});

  /// Fetch leave balances for the authenticated employee
  Future<List<LeaveBalanceModel>> getLeaveBalances({int? year}) async {
    final query = year != null ? '?year=$year' : '';
    final response = await client.get('${ApiConstants.leaveBalances}$query');
    final list = (response['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => LeaveBalanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
