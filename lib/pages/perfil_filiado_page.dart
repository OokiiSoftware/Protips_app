import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

class PerfilFiliadoPage extends StatefulWidget {
  final User user;
  PerfilFiliadoPage([this.user]);
  @override
  State<StatefulWidget> createState() => MyWidgetState(user);
}
class MyWidgetState extends State<PerfilFiliadoPage> {

  MyWidgetState(this.user);

  //region Variaveis
  static const String TAG = 'PerfilFiliadoPage';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  User user;
  User _eu;
  bool _isDadosAtualizados = false;
  bool _inProgress = false;
  bool _isMensalidadePadrao = false;

  List<DropdownMenuItem<String>> _precos;

  String _mensalidadeAtual;
  String _currentMensalidade = '0.0';
  String _mensalidadePadrao = '0.0';

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _eu = Firebase.user;
    _precos = Import.getDropDownMenuItems(GoogleProductsID.precos.values.toList());

    _mensalidadePadrao = _eu.dados.precoPadrao;
    _currentMensalidade = _eu.seguidores[user.dados.id];
    if (_currentMensalidade == UserTag.PRECO_PADRAO) {
      _currentMensalidade = _mensalidadePadrao;
      _isMensalidadePadrao = true;
    }
    _mensalidadeAtual = _currentMensalidade;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) Navigator.pop(context);
    //region Variaveis

    if (!_isDadosAtualizados)
      _updateUser();

    double headerHeight = 150;
    bool isMyPerfil = user.dados.id == _eu.dados.id;
    bool isFiliado = _eu.seguidores.containsKey(user.dados.id);
    bool isFiliadoPendente = _eu.seguidoresPendentes.containsKey(user.dados.id);

    //endregion

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: headerHeight,
        automaticallyImplyLeading: false,
        backgroundColor: MyTheme.primaryLight(),
        title: Container(
          child: Column(children: [
            MyLayouts.customAppBar(context),
            Padding(padding: EdgeInsets.only(top: 10)),
            MyLayouts.fotoEDados(user),
          ]),
        ),
        actions: [PopupMenuButton<String>(
            onSelected: (String result) {
              MyMenus.onCliked(context, result, user: user);
            },
            itemBuilder: (BuildContext context) {
              var list = List<String>();
              list.addAll(MyMenus.perfilPage);
              if (isMyPerfil) {
                list.remove(MyMenus.ABRIR_WHATSAPP);
                list.remove(MyMenus.DENUNCIAR);
                list.add(MyMenus.MEU_PERFIL);
              } else if (user.dados.isPrivado)
                list.remove(MyMenus.ABRIR_WHATSAPP);

              return list.map((item) =>
                  PopupMenuItem<String>(value: item, child: Text(item)))
                  .toList();
            }
        )],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: Column(
            children: [
              //Botões aceitar, recurar ect..
              if (isFiliadoPendente)
                ...[
                  Text(MyTexts.SOLICITACAO_FILIADO),
                  Row(
                    children: [
                      Expanded(child: ElevatedButton(
                          child: Text('Recusar'),
                          onPressed: () async {
                            _setProgressBarVisible(true);
                            if (await _eu.removeSolicitacao(user.dados.id))
                              setState(() {
                                isFiliadoPendente = false;
                              });
                            _setProgressBarVisible(false);
                          })),
                      Padding(padding: EdgeInsets.only(right: 10)),
                      Expanded(child: ElevatedButton(
                          child: Text('Aceitar'),
                          onPressed: (/*Aceitar Filiado*/) async {
                            _setProgressBarVisible(true);
                            if (await _eu.aceitarSeguidor(user))
                              setState(() {
                                isFiliado = true;
                              });
                            _setProgressBarVisible(false);
                          }))
                    ],
                  ),
                  Divider()
                ]
              else if (isFiliado)
                ...[
                  Row(
                    children: [
                      if (_isMensalidadePadrao)
                        Text('Mensalidade (Padráo)', textAlign: TextAlign.center)
                      else
                        Text('Mensalidade', textAlign: TextAlign.center),
                      Padding(padding: EdgeInsets.only(right: 10)),
                      Expanded(child: DropdownButton(
                        items: _precos,
                        value: _currentMensalidade,
                        icon: IconButton(
                          icon: Icon(Icons.refresh, color: MyTheme.primary()),
                          onPressed: () async {
                            var title = 'Redefinir padrão?';
                            var result = await DialogBox.dialogCancelOK(context, title: title);
                            if (result.isOk) {
                              setState(() {
//                                  _cMensalidadeValue.text =
                                _currentMensalidade = _eu.dados.precoPadrao;
                                _isMensalidadePadrao = true;
                              });
                            }
                          },
                        ),
                        onChanged: (value) {
                          setState(() {
                            _currentMensalidade = value;
                            _isMensalidadePadrao = value == _mensalidadePadrao;
                          });
                        },
                      ))
                    ],
                  ),

                  ElevatedButton(
                      child: Text('Remover Filiado'),
                      onPressed: (/*Remover Filiado*/) async {
                        _setProgressBarVisible(true);
                        if (await _eu.removeSeguidor(user))
                          setState(() {
                            isFiliado = false;
                          });
                        _setProgressBarVisible(false);
                      }),
                ]
            ]
        ),
      ),
      floatingActionButton: _inProgress ? Container(
        margin: EdgeInsets.only(top: 70),
        child: CircularProgressIndicator(),
      ) :
      FloatingActionButton.extended(label: Icon(Icons.save), onPressed: _onSalvar),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  //endregion

  //region Metodos

  _onSalvar() async {
    _setProgressBarVisible(true);

    if (_mensalidadeAtual != _currentMensalidade) {
      String value = _isMensalidadePadrao ? UserTag.PRECO_PADRAO : _currentMensalidade;
      await _eu.updateMensalidadeFiliado(user.dados.id, value);
      Log.snackbar(MyTexts.DADOS_SALVOS);
    }

    _setProgressBarVisible(false);
  }
  
  _updateUser() async {
    if (user == null)
      return;
    var item = await getUsers.baixarUser(user.dados.id);
    if (item != null) {
      getUsers.add(item);
      setState(() {
        user = item;
      });
    }
    _isDadosAtualizados = true;
  }

  _setProgressBarVisible(bool visible) {
    setState(() {
      _inProgress = visible;
    });
  }

  //endregion

}