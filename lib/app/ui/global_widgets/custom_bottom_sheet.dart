import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';
import 'package:ysy_kargo_panel/core/base_state.dart';

class CBottomSheet {
  static Future show({
    required Widget content,
    Color? bottomSheetColor,
    String? title,
    required BuildContext context,
    bool? withoutHeader,
    bool showCloseButton = true,
    isDismissible,
    Function? whenComplete,
    EdgeInsetsGeometry? padding,
    Widget? headerWidget,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: isDismissible ?? true,
      isScrollControlled: true,
      useRootNavigator: true,
      constraints: BoxConstraints(
        maxHeight: Utility.dynamicHeight(0.9),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      backgroundColor: bottomSheetColor ?? ColorManager.instance.white,
      builder: (context) {
        return Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: SafeArea(
            child: Padding(
              padding: padding ??
                  EdgeInsets.only(
                    left: Utility.dynamicWidthPixel(16),
                    right: Utility.dynamicWidthPixel(16),
                    top: Utility.dynamicWidthPixel(24),
                  ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  withoutHeader != true
                      ? Padding(
                          padding: EdgeInsets.only(
                            bottom: Utility.dynamicWidthPixel(16),
                          ),
                          child: SizedBox(
                            height: Utility.dynamicWidthPixel(36),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                headerWidget ?? const SizedBox(),
                                Expanded(
                                  child: AutoSizeText(
                                    title ?? "",
                                    style: TextStyle(
                                      fontSize: Utility.dynamicTextSize(18),
                                      fontWeight: FontWeight.w600,
                                      color: ColorManager.instance.primary,
                                    ),
                                  ),
                                ),
                                if (showCloseButton != false) const CloseIconForBottomSheet(),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                  Flexible(child: content),
                ],
              ),
            ),
          ),
        );
      },
    )..whenComplete(
        () {
          if (whenComplete != null) {
            whenComplete();
          }
        },
      );
  }
}

class CloseIconForBottomSheet extends StatelessWidget {
  final Color? closeIconColor;
  const CloseIconForBottomSheet({
    super.key,
    this.closeIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: Utility.dynamicWidthPixel(36),
        height: Utility.dynamicWidthPixel(36),
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorManager.instance.primary,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.close,
            size: 21,
            color: closeIconColor ?? ColorManager.instance.primary,
          ),
        ),
      ),
    );
  }
}
