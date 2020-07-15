import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/user.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/pages/crop_page.dart';
import 'package:protips/pages/meu_perfil_page.dart';
import 'package:protips/pages/notificacoes_page.dart';
import 'package:protips/pages/post_page.dart';
import 'package:protips/res/resources.dart';
import 'package:random_string/random_string.dart';

class FragmentPerfil extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<FragmentPerfil> {

  //region Variaveis
  static const String TAG = 'FragmentPerfil';

  List<PostPerfil> data = new List<PostPerfil>();
  bool hasNotificacao = false;

  User user/* = getFirebase.user()*/;

  double progressBarValue = 0;
  LinearProgressIndicator progressBar;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    progressBar = LinearProgressIndicator(value: progressBarValue);
    data.addAll(getFirebase.user().post_perfil.values.toList()..sort((a, b) => a.data.compareTo(b.data)));
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis
    double itemFontSize = 15;
    double itemSpacing = 3;
    Color itemColor = MyTheme.primaryLight2();
    var itemTextStyle = TextStyle(color: MyTheme.textColor(), fontSize: itemFontSize);
    var headItemPadding = Padding(padding: EdgeInsets.only(left: 3));

//    double heightScreen = MediaQuery.of(context).size.height;

    var gridItemPadding = EdgeInsets.all(10);
    var gridItemBackground = MyTheme.primaryDark();
    double gridSpace = 5;
    double headerHeight = 140;

    user = getFirebase.user();
    UserDados dados = user.dados;

    String foto = dados.foto;
    bool fotoNull = foto == null || foto.isEmpty;

    if (user.seguidoresPendentes.length > 0)
      hasNotificacao = true;

    //endregion

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          //Header
          SliverAppBar(
            expandedHeight: headerHeight,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                height: headerHeight,
                padding: EdgeInsets.all(10),
                color: MyTheme.primaryLight(),
                child: Row(
                  children: [
                    //Foto
                    Container(
                      child: Tooltip(
                        message: MyTooltips.EDITAR_PERFIL,
                        child: GestureDetector(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: fotoNull ? Image.asset(MyIcons.ic_person) :
                                Image.network(foto,
                                    width: 100,
                                    height: 100,
                                    errorBuilder: (c, u, e) => Image.asset(MyIcons.ic_person)),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.add_circle, size: 35, color: MyTheme.accent())
                              ))
                            ],
                          ),
                          onTap: () {
                            _onPerfilPage();
                        },
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: 5)),
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
                            Text((dados.isTipster ? MyStrings.FILIADOS : MyStrings.TIPSTERS) + ': ' +
                                    (dados.isTipster ? user.seguidores.values.length.toString() :
                                    user.seguindo.values.length.toString()), style: itemTextStyle)
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          //progressBar
          SliverPadding(
            padding: EdgeInsets.all(0),
            sliver: SliverGrid.count(
              crossAxisCount: 1,
              childAspectRatio: 90,
              children: [
                progressBar
              ],
            ),
          ),
          //Grid Botões
          SliverPadding(
            padding: EdgeInsets.only(left: 5, right: 5),
            sliver: dados.isTipster ? SliverGrid.count(
              crossAxisSpacing: gridSpace,
              mainAxisSpacing: gridSpace,
              crossAxisCount: 3,
              children: [
                buttonNotificacoes(gridItemPadding, gridItemBackground),
                buttonN(gridItemPadding, gridItemBackground),
                buttonF(gridItemPadding, gridItemBackground),
                buttonNewPost(gridItemBackground),
                buttonNewPerfilPost(gridItemBackground),
              ],
            ) :
            SliverGrid.count(
              crossAxisSpacing: gridSpace,
              mainAxisSpacing: gridSpace,
              crossAxisCount: 3,
              children: [
                buttonNotificacoes(gridItemPadding, gridItemBackground),
                buttonN(gridItemPadding, gridItemBackground),
                buttonF(gridItemPadding, gridItemBackground),
              ],
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.all(0),
            sliver: SliverGrid.count(
              crossAxisCount: 1,
              childAspectRatio: 10,
              children: [
                Container(
                  child: dados.isTipster ? Container(
                    height: 40,
                    margin: EdgeInsets.only(top: gridSpace),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: MyTheme.primaryDark()),
                    child: Text('Meus Posts'.toUpperCase(), style: itemTextStyle),
                  ) :
                  Container(),
                ),
              ],
            ),
          ),
          //PostList
          SliverPadding(
            padding: EdgeInsets.all(5),
            sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: itemSpacing,
                  crossAxisSpacing: itemSpacing,
                ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = data[index];
                return Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    //foto
                    Container(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          child: Image.network(item.foto),
                          onTap: () {
                            Import.showPopup(context, item);
                          },
                        )
                    ),
                    //botão excluir
                    IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(color: MyTheme.textColorInvert(), offset: Offset(-5, 5), blurRadius: 40)
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
      ),
    );
  }

  //endregion

  //Notificações
  Widget buttonNotificacoes(EdgeInsets padding, Color backcolor) {
    return Container(
      padding: padding,
      color: backcolor,
      child: Tooltip(
        message: MyTooltips.NOTIFICACOES,
        child: ButtonTheme(
          minWidth: double.infinity,
          height: double.infinity,
          child: FlatButton(
            child: Image.asset(hasNotificacao?MyIcons.ic_sms_2:MyIcons.ic_sms),
            onPressed: () {
              Navigator.of(context).pushNamed(NotificacoesPage.tag);
            },
          ),
        ),
      ),
    );
  }

  Widget buttonN(EdgeInsets padding, Color backcolor) {
    return Container(
      padding: padding,
      color: backcolor,
      child: ButtonTheme(
        minWidth: double.infinity,
        height: double.infinity,
        child: FlatButton(
          child: Image.asset(MyIcons.ic_cash),
          onPressed: (){

          },
        ),
      ),
    );
  }

  Widget buttonF(EdgeInsets padding, Color backcolor) {
    return Container(
      padding: padding,
      color: backcolor,
      child: ButtonTheme(
        minWidth: double.infinity,
        height: double.infinity,
        child: FlatButton(
          child: Image.asset(MyIcons.ic_planilha),
          onPressed: (){

          },
        ),
      ),
    );
  }
  //Button newPost
  Widget buttonNewPost(Color backcolor) {
    return Container(
      color: backcolor,
      child: Tooltip(
        message: MyTooltips.POSTAR_TIP,
        child: ButtonTheme(
          minWidth: double.infinity,
          height: double.infinity,
          child: FlatButton(
            child: Image.asset(MyIcons.ic_lamp),
            onPressed: _onNewPost,
          ),
        ),
      ),
    );
  }
  //Button newPerfilPost
  Widget buttonNewPerfilPost(Color backcolor) {
    return Container(
      color: backcolor,
      child: Tooltip(
        message: MyTooltips.POSTAR_NO_PERFIL,
        child: ButtonTheme(
          minWidth: double.infinity,
          height: double.infinity,
          child: FlatButton(
            child: Icon(Icons.add, color: MyTheme.tintColor(), size: 100),
            onPressed: onPerfilPost,
          ),
        ),
      ),
    );
  }

  //region Metodos

  Future<void> onPerfilPost() async {
    var result = await Navigator.of(context).pushNamed(CropImagePage.tag, arguments: 1/1);
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
                    setState(() {
                      progressBarValue = null;
                    });
                    PostPerfil post = new PostPerfil();
                    post.id = randomString(10);
                    post.foto = result.path;
                    post.titulo = _titulo.text;
                    post.texto = _legenda.text;
                    post.id_tipster = getFirebase.fUser().uid;
                    post.data = DateTime.now().toString();

                    Navigator.of(context).pop();
                    bool resultOK = await post.postar();
                    setState(() {
                      if (resultOK) {
                        data.add(post);
                      }
                      progressBarValue = 0;
                    });
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
            content: Text(MyStrings.MSG_EXCLUIR_POST_PERFIL),
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
                  Navigator.pop(context);
                  bool result = await item.excluir();
                  setState(() {
                    if (result) {
                      data.remove(item);
                      getFirebase.user().post_perfil.remove(item.id);
                    }
                  });
                },
              ),
            ],
          );
      }
    );
  }

  _onPerfilPage() {
    Navigator.of(context).pushNamed(MeuPerfilPage.tag);
  }

  _onNewPost() {
    Navigator.of(context).pushNamed(PostPage.tag);
  }

  //endregion
}