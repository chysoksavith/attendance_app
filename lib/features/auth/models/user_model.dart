import 'attachment_model.dart';

/// Mirrors the ERP's `Api\UserResource` response shape.
class UserModel {
  final int id;
  final int? companyId;
  final int? departmentId;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? email;
  final String? phoneNumber;
  final String? userType;
  final bool isActive;
  final bool hasMobileAccess;
  final String? birthDate;
  final List<AttachmentModel> attachments;

  const UserModel({
    required this.id,
    this.companyId,
    this.departmentId,
    required this.name,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.email,
    this.phoneNumber,
    this.userType,
    this.isActive = true,
    this.hasMobileAccess = true,
    this.birthDate,
    this.attachments = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      companyId: json['company_id'] as int?,
      departmentId: json['department_id'] as int?,
      name: json['name'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      userType: json['user_type'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      hasMobileAccess: json['has_mobile_access'] as bool? ?? true,
      birthDate: json['birth_date'] as String?,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'department_id': departmentId,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'email': email,
      'phone_number': phoneNumber,
      'user_type': userType,
      'is_active': isActive,
      'has_mobile_access': hasMobileAccess,
      'birth_date': birthDate,
      'attachments': attachments.map((e) => e.toJson()).toList(),
    };
  }

  /// Initials for avatar fallback (e.g. "JD" for "John Doe").
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
