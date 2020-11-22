import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:protips/auxiliar/config.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/denuncia.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

// ignore: must_be_immutable
class DenunciaPage extends StatefulWidget {
  UserPro user;
  Post post;
  // ignore: non_constant_identifier_names
  DenunciaPage.User(this.user);
  // ignore: non_constant_identifier_names
  DenunciaPage.Post(this.post);

  @override
  State<StatefulWidget> createState() => MyWidgetState(user, post);
}
class MyWidgetState extends State<DenunciaPage> {

  MyWidgetState(this.user, this.post);

  //region variaveis
  static const String TAG = 'DenunciaPage';

  UserPro user;
  Post post;
  bool _isUser = false;
  bool _isEnviando = false;
  bool _dadosEmpty = false;
  double progressBarValue = 0;

  TextEditingController cAssunto = TextEditingController();
  TextEditingController cTexto = TextEditingController();
  //endregion

  @override
  Widget build(BuildContext context) {
    _readArgs(context);
    var hintStyle = TextStyle();
    var hintStyleError = TextStyle(color: MyTheme.textColorError);
    var textStyle = TextStyle(color: MyTheme.textColorSpecial);

    return Scaffold(
      appBar: AppBar(
          title: Text(_isUser ? Titles.DENUNCIA_USER : Titles.DENUNCIA_POST),
        actions: [
          if (RunTime.semInternet)
            Layouts.icAlertInternet,
            Layouts.appBarActionsPadding,
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(children: [
          LinearProgressIndicator(value: progressBarValue),
          _isUser ? _itemLayoutUser(user) : _itemLayoutPost(post),

          TextField(
            controller: cAssunto,
            style: textStyle,
            decoration: InputDecoration(
              hintStyle: _dadosEmpty ? hintStyleError : hintStyle,
              hintText: 'Assunto'
            ),
            onTap: _onTextFieldTap,
          ),
          TextField(
            controller: cTexto,
            style: textStyle,
            decoration: InputDecoration(
                hintStyle: _dadosEmpty ? hintStyleError : hintStyle,
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
          backgroundColor: _isEnviando ? Colors.black26 : MyTheme.accent,
          onPressed: _isEnviando ? null : () {_sendManager(context);},
      )
    );
  }

  //region metodos

  Widget _itemLayoutUser(UserPro item) {
    return ListTile(
        leading: Layouts.clipRRectFormatUser(
            radius: 50,
            child: Layouts.fotoUser(item.dados)
        ),
        title: Text(item.dados.nome),
        subtitle: Text(item.dados.descricao),
    );
  }

  Widget _itemLayoutPost(Post item) {
    return ListTile(
      leading: Layouts.fotoPost(item),
      title: Text(item.titulo),
      subtitle: Text(item.descricao),
    );
  }

  _sendManager(BuildContext context) async {
    Denuncia d = _criarItem();
    if (_verificarItem(d)) {
      _setInProgress(true);
      if (await d.salvar()) {
        Log.snackbar('Enviado');
        Navigator.pop(context);
      } else
        Log.snackbar('Ocorreu um erro', isError: true);
    }
    _setInProgress(false);
  }

  Denuncia _criarItem() {
    Denuncia d = Denuncia();
    d.assunto = cAssunto.text;
    d.texto = cTexto.text;
    d.data = DataHora.now();
    d.isUser = _isUser;
    d.idUser = _isUser ? user.dados.id : post.idTipster;
    d.itemKey = post?.data;//data é o key de um post
    d.idDenunciante = FirebasePro.user.uid;
    return d;
  }

  bool _verificarItem(Denuncia item) {
    bool ok = true;
    if (item.assunto.isEmpty) ok = false;
    if (item.texto.isEmpty) ok = false;

    setState(() {_dadosEmpty = !ok;});
    return ok;
  }

  _onTextFieldTap() {
    setState(() {
      _dadosEmpty = false;
    });
  }

  _readArgs(BuildContext context) {
    if (user == null && post == null) {
      Navigator.pop(context);
      return;
    }
    _isUser = user != null;
  }

  _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      _isEnviando = b;
      progressBarValue = b ? null : 0;
    });
  }

  //endregion

}