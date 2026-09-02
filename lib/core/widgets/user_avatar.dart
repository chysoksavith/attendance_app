import 'package:flutter/material.dart';
import '../../features/auth/models/user_model.dart';
import '../theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 22,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final avatarUrl = user?.resolvedAvatarUrl;
    final initials = user?.initials ?? '?';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        backgroundColor ??
        (isDark ? AppColors.primary.withAlpha(40) : AppColors.primaryLight);
    final fgColor = foregroundColor ?? AppColors.primary;
    final fontSz = fontSize ?? (radius * 0.75);

    Widget fallback() {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Text(
          initials,
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.w700,
            fontSize: fontSz,
          ),
        ),
      );
    }

    Widget content;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      content = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
        child: ClipOval(
          child: Image.network(
            avatarUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallback(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return fallback();
            },
          ),
        ),
      );
    } else {
      content = fallback();
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
