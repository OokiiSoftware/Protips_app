import 'package:flutter/material.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

class PerfilFiliadoPage extends StatefulWidget {
  final UserPro user;
  PerfilFiliadoPage([this.user]);
  @override
  State<StatefulWidget> createState() => MyWidgetState(user);
}
class MyWidgetState extends State<PerfilFiliadoPage> {

  MyWidgetState(this.user);

  //region Variaveis
  static const String TAG = 'PerfilFiliadoPage';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  UserPro user;
  UserPro _eu;
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
    _eu = FirebasePro.userPro;
    _precos = Import.getDropDownMenuItems(GoogleProductsID.precos.values.toList());

    _mensalidadePadrao = _eu.dados.precoPadrao;
    _currentMensalidade = _eu.filiados[user.dados.id];
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
    bool isFiliado = _eu.filiados.containsKey(user.dados.id);
    bool isFiliadoPendente = _eu.filiadosPendentes.containsKey(user.dados.id);

    var headerColor = MyTheme.darkModeOn ? MyTheme.dark2 : MyTheme.primaryLight;
    //endregion

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: headerHeight,
        automaticallyImplyLeading: false,
        backgroundColor: headerColor,
        title: Container(
          child: Column(children: [
            Layouts.customAppBar(
                context,
                title: Titles.PERFIL_FILIADO
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Layouts.fotoEDados(user),
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
                            _setInProgress(true);
                            if (await _eu.removeSolicitacao(user.dados.id))
                              setState(() {
                                isFiliadoPendente = false;
                              });
                            _setInProgress(false);
                          })),
                      Padding(padding: EdgeInsets.only(right: 10)),
                      Expanded(child: ElevatedButton(
                          child: Text('Aceitar'),
                          onPressed: (/*Aceitar Filiado*/) async {
                            _setInProgress(true);
                            if (await _eu.aceitarFiliado(user))
                              setState(() {
                                isFiliado = true;
                              });
                            _setInProgress(false);
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
                          tooltip: 'Redefinir padrão',
                          icon: Icon(Icons.refresh, color: MyTheme.textColorSpecial),
                          onPressed: () async {
                            var title = 'Redefinir padrão?';
                            var result = await DialogBox.dialogCancelOK(context, title: title);
                            if (result.isPositive) {
                              setState(() {
//                                  _cMensalidadeValue.text =
                                _currentMensalidade = _eu.dados.precoPadrao;
                                _isMensalidadePadrao = true;
                              });
                            }
                          },
                        ),
                        style: TextStyle(color: MyTheme.textColorSpecial),
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
                        _setInProgress(true);
                        if (await _eu.removeFiliado(user))
                          setState(() {
                            isFiliado = false;
                          });
                        _setInProgress(false);
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
    _setInProgress(true);

    if (_mensalidadeAtual != _currentMensalidade) {
      String value = _isMensalidadePadrao ? UserTag.PRECO_PADRAO : _currentMensalidade;
      await _eu.updateMensalidadeFiliado(user.dados.id, value);
      Log.snackbar(MyTexts.DADOS_SALVOS);
    }

    _setInProgress(false);
  }
  
  _updateUser() async {
    if (user == null)
      return;
    var item = await UserPro.baixar(user.dados.id);
    if (item != null) {
      getUsers.add(item);
      if(!mounted) return;
      setState(() {
        user = item;
      });
    }
    _isDadosAtualizados = true;
  }

  _setInProgress(bool visible) {
    if(!mounted) return;
    setState(() {
      _inProgress = visible;
    });
  }

  //endregion

}