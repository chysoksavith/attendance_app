import 'package:flutter/material.dart';
import '../../../core/i18n/app_translations.dart';

class ClockButton extends StatefulWidget {
  final bool isCheckedIn;
  final bool isCheckedOut;
  final bool isClocking;
  final VoidCallback onTap;

  const ClockButton({
    super.key,
    required this.isCheckedIn,
    required this.isCheckedOut,
    required this.isClocking,
    required this.onTap,
  });

  @override
  State<ClockButton> createState() => _ClockButtonState();
}

class _ClockButtonState extends State<ClockButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInteractable = !widget.isClocking && !widget.isCheckedOut;

    // Shift completed state (Accomplishment / Done)
    if (widget.isCheckedOut) {
      return _buildCompletedState(isDark);
    }

    // Active state: Clock Out
    if (widget.isCheckedIn) {
      return _buildActionButton(
        isDark: isDark,
        isInteractable: isInteractable,
        outerBg: isDark ? const Color(0xFF2E1C14) : const Color(0xFFFFF7ED),
        outerBorder: isDark ? const Color(0xFF5A2A18) : const Color(0xFFFFEDD5),
        gradientStart: const Color(0xFFF97316),
        gradientEnd: const Color(0xFFEA580C),
        shadowColor: const Color(0xFFEA580C).withAlpha(isDark ? 80 : 70),
        icon: Icons.logout_rounded,
        title: context.tr('clock_out'),
        subtitle: context.tr('tap_to_clock_out'),
      );
    }

    // Default state: Clock In
    return _buildActionButton(
      isDark: isDark,
      isInteractable: isInteractable,
      outerBg: isDark ? const Color(0xFF132038) : const Color(0xFFEFF6FF),
      outerBorder: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
      gradientStart: const Color(0xFF3B82F6),
      gradientEnd: const Color(0xFF1D4ED8),
      shadowColor: const Color(0xFF2563EB).withAlpha(isDark ? 90 : 70),
      icon: Icons.touch_app_rounded,
      title: context.tr('clock_in'),
      subtitle: context.tr('tap_to_clock_in'),
    );
  }

  Widget _buildActionButton({
    required bool isDark,
    required bool isInteractable,
    required Color outerBg,
    required Color outerBorder,
    required Color gradientStart,
    required Color gradientEnd,
    required Color shadowColor,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTapDown: isInteractable
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: isInteractable
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: isInteractable
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 182,
          height: 182,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: outerBg,
            border: Border.all(color: outerBorder, width: 1.5),
          ),
          child: Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [gradientStart, gradientEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: widget.isClocking
                ? const Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(45),
                        ),
                        child: Icon(icon, size: 28, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedState(bool isDark) {
    final emeraldBg = isDark
        ? const Color(0xFF063C2E)
        : const Color(0xFFF0FDF4);
    final emeraldBorder = isDark
        ? const Color(0xFF065F46)
        : const Color(0xFFBBF7D0);
    final innerBg = isDark ? const Color(0xFF0A4F3D) : const Color(0xFFDCFCE7);
    final innerBorder = isDark
        ? const Color(0xFF059669)
        : const Color(0xFF86EFAC);
    final emeraldAccent = isDark
        ? const Color(0xFF34D399)
        : const Color(0xFF059669);

    return Container(
      width: 182,
      height: 182,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: emeraldBg,
        border: Border.all(color: emeraldBorder, width: 1.5),
      ),
      child: Container(
        width: 148,
        height: 148,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: innerBg,
          border: Border.all(color: innerBorder, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: emeraldAccent,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 26,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('completed'),
              style: TextStyle(
                color: emeraldAccent,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.tr('all_done_today'),
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF6EE7B7)
                    : const Color(0xFF16A34A),
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
