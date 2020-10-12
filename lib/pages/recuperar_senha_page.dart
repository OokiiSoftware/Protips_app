import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/res/resources.dart';
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

  double progressBarValue = 0;
  LinearProgressIndicator progressBar;

  @override
  Widget build(BuildContext context) {
    //region Variaveis
    double widthScreen = MediaQuery.of(context).size.width/1.3;//Tamanho da tela
    double itemHeight = 50;

    var textfiedlBorder = OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.primaryLight()),
        borderRadius: BorderRadius.circular(60)
    );

    var textfiedDecorationError = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(60)),
        color: MyTheme.primaryLight(),
        boxShadow: [
          BoxShadow(color: Colors.red, blurRadius: 3)
        ]
    );
    var textfiedDecoration = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(60)),
        color: MyTheme.primaryLight(),
        boxShadow: [
          BoxShadow(color: Colors.white, blurRadius: 3)
        ]
    );

    var textfiedPadding = EdgeInsets.only(left: 15, right: 10);
    var textfiedLabelStyle = TextStyle(color: MyTheme.primary());
    var textfiedLabeErrorlStyle = TextStyle(color: Colors.red);
    var textfiedTextStyle = TextStyle(color: MyTheme.textColor());

    progressBar = LinearProgressIndicator(value: progressBarValue, backgroundColor: MyTheme.primaryLight());

    if (!reload) {
      cEmail.text = email;
    }

    reload = true;
    //endregion

    return Scaffold(
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
                  child: Image.asset(MyAssets.ic_launcher,
                    width: 130,
                    height: 130,
                  ),
                ),
                //Texto
                Align(
                  child: Padding(
                    child: Text('Informe seu email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    padding: EdgeInsets.only(top: 30),
                  ),
                ),
                //ProgressBar
                Align(
                  child: Padding(
                    child: progressBar,
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
                  icon: Icon(Icons.email, color: MyTheme.primaryDark()),
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
                    color: MyTheme.tintColor(),
                    borderRadius: BorderRadius.all(Radius.circular(60))
                ),
                child: ButtonTheme(
                  minWidth: double.infinity,
                  height: itemHeight,
                  child: FlatButton(
                    child: Text('Enviar Email'.toUpperCase(),
                      style: TextStyle(
                          color: MyTheme.primary(),
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
      backgroundColor: MyTheme.primaryLight(),
    );
  }

  void enviarEmail() async {
    String email = cEmail.text.trim();

    if (email.isEmpty)
      return;

    setState(() {
      progressBarValue = null;
      log = '';
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Log.d(TAG, 'enviarEmail', email);
      setState(() {
        log = 'Email enviado. Verifique sua caixa de entrada ou span e siga os passos que forem informados';
        progressBarValue = 0;
      });
    } catch (e) {
      bool sendError = true;
      progressBarValue = 0;
      if (e.toString().contains('ERROR_INVALID_EMAIL')) {
        emailInvalido = true;
        sendError = false;
      }
      if (e.toString().contains('ERROR_USER_NOT_FOUND')) {
        emailNaoEncontrado = true;
        sendError = false;
      }
      setState(() {});
      Log.e(TAG, 'enviarEmail', e, sendError);
    }
  }

}