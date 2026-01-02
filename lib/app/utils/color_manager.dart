import 'package:flutter/material.dart';

class ColorManager {
  static final ColorManager _instace = ColorManager._init();
  static ColorManager get instance {
    return _instace;
  }

  ColorManager._init();

  Color get white => const Color(0xFFFFFFFF);
  Color get black => const Color(0xFF111A18);
  Color get transparent => const Color(0x00000000);
  Color get darkGray => const Color(0xFF292D36);
  Color get softGrayBg => const Color(0xffF6F8FF);
  Color get borderGray => const Color(0xffE3E5ED);
  Color get differentGrey => const Color(0xffE8EAF4);
  Color get lightGreen => const Color(0xff3DB02D);
  Color get greyGri => const Color(0xff616161);
  Color get primary => const Color(0xFF1e2f41);
  Color get secondary => const Color(0xFFFFFAED);
  Color get grayBorder => const Color(0xFFF0F0F0);
  Color get greyBG => const Color(0xFFF2F2F2);
  Color get main_green => const Color(0xFF2B9846);
  Color get passive_gray => const Color(0xFF9F9F9F);
  Color get light_gray => const Color(0xFFF2F2F2);
  Color get tertiary => const Color(0xFFEEEEEE);
  Color get dark_blue => const Color(0xFF45586B);
  Color get black60 => const Color(0xFF666666);
  Color get secondaryF7 => const Color(0xFFF7F7F7);
  Color get night_rainy1 => const Color(0xff183C43);
  Color get night_rainy2 => const Color(0xff192838);
  Color get night_open1 => const Color(0xff191C1f);
  Color get night_open2 => const Color(0xff0f1012);
  Color get night_foggy1 => const Color(0xff1f2327);
  Color get night_foggy2 => const Color(0xff171a1d);
  Color get night_snowy1 => const Color(0xff3c4752);
  Color get night_snowy2 => const Color(0xff1b2835);
  Color get sun_born_rainy1 => const Color(0xff6d6fc3);
  Color get sun_born_rainy2 => const Color(0xffda897b);
  Color get sun_rainy1 => const Color(0xff3f757e);
  Color get sun_rainy2 => const Color(0xff485e74);
  Color get sun_open_weather1 => const Color(0xff519be6);
  Color get sun_open_weather2 => const Color(0xff3d7ab8);
  Color get sun_foggy1 => const Color(0xffadbdcc);
  Color get sun_foggy2 => const Color(0xff788694);
  Color get sun_snow1 => const Color(0xffb8cee3);
  Color get sun_snow2 => const Color(0xff7391ad);
  Color get profile_bg => const Color(0xffd9d9d9);
  Color get unselectedTab => const Color(0xFF7A7A7A);
  Color get orange => const Color(0xffff5a00);

  // Status colors for orders
  Color get statusActive => const Color(0xffff5a00); // Turuncu - Aktif gönderi
  Color get statusAssigned => const Color(0xffFFD700); // Sarı - Kuryeye atandı
  Color get statusDelivered => const Color(0xff28A745); // Yeşil - Teslim edildi
  Color get statusPending => const Color(0xff6C757D); // Gri - Beklemede

  // User status colors
  Color get userBanned => const Color(0xffDC3545); // Kırmızı - Banlı
  Color get userPending => const Color(0xffFFC107); // Sarı - Onay Bekliyor
  Color get userApproved => const Color(0xff28A745); // Yeşil - Onaylı
  Color get userRejected => const Color(0xffDC3545); // Kırmızı - Reddedildi
}
