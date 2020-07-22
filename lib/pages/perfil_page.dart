import 'dart:io';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/user.dart';
import 'package:protips/pages/meu_perfil_page.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/sub_pages/fragment_inicio.dart';

// ignore: must_be_immutable
class PerfilPage extends StatefulWidget {
  static const String tag = 'PerfilPage';
  User user;
  PerfilPage({this.user});
  @override
  State<StatefulWidget> createState() => MyWidgetState(user: user);
}
class MyWidgetState extends State<PerfilPage> {

  //region Variaveis

  static const String TAG = 'PerfilPage';

  User user;
  MyWidgetState({this.user});

  List<Widget> tabItems;

  bool isPendente;
  bool isSeguindo;
  bool isPendenteFilial;

  LinearProgressIndicator progressBar;
  double progressBarValue = 0;

  //endregion

  //region overrides

  @override
  Widget build(BuildContext context) {
    //region Variaveis

    progressBar = LinearProgressIndicator(value: progressBarValue, backgroundColor: MyTheme.primaryLight());

    if (user == null)
      user = getArgs();
    String foto = user.dados.foto;
    bool fotoLocalExist = user.dados.fotoLocalExist;

    var eu = getFirebase.user();
    bool isMyPerfil = user.dados.id == getFirebase.fUser().uid;
    bool isTipster = user.dados.isTipster;
    bool isPendente = user.seguidoresPendentes.containsValue(eu.dados.id);
    bool isSeguindo = eu.seguindo.containsKey(user.dados.id);
    bool isFilialPendente = eu.seguidoresPendentes.containsKey(user.dados.id);
    bool isFilial = eu.seguidores.containsKey(user.dados.id);

    tabItems = [
      itemsGrid(user.postPerfil.values.toList()..sort((a, b) => a.data.compareTo(b.data))),
      itemsList(user.postPerfil.values.toList()..sort((a, b) => a.data.compareTo(b.data))),
      FragmentInicio(user: user)
    ];

    double headerHeight = 200;
    Color itemColor = MyTheme.primaryLight2();
    var itemTextStyle = TextStyle(color: MyTheme.textColor(), fontSize: 15);
    var headItemPadding = Padding(padding: EdgeInsets.only(left: 3));

    //endregion

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: headerHeight,
          automaticallyImplyLeading: false,
          backgroundColor: MyTheme.primaryLight(),
          title: Container(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 5),
            child: Column(children: [
              //Dados
              Row(children: [
                //Foto
                GestureDetector(
                  child: Container(
                      height: 100,
                      width: 100,
                      child: Stack(children: [
                        Icon(Icons.arrow_back),
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: fotoLocalExist ?
                            Image.file(File(user.dados.fotoLocal)) :
                            foto == null ? Image.asset(MyIcons.ic_person) :
                            Image.network(foto, errorBuilder: (c, u, e) => Image.asset(MyIcons.ic_person)),
                          ),
                        ),
                      ],
                      )
                  ),
                  onTap: () {Navigator.pop(context);},
                ),
                Padding(padding: EdgeInsets.only(right: 5)),
                //Dados
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Nome
                    Row(
                      children: [
                        Icon(Icons.person, color: itemColor),
                        headItemPadding,
                        Text(user.dados.nome, style: itemTextStyle)
                      ],
                    ),
                    //Email
                    /*Row(
                          children: [
                            Icon(Icons.email, color: itemColor),
                            headItemPadding,
                            Text(user.dados.email, style: itemTextStyle)
                          ],
                        ),*/
                    //TipName
                    Row(
                      children: [
                        Icon(Icons.language, color: itemColor),
                        headItemPadding,
                        Text(user.dados.tipname, style: itemTextStyle)
                      ],
                    ),
                    //Punters
                    Row(
                      children: [
                        Icon(Icons.group, color: itemColor),
                        headItemPadding,
                        Text(MyStrings.FILIADOS + ': ' + user.seguidores.values.length.toString(), style: itemTextStyle)
                      ],
                    ),
                  ],
                ),
              ]),
              progressBar,
              //Botões aceitar, recurar ect..
              Row(children: [
                //Seguir Desseguir
                Expanded(child: FlatButton(
                    child: Text(isMyPerfil ? '' : (isTipster ? (isPendente ? 'Pendente' : (isSeguindo ? 'Remover' : 'Seguir')) : ''), style: itemTextStyle),
                    onPressed: isMyPerfil ? null :
                    isTipster ? isPendente ? (/*Remover Pendente*/) async {
                      _setProgressBarVisible(true);
                      if (await user.removeSolicitacao(eu.dados.id))
                        setState(() {
                          isPendente = false;
                        });
                      _setProgressBarVisible(false);
                    } : isSeguindo ? (/*Desseguir*/) async {
                      _setProgressBarVisible(true);
                      if (await user.removeSeguidor(eu))
                        setState(() {
                          isPendente = isSeguindo = false;
                        });
                      _setProgressBarVisible(false);
                    } : (/*Seguir*/) async {
                      _setProgressBarVisible(true);
                      if (await user.addSolicitacao(eu))
                        setState(() {
                          isPendente = true;
                        });
                      _setProgressBarVisible(false);
                    } : null)),
                Expanded(child: FlatButton(
                    child: Text(isFilialPendente ? 'Recusar' : '', style: itemTextStyle),
                    onPressed: isFilialPendente ? () async {
                      _setProgressBarVisible(true);
                      if (await eu.removeSolicitacao(user.dados.id))
                        setState(() {
                          isFilialPendente = false;
                        });
                      _setProgressBarVisible(false);
                    } : null)),
                Expanded(child: FlatButton(
                    child: Text(isFilial ? 'Remover' : isFilialPendente ? 'Aceitar' : '', style: itemTextStyle),
                    onPressed: isFilial ? (/*Remover Filial*/) async {
                      _setProgressBarVisible(true);
                      if (await eu.removeSeguidor(user))
                        setState(() {
                          isFilial = false;
                        });
                      _setProgressBarVisible(false);
                    } : isFilialPendente ? (/*Aceitar Filial*/) async {
                      _setProgressBarVisible(true);
                      if (await eu.aceitarSeguidor(user))
                        setState(() {
                          isFilial = true;
                        });
                      _setProgressBarVisible(false);
                    } : null))
              ]),
            ]),
          ),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.view_module)),
              Tab(icon: Icon(Icons.list)),
              Tab(icon: Icon(Icons.lightbulb_outline)),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
                onSelected: (String result) {
                  _onMenuItemCliked(result);
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

                  return list.map((item) => PopupMenuItem<String>(value: item, child: Text(item))).toList();
                }
            )
          ],
        ),
        body: TabBarView(
          children: tabItems,
        ),
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
                    child: Image.network(item.foto),
                    onTap: () {
                      Import.showPopup(context, item);
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
            //Titulo
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.all(10),
              color: MyTheme.primary(),
              child: Text(item.titulo, style: TextStyle(color: MyTheme.textColor(), fontSize: 20)
              ),
            ),
            //Foto
            Image.network(item.foto),
            //Legenda
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              color: MyTheme.transparentColor(),
              child: Text(item.texto, style: TextStyle(color: MyTheme.textColorInvert(), fontSize: 20)),
            ),
            Divider(height: 1, thickness: 2, color: MyTheme.textColorInvert())
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

  _setProgressBarVisible(bool visible) {
    setState(() {
      progressBarValue = visible ? null : 0;
    });
  }

  _onMenuItemCliked(String value) async {
    switch(value) {
      case MyMenus.ABRIR_WHATSAPP:
        Import.openWhatsApp(context, user.dados.telefone);
        break;
      case MyMenus.DENUNCIAR:
        break;
      case MyMenus.MEU_PERFIL:
        await Navigator.of(context).pushNamed(MeuPerfilPage.tag);
        setState(() {});
        break;
    }
  }

  //endregion

}