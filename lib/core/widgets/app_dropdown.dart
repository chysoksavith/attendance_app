import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final IconData? icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.icon,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
