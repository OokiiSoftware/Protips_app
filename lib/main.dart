import 'dart:ui';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/preferences.dart';
import 'package:protips/pages/login_page.dart';
import 'package:protips/pages/main_page.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auxiliar/aplication.dart';
import 'auxiliar/import.dart';
import 'auxiliar/log.dart';

void main() => runApp(Main());

class Main extends StatefulWidget {
  @override
  MyState createState() => MyState();
}

class MyState extends State<Main> {

  //region variaveis
  static const String TAG = 'Main';
  static const int FIREBASE_USER_NULL = 1;
  static const int TUDO_OK = 4;

  static const locales = [const Locale('pt'), const Locale('en')];

  static int userStatus = 0;
  //endregion

  @override
  void initState() {
    super.initState();
    init();
    loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: setTheme,
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          theme: theme,
          title: MyResources.APP_NAME,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [GlobalMaterialLocalizations.delegate],
          supportedLocales: locales,
          builder: bodyBuilder,
          home: body,
        );
      }
    );
  }

  //region metodos

  init() async {
    await Aplication.init();
    var result = await FirebasePro.init();
    await OfflineData.readOfflineData();
    bool fUserNull = result == FirebaseInitResult.fUserNull;

    setState(() {
      userStatus = fUserNull ? FIREBASE_USER_NULL : TUDO_OK;
    });
  }

  Widget get body {
    switch (userStatus) {
      case TUDO_OK:
        return MainPage();
        break;
      case FIREBASE_USER_NULL:
        return LoginPage();
        break;
      default:
        return Layouts.splashScreen();
    }
  }

  Widget bodyBuilder(context, child) => Scaffold(
      key: Log.scaffKey, // usado pra funcionar o SnackBar global
      body: child
  );

  ThemeData setTheme(Brightness brightness) {
    bool darkModeOn = brightness == Brightness.dark;
    MyTheme.darkModeOn = darkModeOn;

    return ThemeData(
      brightness: brightness,
      // primaryColorLight: MyTheme.primaryLight,
      // primaryColorDark: MyTheme.primaryDark,
      primaryColor: darkModeOn ? null : MyTheme.primary,
      accentColor: MyTheme.accent,
      cardTheme: CardTheme(
          color: MyTheme.cardColor
      ),
      textTheme: TextTheme(
        bodyText2: TextStyle(
            fontSize: 14,
            color: MyTheme.textColor
        ),
      ),
      tabBarTheme: TabBarTheme(),
      tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
              color: MyTheme.primaryDark
          )
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: darkModeOn ? Colors.grey[800] : MyTheme.primaryDark
      ),
      fontFamily: 'Century',
    )..copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
            }
        )
    );
  }

  void loadTheme() async {
    Preferences.instance = await SharedPreferences.getInstance();
    var savedTheme = Preferences.getString(PreferencesKey.THEME, padrao: Arrays.thema[0]);

    Brightness brightness = MyTheme.getBrilho(savedTheme);
    setTheme(brightness);
  }

  //endregion
}

