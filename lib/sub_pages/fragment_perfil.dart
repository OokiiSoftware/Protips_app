import 'dart:io';
import 'package:flutter/material.dart';
import 'package:protips/animations/container_transition.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/pages/cash_page.dart';
import 'package:protips/pages/crop_page.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/pages/notificacoes_page.dart';
import 'package:protips/pages/new_post_page.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/my_icons.dart';
import 'package:protips/res/custom_tabbar.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';
import 'package:random_string/random_string.dart';

class FragmentPerfil extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<FragmentPerfil> with AutomaticKeepAliveClientMixin<FragmentPerfil> {

  //region Variaveis
  static const String TAG = 'FragmentPerfil';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final double settingsButtonRadius = 5;

  List<PostPerfil> _data = new List();
  bool hasNotificacao = false;
  bool inProgress = false;

  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _data.clear();
    _data.addAll(FirebasePro.userPro.postPerfilList);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //region Variaveis
    double itemFontSize = 15;
    double fotoSize = 90;

    var headerColor = MyTheme.darkModeOn ? MyTheme.cardColor : MyTheme.primary;
    var itemTextStyle = TextStyle(fontSize: itemFontSize);
    var itemTextStyleBold = TextStyle(fontSize: itemFontSize +2, fontWeight: FontWeight.bold);
    var headItemPadding = Padding(padding: EdgeInsets.only(top: 10, left: 5));

    var user = FirebasePro.userPro;
    UserDados dados = user.dados;

    bool souTipster = dados.isTipster && !user.solicitacaoEmAndamento();

    double tabBarHeight = 40;
    double headerHeight = 180;
    if (!souTipster)
      headerHeight -= tabBarHeight;

    _checkNotificacoes();

    var tabBar = [Tab(icon: Icon(MyIcons.settings, size: 21.5))];
    var tabBarView = [_ferramentas(souTipster)];

    if (souTipster) {
      tabBar.add(Tab(icon: Icon(Icons.view_module)));
      tabBarView.add(_publicacoes());
    }

    //endregion

    return DefaultTabController(
      length: tabBar.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: headerHeight,
          elevation: 0,
          backgroundColor: headerColor,
          title: Column(
            children: [
              Row(
                children: [
                  //Foto
                  OpenContainerWrapper(
                    tooltip: MyTooltips.EDITAR_PERFIL,
                    statefulWidget: PerfilPage(),
                    background: headerColor,
                    child: Container(
                      color: headerColor,
                      child: Layouts.clipRRectFormatUser(
                        radius: 100,
                        child: Layouts.fotoUser(dados, iconSize: fotoSize),
                      ),
                    ),
                    onClosed: (value) => setState(() {}),
                  ),
                  Padding(padding: EdgeInsets.only(right: 15)),
                  //Dados
                  Flexible(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dados Tipster
                      if (souTipster)
                        Row(
                          children: [
                            Text(user.seguidores.values.length.toString(), style: itemTextStyleBold),
                            headItemPadding,
                            Flexible(child: Text('Seguidores', style: itemTextStyle)),
                            headItemPadding,
                            headItemPadding,
                            Text(user.filiados.values.length.toString(), style: itemTextStyleBold),
                            headItemPadding,
                            Flexible(child: Text(MyStrings.FILIADOS, style: itemTextStyle)
                            ),
                          ],
                        ),
                      // Dados Filiado
                      Row(
                        children: [
                          Text(user.seguindo.values.length.toString(), style: itemTextStyleBold),
                          headItemPadding,
                          Flexible(child: Text('Seguindo   ', style: itemTextStyle)),
                          headItemPadding,
                          headItemPadding,
                          Text(user.tipsters.values.length.toString(), style: itemTextStyleBold),
                          headItemPadding,
                          Flexible(child: Text(MyStrings.TIPSTERS, style: itemTextStyle)
                          ),
                        ],
                      ),
                      //TipName
                      Text(dados.tipname, style: itemTextStyleBold),
                      //descricao
                      Text(dados.descricao, style: itemTextStyle),
                    ],
                  ))
                ],
              ),
              headItemPadding,
              // Email
              Row(
                children: [
                  Icon(Icons.language),
                  headItemPadding,
                  Flexible(child: Text(dados.email, style: itemTextStyle)),
                ],
              ),
            ],
          ),
          bottom: !souTipster ? null : ColoredTabBar(tabs: tabBar, color: headerColor, height: tabBarHeight),
        ),
        body: TabBarView(children: tabBarView),
        floatingActionButton: inProgress ? CircularProgressIndicator() : null,
      ),
    );
  }

  //endregion

  //region Widgets

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

  Widget _publicacoes() {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(2, 2, 2, 80),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                var item = _data[index];
                return Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    //foto
                    Container(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          child: Layouts.fotoPostNetwork(item.foto),
                          onTap: () {
                            DialogBox.popupPostPerfil(context, item);
                          },
                        )
                    ),
                    //botão excluir
                    IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: MyTheme.darkModeOn ? Colors.black : Colors.white,
                                  blurRadius: 30
                              )
                            ]
                        ),
                        child: Icon(Icons.delete, /*color: MyTheme.tintColor*/),
                      ),
                      onPressed: () {
                        onPerfilPostDelete(item);
                      },
                    ),
                  ],
                );
              },
                  childCount: _data.length
              ),
            ),
          )
        ],
      ),
      // floatingActionButton: inProgress ? null : FloatingActionButton(
      //   child: Icon(Icons.add, color: Colors.white),
      //   onPressed: onPerfilPost,
      // ),
    );
  }

  AppBar get appBarAnterior {
    //region Variaveis
    double itemFontSize = 15;
    double fotoSize = 90;

    var itemColor = MyTheme.primaryLight2;
    var headerColor = MyTheme.darkModeOn ? MyTheme.cardColor : MyTheme.primaryLight;
    var itemTextStyle = TextStyle(fontSize: itemFontSize);
    var headItemPadding = Padding(padding: EdgeInsets.only(left: 5));

    double headerHeight = 180;

    var user = FirebasePro.userPro;
    UserDados dados = user.dados;

    bool isTipster = dados.isTipster && !user.solicitacaoEmAndamento();

    _checkNotificacoes();

    var tabBar = [Tab(text: 'FERRAMENTAS')];
    var tabBarView = [_ferramentas(isTipster)];

    if (isTipster) {
      tabBar.add(Tab(text: 'PUBLICAÇÕES'));
      tabBarView.add(_publicacoes());
    }
    //endregion

    return  AppBar(
      toolbarHeight: headerHeight,
      elevation: 0,
      backgroundColor: headerColor,
      title: Row(
        children: [
          //Foto
          OpenContainerWrapper(
            tooltip: MyTooltips.EDITAR_PERFIL,
            statefulWidget: PerfilPage(),
            background: headerColor,
            child: Container(
              color: headerColor,
              child: Layouts.clipRRectFormatUser(
                radius: 100,
                child: Layouts.fotoUser(dados, iconSize: fotoSize),
              ),
            ),
            onClosed: (value) => setState(() {}),
          ),
          Padding(padding: EdgeInsets.only(right: 15)),
          //Dados
          Flexible(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Nome
              Row(
                children: [
                  Icon(Icons.person, color: itemColor),
                  headItemPadding,
                  Flexible(child: Text(dados.nome, style: itemTextStyle))
                ],
              ),
              //Email
              Row(
                children: [
                  Icon(Icons.email, color: itemColor),
                  headItemPadding,
                  Flexible(child: Text(dados.email, style: itemTextStyle))
                ],
              ),
              //TipName
              Row(
                children: [
                  Icon(Icons.language, color: itemColor),
                  headItemPadding,
                  Flexible(child: Text(dados.tipname, style: itemTextStyle))
                ],
              ),
              //Filiados/Tipsters
              Row(
                children: [
                  Icon(Icons.group, color: itemColor),
                  headItemPadding,
                  Text((isTipster ? MyStrings.FILIADOS : MyStrings.TIPSTERS) + ': ' +
                      (isTipster ? user.filiados.values.length.toString() :
                      user.seguindo.values.length.toString()), style: itemTextStyle)
                ],
              ),
            ],
          ))
        ],
      ),
      bottom: ColoredTabBar(tabs: tabBar, color: headerColor, height: 40),
    );
  }

  //Notificações
  Widget buttonNotificacoes() {
    return OpenContainerWrapper(
      radius: settingsButtonRadius,
      tooltip: MyTooltips.NOTIFICACOES,
      statefulWidget: NotificacoesPage(),
      child: Container(
        color: MyTheme.cardSpecial,
        padding: EdgeInsets.all(20),
        child: Image.asset(
          hasNotificacao ? MyIcons.ic_sms_2 : MyIcons.ic_sms,
          color: hasNotificacao ? null : MyTheme.darkModeOn ? MyTheme.accent : null,
        ),
      ),
      onClosed: (value) => _checkNotificacoes(),
    );
  }

  Widget buttonCash() {
    return OpenContainerWrapper(
      radius: settingsButtonRadius,
      tooltip: MyTooltips.CASH,
      statefulWidget: CashPage(),
      child: Container(
        color: MyTheme.cardSpecial,
        padding: EdgeInsets.all(20),
        child: Image.asset(MyIcons.ic_cash,
          color: MyTheme.darkModeOn ? MyTheme.accent : Colors.white),
      ),
      onClosed: (value) => setState(() {}),
    );
    // return Container(
    //   color: MyTheme.primaryDark(),
    //   child: Tooltip(
    //     message: MyTooltips.CASH,
    //     child: FlatButton(
    //       minWidth: double.infinity,
    //       height: double.infinity,
    //       padding: EdgeInsets.all(20),
    //       child: Image.asset(MyAssets.ic_cash),
    //       onPressed: _onCash,
    //     ),
    //   ),
    // );
  }

  Widget buttonF() {
    return Container(
      color: MyTheme.cardSpecial,
      child: ButtonTheme(
        minWidth: double.infinity,
        height: double.infinity,
        child: FlatButton(
          padding: EdgeInsets.all(20),
          child: Image.asset(MyIcons.ic_planilha,
            color: MyTheme.darkModeOn ? MyTheme.accent : Colors.white,),
          onPressed: (){},
        ),
      ),
    );
  }
  //Button newPost
  Widget buttonNewPost() {
    return OpenContainerWrapper(
      radius: settingsButtonRadius,
      tooltip: MyTooltips.POSTAR_TIP,
      statefulWidget: NewPostPage(),
      child: Container(
        color: MyTheme.cardSpecial,
        padding: EdgeInsets.all(20),
        child: Image.asset(MyIcons.ic_lamp,
          color: MyTheme.darkModeOn ? MyTheme.accent : Colors.white,),
      ),
      onClosed: (value) => setState(() {}),
    );
    // return Container(
    //   color: MyTheme.primaryDark(),
    //   child: Tooltip(
    //     message: MyTooltips.POSTAR_TIP,
    //     child: FlatButton(
    //       minWidth: double.infinity,
    //       height: double.infinity,
    //       padding: EdgeInsets.all(20),
    //       child: Image.asset(MyAssets.ic_lamp),
    //       onPressed: _onNewPost,
    //     ),
    //   ),
    // );
  }
  //Button newPerfilPost
  Widget buttonNewPerfilPost() {
    return Layouts.clipRRect(
      radius: settingsButtonRadius,
      child: Container(
        color: MyTheme.cardSpecial,
        child: Tooltip(
          message: MyTooltips.POSTAR_NO_PERFIL,
          child: FlatButton(
            minWidth: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(20),
            child: Image.asset(MyIcons.ic_add,
              color: MyTheme.darkModeOn ? MyTheme.accent : Colors.white,),
            onPressed: onPerfilPost,
          ),
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

      var content = [
        TextField(
          controller: _titulo,
          decoration: InputDecoration(hintText: MyStrings.TITULO),
        ),
        Image.file(result),
        TextField(
            controller: _legenda,
            decoration: InputDecoration(hintText: MyStrings.LEGENDA)
        ),
      ];
      var resultDialog = await DialogBox.dialogCancelOK(context, content: content);
      if (resultDialog.isPositive) {
        PostPerfil post = new PostPerfil();
        post.id = randomString(10);
        post.foto = result.path;
        post.titulo = _titulo.text;
        post.texto = _legenda.text;
        post.idTipster = FirebasePro.user.uid;
        post.data = DataHora.now();

        _setInProgress(true);
        if (await post.postar()) {
          if(!mounted) return;
            setState(() {
              _data.insert(0, post);
            });
          }
        else
          Log.snackbar(MyErros.ERRO_GENERICO, isError: true);
        _setInProgress(false);
      }
    }
  }

  Future<void> onPerfilPostDelete(PostPerfil item) async {
    var title = MyStrings.EXCLUIR;
    var content = [
      Text(MyTexts.MSG_EXCLUIR_POST_PERFIL)
    ];
    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    if (result.isPositive) {
      _setInProgress(true);
      bool result = await item.excluir();
      if(!mounted) return;
      setState(() {
        if (result) {
          _data.remove(item);
        }
      });
      _setInProgress(false);
    }

    // await showDialog(
    //     context: context,
    //   builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text(MyStrings.EXCLUIR),
    //         content: Text(MyTexts.MSG_EXCLUIR_POST_PERFIL),
    //         actions: [
    //           FlatButton(
    //             child: Text(MyStrings.CANCELAR),
    //             onPressed: () {
    //               Navigator.pop(context);
    //             },
    //           ),
    //           FlatButton(
    //             child: Text(MyStrings.SIM),
    //             onPressed: () async {
    //
    //             },
    //           ),
    //         ],
    //       );
    //   }
    // );
  }

  _setInProgress(bool b) {
    setState(() {
      inProgress = b;
    });
  }

  _checkNotificacoes() {
    setState(() {
      hasNotificacao = FirebasePro.userPro.filiadosPendentes.length > 0;
    });
  }

  //endregion
}