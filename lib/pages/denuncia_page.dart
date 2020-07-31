import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/denuncia.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/resources.dart';

class DenunciaPage extends StatefulWidget {
  static const String tag = 'DenunciaPage';
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<DenunciaPage> {
  static const String TAG = 'DenunciaPage';

  User _user;
  Post _post;
  bool _isUser = false;
  bool _isEnviando = false;
  bool _dadosEmpty = false;
  double progressBarValue = 0;

  TextEditingController cAssunto = TextEditingController();
  TextEditingController cTexto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _readArgs(context);
    var hintStyle = TextStyle(color: _dadosEmpty ? Colors.red : Colors.black26);

    return Scaffold(
      appBar: AppBar(title: Text(_isUser ? Titles.DENUNCIA_USER : Titles.DENUNCIA_POST)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(children: [
          LinearProgressIndicator(value: progressBarValue),
          _isUser ? _itemLayoutUser(_user) : _itemLayoutPost(_post),

          TextField(
            controller: cAssunto,
            decoration: InputDecoration(
              hintStyle: hintStyle,
              hintText: 'Assunto'
            ),
            onTap: _onTextFieldTap,
          ),
          TextField(
            controller: cTexto,
            decoration: InputDecoration(
                hintStyle: hintStyle,
              hintText: 'Descreva aqui o motivo da denúncia'
            ),
            onTap: _onTextFieldTap,
          ),
          if(_dadosEmpty) Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text('Pos favor. Preencha todos os campos'),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text('Enviar'),
          backgroundColor: _isEnviando ? MyTheme.tintColor2() : MyTheme.accent(),
          onPressed: _isEnviando ? null : () {_sendManager(context);},
      )
    );
  }

  Widget _itemLayoutUser(User item) {
    double fotoSize = 50;

    return ListTile(
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: MyIcons.fotoUser(item.dados, fotoSize)
        ),
        title: Text(item.dados.nome),
        subtitle: Text(item.dados.descricao),
    );
  }

  Widget _itemLayoutPost(Post item) {
    double fotoSize = 50;

    return ListTile(
      leading: MyIcons.fotoPost(item, fotoSize),
      title: Text(item.titulo),
      subtitle: Text(item.descricao),
    );
  }

  _sendManager(BuildContext context) async {
    Denuncia d = _criarItem();
    if (_verificarItem(d)) {
      _setEnviando(true);
      if (await d.salvar()) {
        Log.toast('Enviado');
        Navigator.pop(context);
      } else
        Log.toast('Ocorreu um erro', isError: true);
    }
    _setEnviando(false);
  }

  Denuncia _criarItem() {
    Denuncia d = Denuncia();
    d.assunto = cAssunto.text;
    d.texto = cTexto.text;
    d.data = DataHora.now();
    d.isUser = _isUser;
    d.idUser = _isUser ? _user.dados.id : _post.idTipster;
    d.itemKey = _post?.data;//data é o key de um post
    d.idDenunciante = getFirebase.fUser().uid;
    return d;
  }

  bool _verificarItem(Denuncia item) {
    bool ok = true;
    if (item.assunto.isEmpty) ok = false;
    if (item.texto.isEmpty) ok = false;

    setState(() {_dadosEmpty = !ok;});
    return ok;
  }

  _setEnviando(bool b) {
    setState(() {
      _isEnviando = b;
      progressBarValue = b ? null : 0;
    });
  }

  _onTextFieldTap() {
    setState(() {
      _dadosEmpty = false;
    });
  }

  _readArgs(BuildContext context) {
    var item = ModalRoute.of(context).settings.arguments;
    if (item == null) {
      Navigator.pop(context);
      return;
    }
    if (item is User) {
      _user = item;
      _isUser = true;
    } else if (item is Post)
      _post = item;
    else
      Navigator.pop(context);
  }
}