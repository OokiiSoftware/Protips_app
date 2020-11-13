import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:protips/res/strings.dart';

class _ColorsConst {
  static Color get primary => Color.fromRGBO(0, 123, 164, 1);
  static Color get primaryLight => Color.fromRGBO(70, 181, 190, 1);
  static Color get primaryLight2 => Color.fromRGBO(156, 215, 221, 1);
  static Color get primaryDark => Color.fromRGBO(0, 106, 142, 1);
  static Color get dark => Color.fromRGBO(4, 68, 118, 1);
  static Color get dark2 => Color.fromRGBO(2, 37, 64, 1);
  static Color get accent => Color.fromRGBO(255, 201, 9, 1);
  static Color get sombra => Colors.white;
  static Color get tintError => Colors.deepOrangeAccent;
  static Color get textError => Color.fromRGBO(245, 0, 0, 1);
  // static  Color googlePay = Color.fromRGBO(0, 0, 0, 1);
}

class _ColorsLight {
  static const Color card = Color.fromRGBO(150, 150, 150, 1);
  static const Color card2 = Colors.black26;
  static Color get textSubtitle => Colors.black54;
  static Color transparentColor(double alpha) => Color.fromRGBO(0, 0, 0, alpha);
}
class _ColorsDark {
  static const Color card = Color.fromRGBO(33, 33, 33, 1);
  static const Color card2 = Color.fromRGBO(66, 66, 66, 1);
  static Color get textSubtitle => Colors.white54;
  static Color transparentColor(double alpha) => Color.fromRGBO(255, 255, 255, alpha);
}

class MyTheme {
  static bool darkModeOn = false;

  static Color get primary => _ColorsConst.primary;
  static Color get primaryLight => _ColorsConst.primaryLight;
  static Color get primaryLight2 => _ColorsConst.primaryLight2;
  static Color get primaryDark => _ColorsConst.primaryDark;
  static Color get dark => _ColorsConst.dark;
  static Color get dark2 => _ColorsConst.dark2;
  static Color get accent => _ColorsConst.accent;
  static Color get sombra => _ColorsConst.sombra;
  static Color get tintColorError => _ColorsConst.tintError;
  static Color get textColorError => _ColorsConst.textError;
  static Color transparentColor([double alpha = 0]) => darkModeOn ?
  _ColorsDark.transparentColor(alpha) : _ColorsLight.transparentColor(alpha);

  static Color get textColorSpecial => darkModeOn ? _ColorsConst.accent : _ColorsConst.primary;
  static Color get textColor => darkModeOn ? _ColorsDark.textSubtitle : _ColorsLight.textSubtitle;

  static Color get cardColor => darkModeOn ? _ColorsDark.card : _ColorsLight.card;
  static Color get cardColor2 => darkModeOn ? _ColorsDark.card2 : _ColorsLight.card2;
  static Color get cardSpecial => darkModeOn ? _ColorsDark.card : _ColorsConst.primary;

  static Brightness getBrilho(String theme) {
    Brightness brightness;
    if (theme == Arrays.thema[0])// Sistema
      brightness = SchedulerBinding.instance.window.platformBrightness;
    else if (theme == Arrays.thema[1])// Claro
      brightness = Brightness.light;
    else
      brightness = Brightness.dark;
    return brightness;
  }
}
