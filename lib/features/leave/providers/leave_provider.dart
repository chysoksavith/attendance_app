import 'package:flutter/foundation.dart';
import '../models/leave_balance_model.dart';
import '../repositories/leave_repository.dart';

enum LeaveViewState { initial, loading, success, error }

/// State management for employee leave balances.
class LeaveProvider extends ChangeNotifier {
  final LeaveRepository repository;

  LeaveProvider({required this.repository});

  // -- State -----------------------------------------------------------------

  LeaveViewState _state = LeaveViewState.initial;
  LeaveViewState get state => _state;

  List<LeaveBalanceModel> _balances = [];
  List<LeaveBalanceModel> get balances => _balances;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _selectedYear = DateTime.now().year;
  int get selectedYear => _selectedYear;

  // -- Actions ---------------------------------------------------------------

  /// Fetch leave balances for a specific year (defaults to current selected year)
  Future<void> fetchBalances({int? year, bool isRefresh = false}) async {
    if (year != null) {
      _selectedYear = year;
    }

    if (!isRefresh) {
      _state = LeaveViewState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _balances = await repository.getLeaveBalances(year: _selectedYear);
      _state = LeaveViewState.success;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = LeaveViewState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Refresh leave balances
  Future<void> refresh() => fetchBalances(isRefresh: true);

  /// Change year filter
  void changeYear(int year) {
    if (_selectedYear != year) {
      _selectedYear = year;
      fetchBalances(year: year);
    }
  }
}
