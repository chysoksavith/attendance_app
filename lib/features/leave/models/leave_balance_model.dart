class LeaveTypeModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final bool isPaid;
  final bool requiresApproval;
  final bool requiresAttachment;
  final int? maxDaysPerRequest;
  final int? minNoticeDays;

  const LeaveTypeModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.isPaid = true,
    this.requiresApproval = true,
    this.requiresAttachment = false,
    this.maxDaysPerRequest,
    this.minNoticeDays,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      isPaid: json['is_paid'] as bool? ?? true,
      requiresApproval: json['requires_approval'] as bool? ?? true,
      requiresAttachment: json['requires_attachment'] as bool? ?? false,
      maxDaysPerRequest: json['max_days_per_request'] as int?,
      minNoticeDays: json['min_notice_days'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'is_paid': isPaid,
      'requires_approval': requiresApproval,
      'requires_attachment': requiresAttachment,
      'max_days_per_request': maxDaysPerRequest,
      'min_notice_days': minNoticeDays,
    };
  }
}

class LeaveBalanceModel {
  final int id;
  final int userId;
  final int leaveTypeId;
  final int year;
  final double allocatedDays;
  final double usedDays;
  final double pendingDays;
  final double carryoverDays;
  final double adjustmentDays;
  final double remainingDays;
  final double totalEntitledDays;
  final String? expiresAt;
  final LeaveTypeModel? leaveType;

  const LeaveBalanceModel({
    required this.id,
    required this.userId,
    required this.leaveTypeId,
    required this.year,
    required this.allocatedDays,
    required this.usedDays,
    required this.pendingDays,
    required this.carryoverDays,
    required this.adjustmentDays,
    required this.remainingDays,
    required this.totalEntitledDays,
    this.expiresAt,
    this.leaveType,
  });

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      leaveTypeId: json['leave_type_id'] as int? ?? 0,
      year: json['year'] as int? ?? DateTime.now().year,
      allocatedDays: (json['allocated_days'] as num?)?.toDouble() ?? 0.0,
      usedDays: (json['used_days'] as num?)?.toDouble() ?? 0.0,
      pendingDays: (json['pending_days'] as num?)?.toDouble() ?? 0.0,
      carryoverDays: (json['carryover_days'] as num?)?.toDouble() ?? 0.0,
      adjustmentDays: (json['adjustment_days'] as num?)?.toDouble() ?? 0.0,
      remainingDays: (json['remaining_days'] as num?)?.toDouble() ?? 0.0,
      totalEntitledDays:
          (json['total_entitled_days'] as num?)?.toDouble() ?? 0.0,
      expiresAt: json['expires_at'] as String?,
      leaveType:
          json['leave_type'] != null &&
              json['leave_type'] is Map<String, dynamic>
          ? LeaveTypeModel.fromJson(json['leave_type'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'leave_type_id': leaveTypeId,
      'year': year,
      'allocated_days': allocatedDays,
      'used_days': usedDays,
      'pending_days': pendingDays,
      'carryover_days': carryoverDays,
      'adjustment_days': adjustmentDays,
      'remaining_days': remainingDays,
      'total_entitled_days': totalEntitledDays,
      'expires_at': expiresAt,
      'leave_type': leaveType?.toJson(),
    };
  }

  /// Helper to format days nicely (e.g. "18" or "18.5")
  String get formattedRemainingDays {
    if (remainingDays == remainingDays.roundToDouble()) {
      return remainingDays.toInt().toString();
    }
    return remainingDays.toStringAsFixed(1);
  }

  String get leaveTypeName => leaveType?.name ?? 'Leave';
}
