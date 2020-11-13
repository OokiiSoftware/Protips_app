import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/res/my_icons.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

class RecuperarSenhaPage extends StatefulWidget {
  final String args;
  RecuperarSenhaPage(this.args);
  @override
  State<StatefulWidget> createState() => MyWidgetState(args);
}
class MyWidgetState extends State<RecuperarSenhaPage> {

  MyWidgetState(this.email);

  static const String TAG = 'RecuperarSenhaPage';

  TextEditingController cEmail = TextEditingController();

  String log = '';
  String email;
  bool reload = false;
  bool emailNaoEncontrado = false;
  bool emailInvalido = false;

  double _progressBarValue = 0;
  // LinearProgressIndicator progressBar;

  @override
  Widget build(BuildContext context) {
    //region Variaveis
    double widthScreen = MediaQuery.of(context).size.width/1.3;//Tamanho da tela
    double itemHeight = 50;

    var backColor = MyTheme.primaryLight;
    var errorColor = MyTheme.textColorError;
    var tintColor = Colors.white;
    var textColor = Colors.white;

    var textfiedlBorder = OutlineInputBorder(
        borderSide: BorderSide(color: backColor),
        borderRadius: BorderRadius.circular(60)
    );

    var textfiedDecorationError = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(60)),
        color: backColor,
        boxShadow: [
          BoxShadow(color: errorColor, blurRadius: 3)
        ]
    );
    var textfiedDecoration = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(60)),
        color: backColor,
        boxShadow: [
          BoxShadow(color: tintColor, blurRadius: 3)
        ]
    );

    var textfiedPadding = EdgeInsets.only(left: 15, right: 10);
    var textfiedLabelStyle = TextStyle(color: MyTheme.primary);
    var textfiedLabeErrorlStyle = TextStyle(color: errorColor);
    var textfiedTextStyle = TextStyle(color: textColor);

    if (!reload) {
      cEmail.text = email;
    }

    reload = true;
    //endregion

    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(title: Text(Titles.RECUPERAR_SENHA)),
      body: Container(
        alignment: Alignment.center,
        child: ListView(
          padding: EdgeInsets.all(50),
          children: [
            //Top
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //Icone
                Align(
                  child: Image.asset(MyIcons.ic_launcher,
                    width: 130,
                    height: 130,
                  ),
                ),
                //Texto
                Align(
                  child: Padding(
                    child: Text('Informe seu email',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                      ),
                    ),
                    padding: EdgeInsets.only(top: 30),
                  ),
                ),
                //ProgressBar
                Align(
                  child: Padding(
                    child: LinearProgressIndicator(value: _progressBarValue, backgroundColor: backColor),
                    padding: EdgeInsets.only(top: 5),
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            //TextField Email
            Container(
              height: itemHeight,
              padding: textfiedPadding,
              decoration: emailNaoEncontrado || emailInvalido ? textfiedDecorationError : textfiedDecoration,
              child: TextField(
                controller: cEmail,
                keyboardType: TextInputType.emailAddress,
                style: textfiedTextStyle,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  enabledBorder: textfiedlBorder,
                  focusedBorder: textfiedlBorder,
                  labelStyle: textfiedLabeErrorlStyle,
                  hintStyle: textfiedLabelStyle,
                  labelText: emailNaoEncontrado ? 'Email não Registrado' : emailInvalido ? 'Email inválido' : null,
                  hintText: 'Email',
                  icon: Icon(Icons.email, color: MyTheme.primaryDark),
                ),
                onTap: () {
                  setState(() {
                    emailNaoEncontrado = false;
                    emailInvalido = false;
                  });
                },
              ),
            ),
            // Log
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                  log,
                style: textfiedTextStyle,
              ),
            ),
            //Button Enviar
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
                    child: Text('Enviar Email'.toUpperCase(),
                      style: TextStyle(
                          color: MyTheme.primary,
                          fontSize: 20
                      ),
                    ),
                    onPressed: enviarEmail,
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  void enviarEmail() async {
    String email = cEmail.text.trim();

    if (email.isEmpty)
      return;

    if(!mounted) return;
    setState(() {
      log = '';
    });
    _setInProgress(true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if(!mounted) return;
      setState(() {
        log = 'Email enviado. Verifique sua caixa de entrada ou span e siga os passos que forem informados';
      });
      _setInProgress(false);
      Log.d(TAG, 'enviarEmail', email);
    } catch (e) {
      bool sendError = true;
      _setInProgress(false);
      if (e.toString().contains('invalid-email')) {
        emailInvalido = true;
        sendError = false;
      }
      if (e.toString().contains('user-not-found')) {
        emailNaoEncontrado = true;
        sendError = false;
      }
      if(!mounted) return;
      setState(() {});
      if (sendError)
        Log.e(TAG, 'enviarEmail', e);
      else
        Log.e2(TAG, 'enviarEmail', e);
    }
  }

  _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      _progressBarValue = b ? null : 0;
    });
  }

}