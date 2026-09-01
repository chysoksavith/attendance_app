import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

/// A clean 6-digit OTP input using individual boxes.
class OtpInput extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final int length;

  const OtpInput({
    super.key,
    required this.controller,
    this.onCompleted,
    this.onChanged,
    this.length = 6,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _controllers = List.generate(widget.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    _syncValue();
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _syncValue();
    }
  }

  void _syncValue() {
    final otp = _controllers.map((c) => c.text).join();
    widget.controller.text = otp;
    widget.onChanged?.call(otp);

    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(index, event),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: _controllers[index].text.isNotEmpty
                    ? AppColors.primary.withAlpha(15)
                    : AppColors.inputFill,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: _controllers[index].text.isNotEmpty
                        ? AppColors.primary.withAlpha(100)
                        : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) => _onDigitChanged(index, value),
            ),
          ),
        );
      }),
    );
  }
}
