import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ysy_kargo_panel/app/routes/route_manager.dart';
import 'package:ysy_kargo_panel/app/theme/app_theme_dark.dart';
import 'package:ysy_kargo_panel/app/theme/app_theme_light.dart';
import 'package:ysy_kargo_panel/core/application_constants.dart';
import 'package:ysy_kargo_panel/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (_, context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: GetMaterialApp(
          enableLog: kDebugMode,
          navigatorKey: Get.key,
          theme: AppThemeLight.instance.theme,
          darkTheme: AppThemeDark.instance.theme,
          getPages: RouteManager.instance.appPages,
          initialRoute: RouteManager.instance.loginPage,
          logWriterCallback: localLogWriter,
          title: 'YSYKARGO PANEL',
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.cupertino,
          opaqueRoute: Get.isOpaqueRouteDefault,
          popGesture: Get.isPopGestureEnable,
          transitionDuration: Get.defaultTransitionDuration,
          locale: ApplicationConstants.instance.locale,
          fallbackLocale: ApplicationConstants.instance.fallbackLocale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: ApplicationConstants.instance.supportedLocales,
        ),
      ),
    );
  }

  void localLogWriter(String text, {bool isError = false}) {
    if (kDebugMode) {
      debugPrint(text);
    }
  }
}
