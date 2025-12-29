import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool canToggleObscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.canToggleObscure = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final textSecondary = AppColors.textSecondaryOf(context);
    final bg = AppColors.cardOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.fieldLabelOf(context)),
        const SizedBox(height: 8),

        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: widget.canToggleObscure ? _isObscured : widget.obscureText,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.subtitleOf(context).copyWith(
              color: textSecondary.withOpacity(0.5),
            ),
            filled: true,
            fillColor: bg,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 14,
            ),
            suffixIcon: widget.canToggleObscure
                ? IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
                color: textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() => _isObscured = !_isObscured);
              },
            )
                : widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderSoftOf(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderSoftOf(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade400,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red.shade400,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
