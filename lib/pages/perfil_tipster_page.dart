import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/pagamento.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/user.dart';
import 'package:protips/pages/pagamento_page.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/sub_pages/fragment_g_denuncias.dart';
import 'package:protips/sub_pages/fragment_inicio.dart';

class PerfilTipsterPage extends StatefulWidget {
  final User user;
  PerfilTipsterPage(this.user);
  @override
  State<StatefulWidget> createState() => MyWidgetState(user);
}
class MyWidgetState extends State<PerfilTipsterPage> {

  MyWidgetState(this._user);

  //region Variaveis
  static const String TAG = 'PerfilPage';

  User _user;
  bool _isdadosAtualizados = false;
  bool _isPagamentoLoaded = false;
  bool _inProgress = false;
  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    if (_user == null) return;
    if (_user.isMyTipster)
      _loadPagamento();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis

    if (_user == null) Navigator.pop(context);

    if (!_isdadosAtualizados)
      _updateUser();

    var eu = getFirebase.user;
    bool isMyPerfil = _user.dados.id == getFirebase.fUser.uid;
    bool isTipster = _user.dados.isTipster;
    bool isPendente = _user.seguidoresPendentes.containsValue(eu.dados.id);
    bool isSeguindo = eu.seguindo.containsKey(_user.dados.id);
    bool isFilialPendente = eu.seguidoresPendentes.containsKey(_user.dados.id);
    bool isFilial = eu.seguidores.containsKey(_user.dados.id);

    bool isAdminAndHasDenuncias = getFirebase.isAdmin && _user.denuncias.length > 0;

    List<Widget> tabItems = [];
    List<Widget> tabs = [];

    if (isTipster) {
      tabItems = [
        itemsGrid(_user.postPerfilList),
        itemsList(_user.postPerfilList),
        FragmentInicio(user: _user),
      ];
      tabs = [
        Tab(icon: Icon(Icons.view_module)),
        Tab(icon: Icon(Icons.list)),
        Tab(icon: Icon(Icons.lightbulb_outline)),
      ];
    }

    if(isAdminAndHasDenuncias || isMyPerfil) {
      tabItems.add(FragmentDenunciasG(_user));
      tabs.add(Tab(icon: Icon(Icons.comment)));
    }

    double headerHeight = 250;
    if(isMyPerfil)
      headerHeight -= 50;
    var itemTextStyle = TextStyle(color: MyTheme.textColor(), fontSize: 15);

    //endregion

    return DefaultTabController(
      length: tabItems.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: headerHeight,
          automaticallyImplyLeading: false,
          backgroundColor: MyTheme.primaryLight(),
          title: Container(
            child: Column(children: [
              //AppBar
              MyLayouts.customAppBar(
                  context,
                icon: (_user.isMyTipster) ?
                IconButton(
                  tooltip: 'Realizar Pagamento',
                  icon: Icon(Icons.credit_card),
                  onPressed: _isPagamentoLoaded ? () async {
//                   bool result = await PaymentService.novoPagamento(_user);
                    bool result = await Navigate.to(context, PagamentoPage(_user));
                   setState(() {
                     _isPagamentoLoaded = !result;
                   });
                  }: null,
                ) : null,
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              //Foto e Dados
              MyLayouts.fotoEDados(_user),
              //Botões aceitar, recurar ect..
              if(!isMyPerfil)
                Row(children: [
                  //Seguir Desseguir
                  Expanded(child: FlatButton(
                      child: FittedBox(
                          child: Text(
                              (isTipster ? (isPendente ? 'Pendente' : (isSeguindo ? 'Remover' : 'Seguir')) : ''),
                              style: itemTextStyle)),
                      onPressed: isTipster ? isPendente ? (/*Remover Pendente*/) async {
                        _setProgressBarVisible(true);
                        if (await _user.removeSolicitacao(eu.dados.id))
                          setState(() {
                            isPendente = false;
                          });
                        _setProgressBarVisible(false);
                      } : isSeguindo ? (/*Desseguir*/) async {
                        _setProgressBarVisible(true);
                        if (await _user.removeSeguidor(eu))
                          setState(() {
                            isPendente = isSeguindo = false;
                          });
                        _setProgressBarVisible(false);
                      } : (/*Seguir*/) async {
                        _setProgressBarVisible(true);
                        if (await _user.addSolicitacao(eu))
                          setState(() {
                            isPendente = true;
                          });
                        _setProgressBarVisible(false);
                      } : null)),
                  Expanded(child: FlatButton(
                      child: FittedBox(child: Text(isFilialPendente ? 'Recusar' : ' ', style: itemTextStyle)),
                      onPressed: isFilialPendente ? () async {
                        _setProgressBarVisible(true);
                        if (await eu.removeSolicitacao(_user.dados.id))
                          setState(() {
                            isFilialPendente = false;
                          });
                        _setProgressBarVisible(false);
                      } : null)),
                  Expanded(child: FlatButton(
                      child: FittedBox(child: Text(isFilial ? 'Remover' : isFilialPendente ? 'Aceitar' : ' ', style: itemTextStyle)),
                      onPressed: isFilial ? (/*Remover Filial*/) async {
                        _setProgressBarVisible(true);
                        if (await eu.removeSeguidor(_user))
                          setState(() {
                            isFilial = false;
                          });
                        _setProgressBarVisible(false);
                      } : isFilialPendente ? (/*Aceitar Filial*/) async {
                        _setProgressBarVisible(true);
                        if (await eu.aceitarSeguidor(_user))
                          setState(() {
                            isFilial = true;
                          });
                        _setProgressBarVisible(false);
                      } : null))
                ]),
            ]),
          ),

          bottom: TabBar(
            tabs: tabs,
          ),
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
        body: TabBarView(
          children: tabItems,
        ),
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
                    child: MyLayouts.fotoPostNetwork(item.foto),
                    onTap: () {
                      MyLayouts.showPopupPostPerfil(context, item);
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
            Divider(height: 2, thickness: 1, color: MyTheme.textColorInvert()),
            //Titulo
            if(item.titulo.isNotEmpty)
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(10),
                color: MyTheme.primary(),
                child: Text(item.titulo,
                    style: TextStyle(color: MyTheme.textColor(), fontSize: 20)
                ),
              ),
            //Foto
            MyLayouts.fotoPostNetwork(item.foto),
            //Legenda
            if(item.texto.isNotEmpty)
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                color: MyTheme.transparentColor(),
                child: Text(item.texto, style: TextStyle(
                    color: MyTheme.textColorInvert(), fontSize: 20)),
              ),
          ],
        );
      },
    );
  }

  User getArgs() {
    var args = ModalRoute.of(context).settings.arguments;
    if (args == null || !(args is User)) {
      Navigator.pop(context);
      return null;
    }
    return args;
  }

  _updateUser() async {
    if (_user == null)
      return;
    var item = await getUsers.baixarUser(_user.dados.id);
    if (item != null) {
      getUsers.add(item);
      setState(() {
        _user = item;
      });
    }
    _isdadosAtualizados = true;
  }

  _loadPagamento() async {
    bool result = await Pagamento.load(_user.dados.id);
    setState(() {
      _isPagamentoLoaded = !result;
    });
  }

  _setProgressBarVisible(bool visible) {
    setState(() {
      _inProgress = visible;
    });
  }

  //endregion

}