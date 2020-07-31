import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/pages/cadastro_page.dart';
import 'package:protips/pages/main_page.dart';
import 'package:protips/pages/recuperar_senha_page.dart';
import 'package:protips/res/resources.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginPage extends StatefulWidget{
  static const String tag = 'LoginPage';
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<LoginPage> {
  //region Variaveis
  static const String TAG = 'LoginPage';

  bool emailNaoEncontrado = false;
  bool emailInvalido = false;
  bool senhaIncorreta = false;

  TextEditingController cSenha = TextEditingController();
  TextEditingController cEmail = TextEditingController();

  double progressBarValue = 0;
  LinearProgressIndicator progressBar;

  DatabaseReference reference;

  //endregion

  //region overrides

  @override
  void initState() {
//    SystemChrome.setEnabledSystemUIOverlays([]);// Deixa o app em FuulScreen
    super.initState();
    _checkGoogleServices();
    _loadUltimoEmail();
  }

  @override
  Widget build(BuildContext context) {
    Log.setToast = context;
    //region Variaveis
    var backgorundColor = MyTheme.primaryLight();
    var iconColor = MyTheme.primaryDark();
    var iconColorError = MyTheme.textColorError();
    double widthScreen = MediaQuery.of(context).size.width / 1.3; //Tamanho da tela
    double itemHeight = 50;

    var itemBorder = OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none));

    var itemDecorationError = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: backgorundColor,
        boxShadow: [
          BoxShadow(color: Colors.red, blurRadius: 1),
          BoxShadow(color: Colors.red, blurRadius: 1),
        ]
    );
    var itemDecoration = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: backgorundColor,
        boxShadow: [
          BoxShadow(color: Colors.white, blurRadius: 1),
          BoxShadow(color: Colors.white, blurRadius: 1),
        ]
    );

    var itemContentPadding = EdgeInsets.fromLTRB(0, 0, 12, 0);

    var itemPadding = EdgeInsets.symmetric(horizontal: 15);
    var itemHintStyle = TextStyle(color: MyTheme.primary());
    var itemLabeErrorlStyle = TextStyle(color: Colors.red);
    var itemTextStyle = TextStyle(color: MyTheme.textColor());

    var divider = Divider(height: 20, color: backgorundColor);

    progressBar = LinearProgressIndicator(value: progressBarValue, backgroundColor: backgorundColor);

    //endregion

    return Scaffold(
      backgroundColor: backgorundColor,
      body: Tooltip(
        showDuration: Duration(microseconds: 1),
        message: 'Tela de Login',
        child: SingleChildScrollView(
          padding: EdgeInsets.all(50),
          child: Column(children: [
            divider,
            //Top (Logo)
            //Icone
            Image.asset(MyIcons.ic_launcher, width: 130, height: 130),
            //Texto Bem Vindo
            Padding(
              child: Text('BEM VINDO AO PROTIPS',
                style: TextStyle(
                  color: MyTheme.textColor(),
                  fontSize: 18,
                ),
              ),
              padding: EdgeInsets.only(top: 30),
            ),
            //ProgressBar
            Padding(
              child: progressBar,
              padding: EdgeInsets.only(top: 5),
            ),
            divider,
            //Corpo
            // Email
            Container(
              height: itemHeight,
              padding: itemPadding,
              decoration: emailNaoEncontrado || emailInvalido
                  ? itemDecorationError
                  : itemDecoration,
              child: TextFormField(
                controller: cEmail,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                style: itemTextStyle,
                decoration: InputDecoration(
                  contentPadding: itemContentPadding,
                  enabledBorder: itemBorder,
                  focusedBorder: itemBorder,
                  labelStyle: itemLabeErrorlStyle,
                  hintStyle: itemHintStyle,
                  labelText: emailNaoEncontrado
                      ? 'Email não Registrado'
                      : emailInvalido ? 'Email inválido' : null,
                  hintText: 'Email',
                  icon: Icon(Icons.person, color: emailInvalido || emailNaoEncontrado ? iconColorError : iconColor),
                ),
                onTap: () {
                  setState(() {
                    emailNaoEncontrado = false;
                    emailInvalido = false;
                  });
                },
              ),
            ),
            // Senha
            Container(
              height: itemHeight,
              margin: EdgeInsets.only(top: 20),
              padding: itemPadding,
              decoration: senhaIncorreta
                  ? itemDecorationError
                  : itemDecoration,
              child: TextField(
                controller: cSenha,
                obscureText: true,
                style: itemTextStyle,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                  contentPadding: itemContentPadding,
                  enabledBorder: itemBorder,
                  focusedBorder: itemBorder,
                  labelStyle: itemLabeErrorlStyle,
                  hintStyle: itemHintStyle,
                  labelText: senhaIncorreta ? 'Senha incorreta' : null,
                  hintText: 'Senha',
                  icon: Icon(Icons.https, color: senhaIncorreta ? iconColorError : iconColor),
                ),
                onSubmitted: (s) {
                  onLoginButtonPressed();
                },
                onTap: () {
                  setState(() {
                    senhaIncorreta = false;
                  });
                },
              ),
            ),
            //Button Recuperar Senha
            Container(
              alignment: Alignment.centerRight,
              child: FlatButton(
                child: Text(
                    'Recuperar Senha',
                    style: itemTextStyle
                ),
                onPressed: onRecuperarSenhaButtonPressed,
              ),
            ),
            //Button Login
            Container(
                width: widthScreen,
                height: itemHeight,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: MyTheme.tintColor(),
                    borderRadius: BorderRadius.all(Radius.circular(60))
                ),
                child: ButtonTheme(
                  minWidth: double.infinity,
                  height: itemHeight,
                  child: FlatButton(
                    child: Text('Login'.toUpperCase(),
                      style: TextStyle(
                          color: MyTheme.primary(),
                          fontSize: 20
                      ),
                    ),
                    onPressed: onLoginButtonPressed,
                  ),
                )
            ),
            //Rodape
            FlatButton(
              child: Text('Cadastre-se', style: itemTextStyle),
              onPressed: onCadastroButtonPressed,
            ),
            Text('OU', style: itemTextStyle),
            divider,
            Tooltip(message: 'Login com Google', child: FlatButton(
              child: Image.asset(MyIcons.ic_google, width: 40, height: 40),
              onPressed: onLoginWithGoogleButtonPressed,
            )),
          ]),
        ),
      ),
    );
  }

  //endregion

  //region Metodos

  void onRecuperarSenhaButtonPressed() {
    Navigator.of(context).pushNamed(RecuperarSenhaPage.tag, arguments: cEmail.text.trim());
  }

  void onLoginButtonPressed() async {
    String email = cEmail.text.trim();
    String senha = cSenha.text.trim();
    if (email.isEmpty || senha.isEmpty)
      return;

    setState(() {
      //Ativa o movimento da barra
      progressBarValue = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: senha);
      getFirebase.setUltinoEmail(email);
      Navigator.pushReplacementNamed(context, MainPage.tag);
      Log.d(TAG, 'Login com Email', 'OK');
    } catch(e) {
      bool sendError = true;
      progressBarValue = 0;
      if (e.toString().contains('ERROR_WRONG_PASSWORD')) {
        senhaIncorreta = true;
        sendError = false;
      }
      if (e.toString().contains('ERROR_USER_NOT_FOUND')) {
        emailNaoEncontrado = true;
        sendError = false;
      }
      if (e.toString().contains('ERROR_INVALID_EMAIL')) {
        emailInvalido = true;
        sendError = false;
      }
      setState(() {});
      Log.e(TAG, 'Login com Email Fail', e, sendError);
    }
  }

  void onLoginWithGoogleButtonPressed() async {
    try{
      Log.d(TAG, 'Login com Google');
      await getFirebase.googleAuth();
      Log.d(TAG, 'Login com Google', 'OK');
      Navigator.pushReplacementNamed(context, MainPage.tag);
    } catch (e) {
      Log.e(TAG, 'Login com Google Fail', e);
      Log.toast('Login with Google fails');
    }
  }


  _checkGoogleServices() async {
    if (! await Import.checkGoogleServices(true)) {
      Log.d(TAG, 'checkGoogleServices', 'False');
      Navigator.pop(context);
    }
    Log.d(TAG, 'checkGoogleServices', 'OK');
  }

  _loadUltimoEmail() async {
    cEmail.text = await getFirebase.getUltinoEmail();
  }

  void onCadastroButtonPressed() {
    Navigator.of(context).pushNamed(CadastroPage.tag);
  }

  //endregion

}
