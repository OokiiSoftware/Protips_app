import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/input_formatter.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/res/strings.dart';

class CadastroTelefonePage extends StatefulWidget {
  final String numero;
  CadastroTelefonePage({this.numero});
  @override
  State<CadastroTelefonePage> createState() => MyState(numero);
}
class MyState extends State<CadastroTelefonePage> {

  //region variaveis
  static const TAG = 'CadastroTelefonePage';

  MyState([this.numero = '']);
  bool _inProgress = false;
  bool codigoEnviado = false;

  String numero;
  String log = '';

  var _cTelefone = TextEditingController();
  var _cCodigo = TextEditingController();

  final _textFormatterPhone = TextInputFormatterPhone();

  ConfirmationResult confirmationResult;

  //endregion

  //region override

  @override
  void initState() {
    super.initState();
    _cTelefone.text = numero;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(Titles.TELEFONE_PAGE)),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              if (codigoEnviado)...[
                Text('Código de verificação enviado. Insira o código abaixo'),
                TextField(
                  controller: _cCodigo,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Código'
                  ),
                ),
                Divider(),
                ElevatedButton(
                  child: Text('Verificar Código'),
                  onPressed: _onConfirvarCodigo,
                ),
              ] else...[
                Text('Insira seu número abaixo e solicite um código de verificação'),
                TextField(
                  controller: _cTelefone,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _textFormatterPhone,
                  ],
                  decoration: InputDecoration(
                      labelText: 'Número'
                  ),
                ),
                Divider(),
                ElevatedButton(
                  child: Text('Enviar Código'),
                  onPressed: _onEnviarCodigo,
                ),
              ],
              if (log.isNotEmpty)
                Text(log),
            ],
          ),
        ),
        floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
      ),
    );
  }

  //endregion

  //region metodos

  _onEnviarCodigo() async {
    _setLog();
    _setInProgress(true);
    try {
      String numero = '+55${_cTelefone.text}';
      numero = numero
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll('-', '')
          .replaceAll(' ', '');

      confirmationResult = await FirebasePro.user.linkWithPhoneNumber(numero);
      if(!mounted) return;
      setState(() {
        codigoEnviado = true;
      });
    } catch(e) {
      _setLog(e.toString());
      Log.e(TAG, '_onEnviarCodigo', e);
    }
    _setInProgress(false);
  }

  _onConfirvarCodigo() async {
    _setLog();
    _setInProgress(true);
    try {
      var result = await confirmationResult.confirm(_cCodigo.text);
      if (result != null) {

      }
    } catch(e) {
      _setLog(e.toString());
      Log.e(TAG, '_onConfirvarCodigo', e);
    }
    _setInProgress(false);
  }

  _setLog([String value = '']) {
    if(!mounted) return;
    setState(() {
      log = value;
    });
  }

  _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}