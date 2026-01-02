import 'package:flutter/material.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';
import 'package:ysy_kargo_panel/core/application_constants.dart';
import 'package:ysy_kargo_panel/core/theme.dart';

class AppThemeDark extends AppTheme {
  static AppThemeDark? _instance;
  static AppThemeDark get instance {
    _instance ??= AppThemeDark._init();
    return _instance!;
  }

  AppThemeDark._init();

  @override
  ThemeData get theme => ThemeData(
        visualDensity: VisualDensity.standard,
        splashFactory: NoSplash.splashFactory,
        scaffoldBackgroundColor: ColorManager.instance.black,
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
          cursorColor: ColorManager.instance.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: ColorManager.instance.black,
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