import 'package:flutter/cupertino.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';
import 'package:ysy_kargo_panel/core/base_state.dart';

class CustomCupertinoPicker {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onConfirm,
    required List<Widget> children,
    double itemExtent = 40.0,
    ValueChanged<int>? onSelectedItemChanged,
    int? initialItemIndex,
  }) {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: ColorManager.instance.borderGray,
                border: Border(
                  bottom: BorderSide(
                    color: ColorManager.instance.borderGray,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CupertinoButton(
                    child: Text(
                      'Vazgeç',
                      style: TextStyle(fontSize: Utility.dynamicTextSize(14), color: ColorManager.instance.darkGray, fontFamily: 'Regular'),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    onPressed: () {
                      onConfirm();
                      Navigator.of(context).pop();
                    },
                    padding: EdgeInsets.symmetric(
                      horizontal: Utility.dynamicWidthPixel(16),
                      vertical: Utility.dynamicWidthPixel(5),
                    ),
                    child: Text(
                      'Tamam',
                      style: TextStyle(fontSize: Utility.dynamicTextSize(14), color: ColorManager.instance.darkGray, fontFamily: 'Regular'),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: Utility.dynamicWidthPixel(180),
              color: ColorManager.instance.white,
              child: CupertinoPicker(
                itemExtent: itemExtent,
                scrollController: FixedExtentScrollController(initialItem: initialItemIndex ?? 0),
                onSelectedItemChanged: onSelectedItemChanged ?? (int index) {},
                children: children,
              ),
            ),
          ],
        );
      },
    );
  }
}
