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
//    _animationController = AnimationController(vsync: null);
//    _animationController.stop();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis
    double widthScreen = MediaQuery.of(context).size.width/1.3;//Tamanho da tela
    double itemHeight = 50;

    var textfiedlBorder = OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.primaryLight())
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

    var textfiedPadding = EdgeInsets.only(left: 10, right: 10);
    var textfiedHintStyle = TextStyle(color: MyTheme.primary());
    var textfiedLabeErrorlStyle = TextStyle(color: Colors.red);
    var textfiedTextStyle = TextStyle(color: MyTheme.textColor());

    var separator = Padding(padding: EdgeInsets.only(top: 20));

    progressBar = LinearProgressIndicator(value: progressBarValue, backgroundColor: MyTheme.primaryLight());
    //endregion

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: ListView(
          padding: EdgeInsets.all(50),
          children: <Widget>[
            separator,
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
                //Texto Bem Vindo
                Align(
                  child: Padding(
                    child: Text('BEM VINDO AO PROTIPS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
            separator,
            //Corpo
            Column(
              children: <Widget>[
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
                      enabledBorder: textfiedlBorder,
                      focusedBorder: textfiedlBorder,
                      labelStyle: textfiedLabeErrorlStyle,
                      hintStyle: textfiedHintStyle,
                      labelText: emailNaoEncontrado ? 'Email não Registrado' : emailInvalido ? 'Email inválido' : null,
                      hintText: 'Email',
                      icon: Icon(Icons.person, color: MyTheme.primaryDark()),
                    ),
                    onTap: () {
                      setState(() {
                        emailNaoEncontrado = false;
                        emailInvalido = false;
                      });
                    },
                  ),
                ),
                //TextField Senha
                Container(
                  height: itemHeight,
                  margin: EdgeInsets.only(top: 20),
                  padding: textfiedPadding,
                  decoration: senhaIncorreta ? textfiedDecorationError : textfiedDecoration,
                  child: TextField(
                    controller: cSenha,
                    obscureText: true,
                    style: textfiedTextStyle,
                    decoration: InputDecoration(
                      enabledBorder: textfiedlBorder,
                      focusedBorder: textfiedlBorder,
                      labelStyle: textfiedLabeErrorlStyle,
                      hintStyle: textfiedHintStyle,
                      labelText: senhaIncorreta ? 'Senha incorreta' : null,
                      hintText: 'Senha',
                      icon: Icon(Icons.https, color: MyTheme.primaryDark()),
                    ),
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
                      style: textfiedTextStyle
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
              ],
            ),
            //Rodape
            Column(
              children: <Widget>[
                FlatButton(
                  child: Text('Cadastre-se', style: textfiedTextStyle),
                  onPressed: onCadastroButtonPressed,
                ),
                Text('OU', style: textfiedTextStyle),
                FlatButton(
                  padding: EdgeInsets.only(top: 20),
                  child: Image.asset(MyIcons.ic_google, width: 40, height: 40,),
                  onPressed: onLoginWithGoogleButtonPressed,
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: MyTheme.primaryLight(),
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
      var auth = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: senha);
      getFirebase.setfUser(auth.user);
      Navigator.pushReplacementNamed(context, MainPage.tag);
    } catch(e) {
      progressBarValue = 0;
      Log.e(TAG, 'Login com Email Fail', e);
      if (e.toString().contains('ERROR_WRONG_PASSWORD')) {
        setState(() {
          senhaIncorreta = true;
        });
      }
      if (e.toString().contains('ERROR_USER_NOT_FOUND')) {
        setState(() {
          emailNaoEncontrado = true;
        });
      }
      if (e.toString().contains('ERROR_INVALID_EMAIL')) {
        setState(() {
          emailInvalido = true;
        });
      }
    }
  }

  void onLoginWithGoogleButtonPressed() async {
    try{
      print(TAG + ' Login com Google');
      var user = await getFirebase.googleAuth();
      getFirebase.setfUser(user);
      print(TAG + ' Login com Google OK');
      Navigator.pushReplacementNamed(context, MainPage.tag);
    } catch (e) {
      Log.e(TAG, 'Login com Google Fail', e);
    }
  }



  void onCadastroButtonPressed() {
    Navigator.of(context).pushNamed(CadastroPage.tag);
  }

//endregion

}
