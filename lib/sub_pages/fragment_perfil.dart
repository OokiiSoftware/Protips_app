import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/colored_tabbar.dart';
import 'package:protips/model/user.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/pages/cash_page.dart';
import 'package:protips/pages/crop_page.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/pages/notificacoes_page.dart';
import 'package:protips/pages/new_post_page.dart';
import 'package:protips/res/resources.dart';
import 'package:random_string/random_string.dart';

class FragmentPerfil extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<FragmentPerfil> with AutomaticKeepAliveClientMixin<FragmentPerfil> {

  //region Variaveis
  static const String TAG = 'FragmentPerfil';

  List<PostPerfil> _data = new List<PostPerfil>();
  bool hasNotificacao = false;
  bool inProgress = false;

  User user/* = getFirebase.user()*/;

//  double progressBarValue = 0;

  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //region Variaveis
    double itemFontSize = 15;
    double fotoSize = 90;

    Color itemColor = MyTheme.primaryLight2();
    var itemTextStyle = TextStyle(color: MyTheme.textColor(), fontSize: itemFontSize);
    var headItemPadding = Padding(padding: EdgeInsets.only(left: 5));

//    double heightScreen = MediaQuery.of(context).size.height;

    double headerHeight = 180;

    user = getFirebase.user;
    UserDados dados = user.dados;

    bool isTipster = dados.isTipster && !user.solicitacaoEmAndamento();

    if (user.seguidoresPendentes.length > 0)
      hasNotificacao = true;

    _data.clear();
    _data.addAll(user.postPerfilList);
//    for (int i = 0; i < 30; i++) {
//      PostPerfil p = PostPerfil();
//      p.titulo = 'Post ' + i.toString();
//      _data.add(p);
//    }

    var tabBar = [Tab(text: 'FERRAMENTAS')];
    var tabBarView = [_ferramentas(isTipster)];

    if (isTipster) {
      tabBar.add(Tab(text: 'PUBLICAÇÕES'));
      tabBarView.add(_publicacoes(_data));
    }

    //endregion

    return DefaultTabController(
      length: tabBar.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: headerHeight,
          elevation: 0,
          backgroundColor: MyTheme.primaryLight(),
          title: Row(
            children: [
              //Foto
              Container(
                child: Tooltip(
                  message: MyTooltips.EDITAR_PERFIL,
                  child: GestureDetector(
                    child: MyLayouts.iconFormatUser(
                      radius: 100,
                      child: MyLayouts.fotoUser(dados, iconSize: fotoSize),
                    ),
                    onTap: _onPerfilPage,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(right: 15)),
              //Dados
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Nome
                  Row(
                    children: [
                      Icon(Icons.person, color: itemColor),
                      headItemPadding,
                      Text(dados.nome, style: itemTextStyle)
                    ],
                  ),
                  //Email
                  Row(
                    children: [
                      Icon(Icons.email, color: itemColor),
                      headItemPadding,
                      Text(dados.email, style: itemTextStyle)
                    ],
                  ),
                  //TipName
                  Row(
                    children: [
                      Icon(Icons.language, color: itemColor),
                      headItemPadding,
                      Text(dados.tipname, style: itemTextStyle)
                    ],
                  ),
                  //Punters
                  Row(
                    children: [
                      Icon(Icons.group, color: itemColor),
                      headItemPadding,
                      Text((isTipster ? MyStrings.FILIADOS : MyStrings.TIPSTERS) + ': ' +
                          (isTipster ? user.seguidores.values.length.toString() :
                          user.seguindo.values.length.toString()), style: itemTextStyle)
                    ],
                  ),
                ],
              ),
            ],
          ),
          bottom: ColoredTabBar(tabs: tabBar, color: MyTheme.primary(), height: 40),
        ),
        body: TabBarView(children: tabBarView),
        floatingActionButton: inProgress ? CircularProgressIndicator() : Container(),
      ),
    );
  }

  //endregion

  //region Widgets

  Widget _publicacoes(List<PostPerfil> data) {
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
              return Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  //foto
                  Container(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        child: MyLayouts.fotoPostNetwork(item.foto),
                        onTap: () {
                          MyLayouts.showPopupPostPerfil(context, item);
                        },
                      )
                  ),
                  //botão excluir
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: MyTheme.textColorInvert(),
                                offset: Offset(-5, 5),
                                blurRadius: 40)
                          ]
                      ),
                      child: Icon(Icons.delete, color: MyTheme.tintColor()),
                    ),
                    onPressed: () {
                      onPerfilPostDelete(item);
                    },
                  ),
                ],
              );
            },
                childCount: data.length
            ),
          ),
        )
      ],
    );
  }

  Widget _ferramentas(bool isTipster) {
    const double itemSpacing = 5;
    const double gridSpace = 5;

    return GridView.count(
      crossAxisSpacing: gridSpace,
      mainAxisSpacing: gridSpace,
      crossAxisCount: 3,
      padding: const EdgeInsets.all(itemSpacing),
      children: [
        buttonNotificacoes(),
        if(isTipster)...[
          buttonNewPost(),
          buttonCash(),
          buttonNewPerfilPost(),
        ],
      ],
    );
  }

  //Notificações
  Widget buttonNotificacoes() {
    return Container(
      color: MyTheme.primaryDark(),
      child: Tooltip(
        message: MyTooltips.NOTIFICACOES,
        child: ButtonTheme(
          minWidth: double.infinity,
          height: double.infinity,
          child: FlatButton(
            padding: EdgeInsets.all(20),
            child: Image.asset(hasNotificacao?MyAssets.ic_sms_2:MyAssets.ic_sms),
            onPressed: () async {
              await Navigate.to(context, NotificacoesPage());
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  Widget buttonCash() {
    return Container(
      color: MyTheme.primaryDark(),
      child: Tooltip(
        message: MyTooltips.CASH,
        child: FlatButton(
          minWidth: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(20),
          child: Image.asset(MyAssets.ic_cash),
          onPressed: _onCash,
        ),
      ),
    );
  }

  Widget buttonF() {
    return Container(
      color: MyTheme.primaryDark(),
      child: ButtonTheme(
        minWidth: double.infinity,
        height: double.infinity,
        child: FlatButton(
          padding: EdgeInsets.all(20),
          child: Image.asset(MyAssets.ic_planilha),
          onPressed: (){},
        ),
      ),
    );
  }
  //Button newPost
  Widget buttonNewPost() {
    return Container(
      color: MyTheme.primaryDark(),
      child: Tooltip(
        message: MyTooltips.POSTAR_TIP,
        child: FlatButton(
          minWidth: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(20),
          child: Image.asset(MyAssets.ic_lamp),
          onPressed: _onNewPost,
        ),
      ),
    );
  }
  //Button newPerfilPost
  Widget buttonNewPerfilPost() {
    return Container(
      color: MyTheme.primaryDark(),
      child: Tooltip(
        message: MyTooltips.POSTAR_NO_PERFIL,
        child: FlatButton(
          minWidth: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(20),
          child: Image.asset(MyAssets.ic_add),
          onPressed: onPerfilPost,
        ),
      ),
    );
  }

  //endregion

  //region Metodos

  Future<void> onPerfilPost() async {
    var result = await Navigate.to(context, CropImagePage(1/1));
    if (result != null && result is File) {
      TextEditingController _titulo = TextEditingController();
      TextEditingController _legenda = TextEditingController();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: TextField(
                controller: _titulo,
                decoration: InputDecoration(hintText: MyStrings.TITULO),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Image.file(result),
                    TextField(
                        controller: _legenda,
                        decoration: InputDecoration(hintText: MyStrings.LEGENDA)
                    ),
                  ],
                ),
              ),
              actions: [
                FlatButton(
                  child: Text(MyStrings.CANCELAR),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(MyStrings.POSTAR),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _setInProgress(true);
                    PostPerfil post = new PostPerfil();
                    post.id = randomString(10);
                    post.foto = result.path;
                    post.titulo = _titulo.text;
                    post.texto = _legenda.text;
                    post.idTipster = getFirebase.fUser.uid;
                    post.data = DataHora.now();

                    if (await post.postar())
                      setState(() {});
                    else
                      Log.toast(MyErros.ERRO_GENERICO, isError: true);
                    _setInProgress(false);
                  },
                ),
              ],
            );
          }
      );
    }
  }

  Future<void> onPerfilPostDelete(PostPerfil item) async {
    await showDialog(
        context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            title: Text(MyStrings.EXCLUIR),
            content: Text(MyTexts.MSG_EXCLUIR_POST_PERFIL),
            actions: [
              FlatButton(
                child: Text(MyStrings.CANCELAR),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(MyStrings.SIM),
                onPressed: () async {
                  _setInProgress(true);
                  Navigator.pop(context);
                  bool result = await item.excluir();
                  setState(() {
                    if (result) {
                      _data.remove(item);
                      getFirebase.user.postPerfil.remove(item.id);
                    }
                  });
                  _setInProgress(false);
                },
              ),
            ],
          );
      }
    );
  }

  _onPerfilPage() async {
    await Navigate.to(context, PerfilPage());
    setState(() {});
  }

  _onNewPost() {
    Navigate.to(context, NewPostPage());
  }

  _onCash() {
    Navigate.to(context, CashPage());
  }

  void _setInProgress(bool b) {
    setState(() {
      inProgress = b;
    });
  }

  //endregion
}