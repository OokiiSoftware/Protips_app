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

  //region Variaveis
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
  //endregion

  @override
  Widget build(BuildContext context) {
    double itemHeight = 45;

    var itemContentPadding = EdgeInsets.fromLTRB(12, 0, 12, 0);
    var textfiedlBorder = OutlineInputBorder(
        borderSide: BorderSide(color: MyTheme.tintColor()),
      borderRadius: BorderRadius.circular(60)
    );
    var textfiedlBorderError = OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(60)
    );

    var textfiedPadding = EdgeInsets.symmetric(horizontal: 10);
    var textfiedLabelStyle = TextStyle(color: MyTheme.primaryLight());
    var textfiedTextStyle = TextStyle(color: MyTheme.textColor());

    var divider = Divider(height: 50, color: MyTheme.primary());

    return Scaffold(
      body: SingleChildScrollView(
          padding: EdgeInsets.all(50),
        child: Column(
          children: [
            Image.asset(MyIcons.ic_person, width: 100, height: 100),
            // Texto
            Padding(
              child: Text('PUNTER | TIPSTER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              padding: EdgeInsets.only(top: 50),
            ),
            divider,
            // Nome
            Container(
              height: itemHeight,
              padding: textfiedPadding,
              child: TextField(
                controller: cNome,
                keyboardType: TextInputType.name,
                style: textfiedTextStyle,
                decoration: InputDecoration(
                  contentPadding: itemContentPadding,
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
            // Email
            Container(
              height: itemHeight,
              margin: EdgeInsets.only(top: 20),
              padding: textfiedPadding,
              child: TextFormField(
                controller: cEmail,
                keyboardType: TextInputType.emailAddress,
                style: textfiedTextStyle,
                decoration: InputDecoration(
                  contentPadding: itemContentPadding,
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
            // Senha
            Container(
              height: itemHeight,
              margin: EdgeInsets.only(top: 20),
              padding: textfiedPadding,
              child: TextField(
                controller: cSenha,
                obscureText: true,
                style: textfiedTextStyle,
                decoration: InputDecoration(
                  contentPadding: itemContentPadding,
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
            // Confirmar Senha
            Container(
              height: itemHeight,
              margin: EdgeInsets.only(top: 20),
              padding: textfiedPadding,
              child: TextField(
                controller: cConfirmSenha,
                obscureText: true,
                style: textfiedTextStyle,
                decoration: InputDecoration(
                  contentPadding: itemContentPadding,
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
            divider,
            //Rodape
            FloatingActionButton(
              child: Icon(Icons.forward, color: MyTheme.tintColor()),
              backgroundColor: MyTheme.accent(),
              onPressed: onCadastroButtonPressed,
            )
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

    bool retornar = false;
    setState(() {
      if (nome.isEmpty) {
        retornar = nomeVazio = true;
        return;
      }
      if (email.isEmpty) {
        retornar = emailVazio = true;
        return;
      }
      if (senha.isEmpty) {
        retornar = senhaVazio = true;
        return;
      }
      if (confSenha.isEmpty) {
        retornar = confSenhaVazio = true;
        return;
      }
      if (senha != confSenha) {
        retornar = senhasDiferentes = true;
        return;
      }
    });
    if (retornar)
      return;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: senha);
      Navigator.pop(context);
    } catch (e) {
      bool sendError = true;
      if (e.toString().contains('ERROR_INVALID_EMAIL')) {
        emailVazio = true;
        sendError = false;
      }
      if (e.toString().contains('ERROR_WEAK_PASSWORD')) {
        senhaFraca = true;
        sendError = false;
      }
      setState(() {});
      Log.e(TAG, 'Cadastro', e, sendError);
    }
  }
}