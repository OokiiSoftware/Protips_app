import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/my_icons.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';
import 'package:protips/sub_pages/fragment_g_denuncias.dart';
import 'package:protips/sub_pages/fragment_inicio.dart';

class PerfilTipsterPage extends StatefulWidget {
  final UserPro user;
  PerfilTipsterPage(this.user);
  @override
  State<StatefulWidget> createState() => MyWidgetState(user);
}
class MyWidgetState extends State<PerfilTipsterPage> {

  MyWidgetState(this._user);

  //region Variaveis
  static const String TAG = 'PerfilPage';

  UserPro _user;
  bool _isdadosAtualizados = false;
  // bool _isPagamentoLoaded = false;
  bool _inProgress = false;

  bool isMyPerfil = false;
  bool userIsTipster = false;
  bool souFiliadoPendente = false;
  bool souFiliado = false;

  bool euSigo = false;
  bool meSegue = false;
  bool meuFiliadoPendente = false;
  bool meuFiliado = false;

  bool canMostrarDenuncias = false;

  GlobalKey descricaoKey = GlobalKey();
  String _userDescricao;

  //endregion

  //region overrides

  @override
  void dispose() {
    Log.removeTooltip(descricaoKey);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (_user == null) return;
    _userDescricao = _user.dados.descricao;
    if (_userDescricao.isNotEmpty)
      if (_userDescricao.length >= 40)
        _mostrarDicaInicial();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis

    if (_user == null) Navigator.pop(context);

    var eu = FirebasePro.userPro;
    String meuID = eu.dados.id;
    String userID = _user.dados.id;

    if (!_isdadosAtualizados)
      _updateUser();

    isMyPerfil = userID == meuID;
    userIsTipster = _user.dados.isTipster;
    souFiliadoPendente = _user.filiadosPendentes.containsKey(meuID);
    souFiliado = _user.filiados.containsKey(meuID);

    euSigo = eu.seguindo.containsKey(userID);
    meSegue = eu.seguidores.containsKey(userID);
    meuFiliadoPendente = eu.filiadosPendentes.containsKey(userID);
    meuFiliado = eu.filiados.containsKey(userID);

    canMostrarDenuncias = (FirebasePro.isAdmin || isMyPerfil) && _user.denuncias.length > 0;

    List<Widget> tabItems = [];
    List<Widget> tabs = [];

    if (userIsTipster) {
      tabItems = [
        itemsGrid(_user.postPerfilList),
        itemsList(_user.postPerfilList),
        FragmentInicio(user: _user),
      ];
      tabs = [
        Tab(icon: Icon(Icons.view_module)),
        Tab(icon: Icon(Icons.list)),
        Tab(icon: Icon(MyIcons.lightbulb, size: 20)),
      ];
    }

    if(canMostrarDenuncias) {
      tabItems.add(FragmentDenunciasG(_user));
      tabs.add(Tab(icon: Icon(Icons.comment)));
    }

    double headerHeight = 250;
    if(isMyPerfil)
      headerHeight -= 50;
    var btnTextStyle = TextStyle(color: Colors.white);

    var headerColor = MyTheme.darkModeOn ? MyTheme.dark2 : MyTheme.primaryLight;
    //endregion

    return DefaultTabController(
      length: tabItems.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: headerHeight,
          automaticallyImplyLeading: false,
          backgroundColor: headerColor,
          title: Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //AppBar
                  Layouts.customAppBar(
                      context,
                      title: userIsTipster ? Titles.PERFIL_TIPSTER : Titles.PERFIL_FILIADO
                    // icon: ((_user.isMyTipster && _isPagamentoLoaded) || FirebasePro.isAdmin) ?
                    // OpenContainerWrapper(
                    //   tooltip: FirebasePro.isAdmin ? 'Admin Mode' : 'Realizar Pagamento',
                    //   statefulWidget: PagamentoPage(_user),
                    //   child: Container(
                    //     color: MyTheme.primaryLight(),
                    //     child: Icon(
                    //         Icons.credit_card,
                    //         color: FirebasePro.isAdmin ? Colors.red : Colors.white
                    //     ),
                    //   ),
                    //   onClosed: (value) => setState(() {_isPagamentoLoaded = !value;}),
                    // ) : null,
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  //Foto e Dados
                  Layouts.fotoEDados(_user),
                  if (_userDescricao.isNotEmpty)
                    GestureDetector(
                      child: Text(_userDescricao,
                        key: descricaoKey,
                        style: TextStyle(fontSize: 13),
                      ),
                      onTap: _onDescricaoTap,
                    ),
                  //Botões aceitar, recurar ect..
                  if(!isMyPerfil)
                    Container(
                      height: 50,
                      child: Scrollbar(
                        thickness: 1,
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              //Seguir Desseguir
                              if (userIsTipster)...[
                                if (euSigo)...[
                                  // Desseguir
                                  FlatButton(
                                    child: Text('Deixar de Seguir', style: btnTextStyle),
                                    onPressed: () async {
                                      _setProgressBarVisible(true);
                                      if (await _user.removeSeguidor(eu))
                                        setState(() {
                                          euSigo = false;
                                        });
                                      _setProgressBarVisible(false);
                                    },
                                  ),
                                  if (souFiliadoPendente)
                                  // Filiação Pendente
                                    FlatButton(
                                      child: Text('Filiação Pendente', style: btnTextStyle),
                                      onPressed: () async {
                                        _setProgressBarVisible(true);
                                        if (await _user.removeSolicitacao(eu.dados.id))
                                          setState(() {
                                            souFiliadoPendente = false;
                                          });
                                        _setProgressBarVisible(false);
                                      },
                                    )
                                  else if (souFiliado)
                                  // Desfiliar
                                    FlatButton(
                                      child: Text('Cancelar assinatura', style: btnTextStyle),
                                      onPressed: () async {
                                        _setProgressBarVisible(true);
                                        if (await _user.removeFiliado(eu))
                                          setState(() {
                                            souFiliadoPendente = souFiliado = false;
                                          });
                                        _setProgressBarVisible(false);
                                      },
                                    )
                                  else
                                  // Filie-se
                                    FlatButton(
                                      child: Text('Filiar-se', style: btnTextStyle),
                                      onPressed: () async {
                                        _setProgressBarVisible(true);
                                        if (await _user.addSolicitacao(eu))
                                          setState(() {
                                            souFiliadoPendente = true;
                                          });
                                        _setProgressBarVisible(false);
                                      },
                                    )
                                ] else...[
                                  // Seguir
                                  FlatButton(
                                    child: Text('Seguir', style: btnTextStyle),
                                    onPressed: () async {
                                      _setProgressBarVisible(true);
                                      if (await _user.addSeguidor(eu))
                                        setState(() {
                                          euSigo = true;
                                        });
                                      _setProgressBarVisible(false);
                                    },
                                  ),
                                ],

                                if (meuFiliadoPendente)...[
                                  FlatButton(
                                    child: Text('Recusar Filiado', style: btnTextStyle),
                                    onPressed: () async {
                                      _setProgressBarVisible(true);
                                      if (await eu.removeSolicitacao(userID))
                                        setState(() {
                                          meuFiliadoPendente = false;
                                        });
                                      _setProgressBarVisible(false);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Aceitar Filiado', style: btnTextStyle),
                                    onPressed: (/*Aceitar Filial*/) async {
                                      _setProgressBarVisible(true);
                                      if (await eu.aceitarFiliado(_user))
                                        setState(() {
                                          meuFiliado = true;
                                        });
                                      _setProgressBarVisible(false);
                                    },
                                  ),
                                ] else if (meuFiliado)...[
                                  FlatButton(
                                    child: Text('Remover Filiado', style: btnTextStyle),
                                    onPressed: (/*Remover Filial*/) async {
                                      _setProgressBarVisible(true);
                                      if (await eu.removeFiliado(_user))
                                        setState(() {
                                          meuFiliado = false;
                                        });
                                      _setProgressBarVisible(false);
                                    },
                                  ),
                                ]
                              ],
                              /*Expanded(child: FlatButton(
                      child: FittedBox(
                          child: Text(
                              (userIsTipster ? (souFiliadoPendente ? 'Pendente' : (euSigo ? 'Remover' : 'Seguir')) : ''),
                              style: itemTextStyle)),
                      onPressed: userIsTipster ? souFiliadoPendente ? () async {
                        _setProgressBarVisible(true);
                        if (await _user.removeSolicitacao(eu.dados.id))
                          setState(() {
                            souFiliadoPendente = false;
                          });
                        _setProgressBarVisible(false);
                      } : euSigo ? () async {
                        _setProgressBarVisible(true);
                        if (await _user.removeFiliado(eu))
                          setState(() {
                            souFiliadoPendente = euSigo = false;
                          });
                        _setProgressBarVisible(false);
                      } : () async {
                        _setProgressBarVisible(true);
                        if (await _user.addSolicitacao(eu))
                          setState(() {
                            souFiliadoPendente = true;
                          });
                        _setProgressBarVisible(false);
                      } : null)),*/
                              /*Expanded(child: FlatButton(
                      child: FittedBox(child: Text(meuFiliadoPendente ? 'Recusar' : ' ', style: itemTextStyle)),
                      onPressed: meuFiliadoPendente ? () async {
                        _setProgressBarVisible(true);
                        if (await eu.removeSolicitacao(_user.dados.id))
                          setState(() {
                            meuFiliadoPendente = false;
                          });
                        _setProgressBarVisible(false);
                      } : null)),*/
                              /*Expanded(child: FlatButton(
                      child: FittedBox(child: Text(meuFiliado ? 'Remover' : meuFiliadoPendente ? 'Aceitar' : ' ', style: itemTextStyle)),
                      onPressed: meuFiliado ? () async {
                        _setProgressBarVisible(true);
                        if (await eu.removeFiliado(_user))
                          setState(() {
                            meuFiliado = false;
                          });
                        _setProgressBarVisible(false);
                      } : meuFiliadoPendente ? () async {
                        _setProgressBarVisible(true);
                        if (await eu.aceitarFiliado(_user))
                          setState(() {
                            meuFiliado = true;
                          });
                        _setProgressBarVisible(false);
                      } : null))*/
                            ]),
                      ),
                    ),
                ]),
          ),

          bottom: TabBar(tabs: tabs),
          actions: [PopupMenuButton<String>(
              onSelected: (String result) {
                MyMenus.onCliked(context, result, user: _user);
              },
              itemBuilder: (BuildContext context) {
                var list = List<String>();
                list.addAll(MyMenus.perfilPage);
                if (isMyPerfil) {
//                    list.remove(MyMenus.ABRIR_WHATSAPP);
                  list.remove(MyMenus.DENUNCIAR);
                  list.add(MyMenus.MEU_PERFIL);
                } else if (_user.dados.isPrivado)
                  list.remove(MyMenus.ABRIR_WHATSAPP);

                return list.map((item) => PopupMenuItem<String>(value: item, child: Text(item))).toList();
              }
          )],
        ),
        body: TabBarView(children: tabItems),
        floatingActionButton: _inProgress ? Container(
          margin: EdgeInsets.only(top: 70),
          child: CircularProgressIndicator(),
        ) : Container(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }

  //endregion

  //region Metodos

  Widget itemsGrid(List<PostPerfil> data) {
    if (data == null)
      return Scaffold();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(2),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              var item = data[index];
              return Container(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    child: Layouts.fotoPostNetwork(item.foto),
                    onTap: () {
                      DialogBox.popupPostPerfil(context, item);
                    },
                  )
              );
            },
                childCount: data.length
            ),
          ),
        )
      ],
    );
  }

  Widget itemsList(List<PostPerfil> data) {
    if (data == null)
      return Scaffold();
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) {
        var item = data[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 2, thickness: 1),
            //Titulo
            if(item.titulo.isNotEmpty)
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(10),
                color: MyTheme.primary,
                child: Text(item.titulo,
                    style: TextStyle(color: Colors.white, fontSize: 20)
                ),
              ),
            //Foto
            Layouts.fotoPostNetwork(item.foto, progressTypeLinear: true),
            //Legenda
            if(item.texto.isNotEmpty)
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                color: MyTheme.transparentColor(),
                child: Text(item.texto, style: TextStyle(
                    /*color: MyTheme.textColorInvert,*/
                    fontSize: 20)),
              ),
            Divider()
          ],
        );
      },
    );
  }

  _updateUser() async {
    if (_user == null)
      return;
    var item = await UserPro.baixar(_user.dados.id);
    if (item != null) {
      getUsers.add(item);
      if(!mounted) return;
      setState(() {
        _user = item;
      });
    }
    _isdadosAtualizados = true;
  }

  _onDescricaoTap() {
    Log.tooltip(context, descricaoKey, _userDescricao, tempo: 7000);
  }

  _mostrarDicaInicial() async {
    await Future.delayed(Duration(seconds: 1)); // espera um tempo pra tela ser montada
    Log.tooltip(context, descricaoKey, 'Click para ver mais');
  }
  // _loadPagamento() async {
  //   bool result = await Pagamento.load(_user.dados.id);
  //   if(!mounted) return;
  //   setState(() {
  //     _isPagamentoLoaded = !result;
  //   });
  // }

  _setProgressBarVisible(bool visible) {
    if(!mounted) return;
    setState(() {
      _inProgress = visible;
    });
  }

  //endregion

}