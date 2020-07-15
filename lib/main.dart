import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/pages/about_page.dart';
import 'package:protips/pages/cadastro_page.dart';
import 'package:protips/pages/crop_page.dart';
import 'package:protips/pages/main_page.dart';
import 'package:protips/pages/login_page.dart';
import 'package:protips/pages/meu_perfil_page.dart';
import 'package:protips/pages/notificacoes_page.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/pages/post_page.dart';
import 'package:protips/pages/recuperar_senha_page.dart';
import 'package:protips/res/resources.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  static const String TAG = 'Main';
  final routes = <String, WidgetBuilder> {
    LoginPage.tag: (context) => LoginPage(),
    MainPage.tag: (context) => MainPage(),
    PostPage.tag: (context) => PostPage(),
    AboutPage.tag: (context) => AboutPage(),
    PerfilPage.tag: (context) => PerfilPage(),
    CadastroPage.tag: (context) => CadastroPage(),
    MeuPerfilPage.tag: (context) => MeuPerfilPage(),
    CropImagePage.tag: (context) => CropImagePage(),
    NotificacoesPage.tag: (context) => NotificacoesPage(),
    RecuperarSenhaPage.tag: (context) => RecuperarSenhaPage(),
  };

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
      routes: routes,
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