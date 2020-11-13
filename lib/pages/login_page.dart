import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protips/auxiliar/device.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/pages/about_page.dart';
import 'package:protips/pages/cadastro_page.dart';
import 'package:protips/pages/main_page.dart';
import 'package:protips/pages/recuperar_senha_page.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/my_icons.dart';
import 'package:protips/res/theme.dart';

class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<LoginPage> {

  //region Variaveis
  static const String TAG = 'LoginPage';

  bool emailNaoEncontrado = false;
  bool emailInvalido = false;
  bool emailNaoVerificado = false;
  bool senhaIncorreta = false;

  TextEditingController cSenha = TextEditingController();
  TextEditingController cEmail = TextEditingController();

  double _progressBarValue = 0;

  User _currentUser;

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
    //region Variaveis
    var backgorundColor = MyTheme.primaryLight;
    var iconColor = MyTheme.primaryDark;
    var iconColorError = MyTheme.textColorError;
    var tintColor = Colors.white;
    var textColor = Colors.white;
    double widthScreen = MediaQuery.of(context).size.width / 1.3; //Tamanho da tela
    double itemHeight = 50;

    var itemBorder = OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none));

    var itemDecorationError = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: backgorundColor,
        boxShadow: [
          BoxShadow(color: iconColorError, blurRadius: 1),
          BoxShadow(color: iconColorError, blurRadius: 1),
        ]
    );
    var itemDecoration = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: backgorundColor,
        boxShadow: [
          BoxShadow(color: tintColor, blurRadius: 1),
          BoxShadow(color: tintColor, blurRadius: 1),
        ]
    );

    var itemContentPadding = EdgeInsets.fromLTRB(0, 0, 12, 0);

    var itemPadding = EdgeInsets.symmetric(horizontal: 15);
    var itemHintStyle = TextStyle(color: MyTheme.primary);
    var itemLabeErrorlStyle = TextStyle(color: iconColorError);
    var itemTextStyle = TextStyle(color: textColor);

    var divider = Divider(height: 20, color: backgorundColor);

    //endregion

    return Scaffold(
      backgroundColor: backgorundColor,
      body: SingleChildScrollView(
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
                color: textColor,
                fontSize: 18,
              ),
            ),
            padding: EdgeInsets.only(top: 30),
          ),
          //ProgressBar
          Padding(
            child: LinearProgressIndicator(value: _progressBarValue, backgroundColor: backgorundColor),
            padding: EdgeInsets.only(top: 5),
          ),
          divider,
          //Corpo
          // Email
          Container(
            height: itemHeight,
            padding: itemPadding,
            decoration: (emailNaoEncontrado || emailInvalido)
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
          if (emailNaoVerificado)
            Container(
              alignment: Alignment.centerRight,
              child: FlatButton(
                child: Text(
                    'Email não verificado',
                    style: itemTextStyle
                ),
                onPressed: onVerificarEmail,
              ),
            ),
          //Button Login
          Container(
              width: widthScreen,
              height: itemHeight,
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  color: tintColor,
                  borderRadius: BorderRadius.all(Radius.circular(60))
              ),
              child: ButtonTheme(
                minWidth: double.infinity,
                height: itemHeight,
                child: FlatButton(
                  child: Text('Login'.toUpperCase(),
                    style: TextStyle(
                        color: MyTheme.primary,
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
          if (Platform.isAndroid)
            GestureDetector(
              child: Container(
                width: 270,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(
                      width: 1.5,
                      color: Colors.blue,
                    )
                ),
                child: Row(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(5),
                      child: Image.asset(MyIcons.ic_google),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Login com Google', style: TextStyle(color: Colors.white, fontSize: 20)),
                    )
                  ],
                ),
              ),
              onTap: onLoginWithGoogleButtonPressed,
            ),
          // Tooltip(message: 'Login com Google', child: FlatButton(
          //   child: Image.asset(MyAssets.ic_google, width: 40, height: 40),
          //   onPressed: onLoginWithGoogleButtonPressed,
          // )),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        tooltip: 'Sobre',
        child: Icon(Icons.info, color: Colors.white),
        backgroundColor: backgorundColor,
        elevation: 0.001,
        focusElevation: 0.001,
        hoverElevation: 0.001,
        highlightElevation: 0.001,
        onPressed: _onInfoPressed,
      ),
    );
  }

  //endregion

  //region Metodos

  void onRecuperarSenhaButtonPressed() {
    Navigate.to(context, RecuperarSenhaPage(cEmail.text.trim()));
  }

  void onLoginButtonPressed() async {
    String email = cEmail.text.trim();
    String senha = cSenha.text.trim();
    if (email.isEmpty || senha.isEmpty)
      return;

    _setInProgress(true);

    try {
      var result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: senha);
      _currentUser = result.user;
      if (!_currentUser.emailVerified) {
        onVerificarEmail();
        throw Exception('EMAIL_NAO_VERIFICADO');
      }

      FirebasePro.ultinoEmail = email;
      FirebasePro.logado = true;
      Navigate.toReplacement(context, MainPage());
      Log.d(TAG, 'Login com Email', 'OK');
    } catch(e) {
      bool sendError = true;
      _setInProgress(false);
      HapticFeedback.lightImpact();
      String erro = e.toString();
      setState(() {
        if (erro.contains('wrong-password')) {
          senhaIncorreta = true;
          sendError = false;
        }
        if (erro.contains('user-not-found')) {
          emailNaoEncontrado = true;
          sendError = false;
        }
        if (erro.contains('invalid-email')) {
          emailInvalido = true;
          sendError = false;
        }
        if (erro.contains('EMAIL_NAO_VERIFICADO')) {
          emailNaoVerificado = true;
          sendError = false;
        }
      });
      if (sendError)
        Log.e(TAG, 'Login com Email Fail', e);
      else
        Log.e2(TAG, 'Login com Email Fail', e);
    }
  }

  void onLoginWithGoogleButtonPressed() async {
    try{
      Log.d(TAG, 'Login com Google');
      await FirebasePro.googleAuth();
      Log.d(TAG, 'Login com Google', 'OK');
      FirebasePro.logado = true;
      Navigate.toReplacement(context, MainPage());
    } catch (e) {
      Log.e(TAG, 'Login com Google Fail', e);
      Log.snackbar('Login with Google fails', isError: true);
    }
  }

  void onCadastroButtonPressed() {
    Navigate.to(context, CadastroPage());
  }

  void onVerificarEmail() async {
    var title = 'Verificar Email';
    var content = Text('Deseja reenviar um novo email de verificação para ${cEmail.text}?');
    var result = await DialogBox.dialogCancel(context, title: title, auxBtnText: 'Enviar', negativeButton: 'Fechar', content: [content]);
    if (result.isAux) {
      _setInProgress(true);
      try {
        await _currentUser.sendEmailVerification();
        Log.snackbar('Email enviado');
      } catch(e) {
        Log.snackbar('Erro ao enviar email', isError: true);
        Log.e(TAG, 'onVerificarEmail', e);
      }
      _setInProgress(false);
    }
  }

  _onInfoPressed() {
    Navigate.to(context, AboutPage());
  }

  _checkGoogleServices() async {
    if (! await Device.checkGoogleServices(true)) {
      Log.d(TAG, 'checkGoogleServices', 'False');
      Navigator.pop(context);
    }
    Log.d(TAG, 'checkGoogleServices', 'OK');
  }

  _loadUltimoEmail() {
    cEmail.text = FirebasePro.ultinoEmail;
  }

  _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      _progressBarValue = b ? null : 0;
    });
  }

  //endregion

}
