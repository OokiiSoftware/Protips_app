import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:protips/pages/main_page.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';
import 'auxiliar/log.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  static const String TAG = 'Main';

  @override
  Widget build(BuildContext context) {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    MyTheme.darkModeOn = brightness == Brightness.dark;

    return MaterialApp(
      title: MyResources.APP_NAME,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [
        const Locale('pt'),
        const Locale('en'),
      ],
      theme: ThemeData(
        brightness: brightness,
        primaryColorLight: MyTheme.primaryLight,
        primaryColorDark: MyTheme.primaryDark,
        primaryColor: MyTheme.primary,
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
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: MyTheme.primaryDark
          ),
        fontFamily: 'Century',
      ).copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder()
          }
        )
      ),
      home: MainPage(),
      builder: (context, child) => Scaffold(
          key: Log.scaffKey, // usado pra funcionar o SnackBar global
          body: child
      ),
      /*
      //getInitPage
      home: FutureBuilder<FirebaseUser> (
        future: getFirebase.auth().currentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              if (snapshot.hasError || snapshot.data == null) {
                Log.d(TAG, 'build', 'Deslogado');
                return LoginPage();
              } else {
                return MainPage();
              }
          }
        },
      ),*/
    );
  }
}

