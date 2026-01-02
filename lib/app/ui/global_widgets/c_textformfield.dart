import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KargoTextFormField extends StatefulWidget {
  const KargoTextFormField({
    super.key,
    this.hintText,
    required this.title,
    this.textEditingController,
    this.suffixIcon,
    this.obsecureText,
    this.titleStyle,
    this.minLines,
    this.prefixIcon,
    this.textInputType,
    this.hintStyle,
    this.mask,
    this.textInputAction,
    this.submitted,
    this.onChanged,
    this.onTap,
    this.enabled,
    this.readOnly,
    this.validation,
  });
  final String? hintText;
  final String? title;
  final TextEditingController? textEditingController;
  final String? Function(String?)? validation;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? obsecureText;
  final TextStyle? titleStyle;
  final int? minLines;
  final VoidCallback? onTap;
  final TextInputType? textInputType;
  final TextStyle? hintStyle;
  final List<TextInputFormatter>? mask;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? submitted;
  final ValueChanged<String>? onChanged;
  final bool? enabled;
  final bool? readOnly;

  @override
  State<KargoTextFormField> createState() => _KargoTextFormFieldState();
}

class _KargoTextFormFieldState extends State<KargoTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            child: SelectableText(
              widget.title!,
              style: widget.titleStyle ??
                  TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
            ),
          ),
        Container(
          height: widget.suffixIcon != null ? 48.h : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFF2F2F2),
          ),
          padding: EdgeInsets.only(
            left: 12.w,
            top: 13.h,
            bottom: 13.h,
            right: widget.suffixIcon != null ? 0 : 12.w,
          ),
          child: Center(
            child: TextFormField(
              validator: widget.validation,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.submitted,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.mask,
              minLines: widget.minLines ?? 1,
              maxLines: widget.minLines ?? 1,
              enabled: widget.enabled ?? true,
              readOnly: widget.readOnly ?? false,
              scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              obscureText: widget.obsecureText ?? false,
              controller: widget.textEditingController,
              keyboardType: widget.textInputType,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: widget.suffixIcon,
                prefixIcon: widget.prefixIcon,
                hintStyle: widget.hintStyle ??
                    TextStyle(
                      color: const Color(0xFF9F9F9F),
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                    ),
                hintText: widget.hintText,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
        ),
      ],
    );
  }
}
