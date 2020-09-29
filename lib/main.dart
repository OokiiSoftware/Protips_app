import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:protips/pages/main_page.dart';
import 'package:protips/res/resources.dart';

void main() {
  // Para a biblioteca de cobrança do Google Play 2.0 no Android, é obrigatório ligar
  // como parte da inicialização do aplicativo.
  InAppPurchaseConnection.enablePendingPurchases();
  runApp(Main());
}

class Main extends StatelessWidget {
  static const String TAG = 'Main';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: MyStrings.APP_NAME,
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
      ),
//      routes: routes,
      home: MainPage(),
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