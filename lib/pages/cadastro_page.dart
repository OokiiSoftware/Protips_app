import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/res/resources.dart';

class CadastroPage extends StatefulWidget{
  static const String tag = 'CadastroPage';
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<CadastroPage> {
  static const String TAG = 'CadastroPage';

  bool nomeVazio = false;
  bool emailVazio = false;
  bool emailInvalido = false;
  bool senhaVazio = false;
  bool senhaFraca = false;
  bool confSenhaVazio = false;
  bool senhasDiferentes = false;

  TextEditingController cNome = TextEditingController();
  TextEditingController cEmail = TextEditingController();
  TextEditingController cSenha = TextEditingController();
  TextEditingController cConfirmSenha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double itemHeight = 45;

    var textfiedlBorder = OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.tintColor()),
      borderRadius: BorderRadius.circular(60)
    );
    var textfiedlBorderError = OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(60)
    );

    var textfiedPadding = EdgeInsets.only(left: 10, right: 10);
    var textfiedLabelStyle = TextStyle(color: MyTheme.primaryLight());
    var textfiedTextStyle = TextStyle(color: MyTheme.textColor());

    var separator = Padding(padding: EdgeInsets.only(top: 50));

    return Scaffold(
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
                  child: Image.asset(MyIcons.ic_person,
                    width: 100,
                    height: 100,
                  ),
                ),
                //Texto Bem Vindo
                Align(
                  child: Padding(
                    child: Text('PUNTER | TIPSTER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    padding: EdgeInsets.only(top: 50),
                  ),
                ),
              ],
            ),
            separator,
            //Corpo
            Column(
              children: <Widget>[
                //TextField Nome
                Container(
                  height: itemHeight,
                  padding: textfiedPadding,
                  child: TextField(
                    controller: cNome,
                    keyboardType: TextInputType.name,
                    style: textfiedTextStyle,
                    decoration: InputDecoration(
                      enabledBorder: nomeVazio ? textfiedlBorderError : textfiedlBorder,
                      focusedBorder: nomeVazio ? textfiedlBorderError : textfiedlBorder,
                      labelStyle: textfiedLabelStyle,
                      labelText: 'Seu Nome',
                    ),
                    onTap: () {
                      setState(() {
                        nomeVazio = false;
                      });
                    },
                  ),
                ),
                //TextField Email
                Container(
                  height: itemHeight,
                  margin: EdgeInsets.only(top: 20),
                  padding: textfiedPadding,
                  child: TextFormField(
                    controller: cEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: textfiedTextStyle,
                    decoration: InputDecoration(
                      enabledBorder: emailVazio || emailInvalido ? textfiedlBorderError : textfiedlBorder,
                      focusedBorder: emailVazio || emailInvalido ? textfiedlBorderError : textfiedlBorder,
                      suffixText: emailInvalido ? 'email inválido' : null,
                      labelStyle: textfiedLabelStyle,
                      labelText: 'Seu Email',
                    ),
                    onTap: () {
                      setState(() {
                        emailVazio = false;
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
                  child: TextField(
                    controller: cSenha,
                    obscureText: true,
                    style: textfiedTextStyle,
                    decoration: InputDecoration(
                      enabledBorder: senhaVazio || senhaFraca ? textfiedlBorderError : textfiedlBorder,
                      focusedBorder: senhaVazio || senhaFraca ? textfiedlBorderError : textfiedlBorder,
                      labelStyle: textfiedLabelStyle,
                      suffixText: senhaFraca ? 'Senha fraca' : null,
                      labelText: 'Senha',
                    ),
                    onTap: () {
                      setState(() {
                        senhaVazio = false;
                        senhaFraca = false;
                      });
                    },
                  ),
                ),
                //TextField Confirmar Senha
                Container(
                  height: itemHeight,
                  margin: EdgeInsets.only(top: 20),
                  padding: textfiedPadding,
                  child: TextField(
                    controller: cConfirmSenha,
                    obscureText: true,
                    style: textfiedTextStyle,
                    decoration: InputDecoration(
                      enabledBorder: confSenhaVazio || senhasDiferentes ? textfiedlBorderError : textfiedlBorder,
                      focusedBorder: confSenhaVazio || senhasDiferentes ? textfiedlBorderError : textfiedlBorder,
                      labelStyle: textfiedLabelStyle,
                      suffixText: senhasDiferentes ? 'Senha diferente' : null,
                      labelText: 'Confirmar Senha',
                    ),
                    onTap: () {
                      setState(() {
                        confSenhaVazio = false;
                        senhasDiferentes = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            separator,
            //Rodape
            Column(
              children: <Widget>[
                FloatingActionButton(
                  child: Icon(Icons.forward, color: MyTheme.tintColor()),
                  backgroundColor: MyTheme.accent(),
                  onPressed: onCadastroButtonPressed,
                ),
              ],
            ),
          ],
        )
      ),
      backgroundColor: MyTheme.primary(),

    );
  }

  void onCadastroButtonPressed() async {
    String email = cEmail.text.trim();
    String senha = cSenha.text;
    String confSenha = cConfirmSenha.text;
    String nome = cNome.text;

    setState(() {
      if (nome.isEmpty) {
        nomeVazio = true;
        return;
      }
      if (email.isEmpty) {
        emailVazio = true;
        return;
      }
      if (senha.isEmpty) {
        senhaVazio = true;
        return;
      }
      if (confSenha.isEmpty) {
        confSenhaVazio = true;
        return;
      }
      if (senha != confSenha) {
        senhasDiferentes = true;
        return;
      }
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: senha);
      Navigator.pop(context);
    } catch (e) {
      if (e.toString().contains('ERROR_INVALID_EMAIL'))
        setState(() {
          emailVazio = true;
        });
      if (e.toString().contains('ERROR_WEAK_PASSWORD'))
        setState(() {
          senhaFraca = true;
        });
      Log.e(TAG, 'Cadastro', e);
    }
  }
}