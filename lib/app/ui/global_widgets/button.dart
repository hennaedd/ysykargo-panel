import 'package:flutter/material.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';
import 'package:ysy_kargo_panel/core/base_state.dart';

class KargoButton extends StatefulWidget {
  const KargoButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isPassive,
    this.borderColor,
    this.width,
    this.icon,
    this.buttonColor,
    this.textStyle,
  });
  final String text;
  final Function onTap;
  final bool? isPassive;
  final Color? borderColor;
  final Color? buttonColor;
  final double? width;
  final Widget? icon;
  final TextStyle? textStyle;

  @override
  State<KargoButton> createState() => _KargoButtonState();
}

class _KargoButtonState extends State<KargoButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.isPassive == true) {
          return;
        } else {
          await widget.onTap();
        }
      },
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color:
              widget.isPassive == true ? ColorManager.instance.main_green.withOpacity(0.5) : widget.buttonColor ?? ColorManager.instance.main_green,
          borderRadius: BorderRadius.circular(10),
          border: widget.borderColor != null
              ? Border.all(
                  color: widget.borderColor!,
                  width: 1.5,
                )
              : null,
        ),
        padding: const EdgeInsets.all(13),
        child: widget.icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.icon!,
                  SizedBox(
                    width: Utility.dynamicWidthPixel(8),
                  ),
                  Center(
                    child: Text(
                      widget.text,
                      style: widget.textStyle ??
                          TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: Utility.dynamicTextSize(14),
                            color: ColorManager.instance.white,
                          ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  widget.text,
                  style: widget.textStyle ??
                      TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: Utility.dynamicTextSize(14),
                        color: ColorManager.instance.white,
                      ),
                ),
              ),
      ),
    );
  }
}
