import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/constants/api_constants.dart';
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
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    bool parseBool(dynamic v, {bool defaultValue = true}) {
      if (v == null) return defaultValue;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v == '1' || v.toLowerCase() == 'true';
      return defaultValue;
    }

    return UserModel(
      id: parseInt(json['id']) ?? 0,
      companyId: parseInt(json['company_id']),
      departmentId: parseInt(json['department_id']),
      name: json['name']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      userType: json['user_type']?.toString(),
      isActive: parseBool(json['is_active'], defaultValue: true),
      hasMobileAccess: parseBool(json['has_mobile_access'], defaultValue: true),
      birthDate: json['birth_date']?.toString(),
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

  /// Resolves the full URL for the avatar, converting relative paths and localhost for Android emulator.
  String? get resolvedAvatarUrl {
    if (avatarUrl == null || avatarUrl!.trim().isEmpty) return null;
    var url = avatarUrl!.trim();
    if (url.startsWith('/')) {
      return '${ApiConstants.baseUrl}$url';
    }
    if (!kIsWeb && Platform.isAndroid) {
      if (url.contains('localhost:8000')) {
        url = url.replaceAll('localhost:8000', '10.0.2.2:8000');
      } else if (url.contains('127.0.0.1:8000')) {
        url = url.replaceAll('127.0.0.1:8000', '10.0.2.2:8000');
      }
    }
    return url;
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
