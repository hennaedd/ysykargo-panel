import 'package:ysy_kargo_panel/app/utils/color_manager.dart';
import 'package:ysy_kargo_panel/core/application_constants.dart';
import 'package:ysy_kargo_panel/core/theme.dart';
import 'package:flutter/material.dart';

class AppThemeLight extends AppTheme {
  static AppThemeLight? _instance;
  static AppThemeLight get instance {
    _instance ??= AppThemeLight._init();
    return _instance!;
  }

  AppThemeLight._init();
  @override
  ThemeData get theme => ThemeData(
        visualDensity: VisualDensity.standard,
        splashFactory: NoSplash.splashFactory,
        scaffoldBackgroundColor: ColorManager.instance.white,
        highlightColor: ColorManager.instance.transparent,
        focusColor: ColorManager.instance.transparent,
        hoverColor: ColorManager.instance.transparent,
        splashColor: ColorManager.instance.transparent,
        shadowColor: ColorManager.instance.transparent,
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: ColorManager.instance.transparent,
        ),
        fontFamily: ApplicationConstants.instance.fontFamily,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: ColorManager.instance.darkGray,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorManager.instance.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: ColorManager.instance.black),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
