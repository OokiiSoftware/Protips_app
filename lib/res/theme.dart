import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyColors {
  static const Color primary = Color.fromRGBO(0, 123, 164, 1);
  static const Color primaryLight = Color.fromRGBO(70, 181, 190, 1);
  static const Color primaryLight2 = Color.fromRGBO(156, 215, 221, 1);
  static const Color primaryDark = Color.fromRGBO(0, 106, 142, 1);
  static const Color accent = Color.fromRGBO(255, 201, 9, 1);
  static const Color background = Colors.white;
  static Color transparentColor(double alpha) => Color.fromRGBO(0, 0, 0, alpha);

  static  Color textLight = Colors.white;
  static  Color textLightInvert(double alfa) => Color.fromRGBO(0, 0, 0, alfa);
  static  Color textColorError(double alfa) => Color.fromRGBO(245, 0, 0, alfa);
  static  Color textSubtitleLight = Colors.white54;
  static  Color tintLight = Colors.white;
  static  Color tintLight2 = Color.fromRGBO(222, 229, 237, 1);

  static  Color googlePay = Color.fromRGBO(0, 0, 0, 1);
}

class MyTheme {
  static Color primary() => MyColors.primary;
  static Color primaryLight() => MyColors.primaryLight;
  static Color primaryLight2() => MyColors.primaryLight2;
  static Color primaryDark() => MyColors.primaryDark;
  static Color accent() => MyColors.accent;

  static Color textColor() => MyColors.textLight;
  static Color textColorInvert([double alfa = 1]) => MyColors.textLightInvert(alfa);
  static Color textColorError([double alfa = 1]) => MyColors.textColorError(alfa);
  static Color textSubtitleColor() => MyColors.textSubtitleLight;
  static Color tintColor() => MyColors.tintLight;
  static Color tintColor2() => MyColors.tintLight2;
  static Color backgroundColor() => MyColors.background;
  static Color transparentColor([double alpha = 0]) => MyColors.transparentColor(alpha);
}
