import 'package:flutter/material.dart';
import 'package:protips/pages/main_page.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';
import 'auxiliar/log.dart';

void main() {
  // Para a biblioteca de cobrança do Google Play 2.0 no Android, é obrigatório ligar
  // como parte da inicialização do aplicativo.
  // InAppPurchaseConnection.enablePendingPurchases();
  runApp(Main());
}

class Main extends StatelessWidget {
  static const String TAG = 'Main';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: MyResources.APP_NAME,
      theme: ThemeData(
          primaryColorLight: MyTheme.primaryLight(),
          primaryColorDark: MyTheme.primaryDark(),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: MyTheme.primaryDark()
          ),
          tabBarTheme: TabBarTheme(),
          primaryColor: MyTheme.primary(),
          accentColor: MyTheme.accent(),
          backgroundColor: MyTheme.textColor(),
        fontFamily: 'Century',
        textTheme: TextTheme(
            headline6: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: 14),
        ),
      ).copyWith(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder()
          }
        )
      ),
//      routes: routes,
      home: MainPage(),
      builder: (context, child) => Scaffold(
        key: Log.scaffKey,
          body: child
      ),// usado pra funcionar o SnackBar global
      //getInitPage
      /*home: FutureBuilder<FirebaseUser> (
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

