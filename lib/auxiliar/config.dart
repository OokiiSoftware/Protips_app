import 'package:protips/auxiliar/preferences.dart';

class Config {
  static bool get postAvancado => Preferences.getBool(PreferencesKey.POST_AVANCADO, padrao: true);
  static set postAvancado(bool value) => Preferences.setBool(PreferencesKey.POST_AVANCADO, value);
}

class RunTime {
  static bool semInternet = false;
}