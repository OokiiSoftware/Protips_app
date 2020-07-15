import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user.dart';
import 'package:protips/pages/meu_perfil_page.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/res/resources.dart';

class FragmentInicio extends StatefulWidget {
  List<Post> data;
  FragmentInicio({this.data});
  @override
  State<StatefulWidget> createState() => MyWidgetState(data: data);
}
class MyWidgetState extends State<FragmentInicio> {

  MyWidgetState({this.data});

  //region Variaveis
  static const String TAG = 'FragmentInicio';

  List<Post> data = List<Post>();
  static bool canOpenPerfil = false;

  static double progressBarValue = 0;
  static CircularProgressIndicator progressBar;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    if (data == null) {
      data = List<Post>();
      canOpenPerfil = true;
    }
    _onRefresh();
    progressBar = CircularProgressIndicator(value: progressBarValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              final item = data[index];
              return itemLayout(item);
            }
        ),
      ),
      floatingActionButton: progressBar,
    );
  }

  //endregion

  //region Metodos

  Widget itemLayout(Post item) {
    User user = getTipster.get(item.id_tipster);
    bool isMyPost = item.id_tipster == getFirebase.fUser().uid;

    var divider = Divider(color: MyTheme.textColorInvert(), height: 1, thickness: 1);

    return Container(
      alignment: Alignment.center,
      child: Column(children:[
        //header
        GestureDetector(
            child: Container(
              color: MyTheme.tintColor2(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Foto
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: item == null ?
                      Image.asset(MyIcons.ic_person, color: Colors.black) :
                      ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                              user.dados.foto,
                              width: 40,
                              height: 40,
                              errorBuilder: (c, u, e) => Image.asset(MyIcons.ic_person)
                          )
                      )
                  ),
                  //Dados
                  Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.dados?.nome ?? '', style: TextStyle(fontSize: 17)),
                      Text(item?.data)
                    ],
                  )),
                  //Menu
                  PopupMenuButton<String>(
                      onSelected: (String result) {
                        _onMenuItemPostCliked(result, item);
                      },
                      itemBuilder: (BuildContext context) {
                        var list = List<String>();
                        list.addAll(MyMenus.post);
                        if (isMyPost)
                          list.remove(MyMenus.DENUNCIAR);
                        else
                          list.remove(MyMenus.EXCLUIR);
                        if (item.link.isEmpty)
                          list.remove(MyMenus.ABRIR_LINK);

                        return list.map((item) =>
                            PopupMenuItem<String>(value: item, child: Text(item))).toList();
                      }
                  ),
                ],
              ),
            ),
            onTap: canOpenPerfil ? () {
              if (user.dados.id == getFirebase.fUser().uid)
                Navigator.of(context).pushNamed(MeuPerfilPage.tag);
              else
                Navigator.of(context).pushNamed(PerfilPage.tag, arguments: user);
            } : null,
          ),
         Divider(
            color: MyTheme.accent(),
            height: 3,
            thickness: 3,
          ),
        //Titulo
        Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(7),
            child: Text(item?.titulo, style: TextStyle(fontSize: 17)),
          ),
        //Foto
        Container(
              child: item == null ?
              Image.asset(MyIcons.ic_person, color: Colors.black) :
              Image.network(
                  item.foto,
                  errorBuilder: (c, u, e) => Image.asset(MyIcons.ic_person)
              )
          ),
        divider,
        //descricao
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
            child: Text(item.descricao),
          ),
        //Dados
        Column(
            children: [
              //categoria
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(MyStrings.CATEGORIA),
                  Text(item.esporte),
                  Text(item.linha),
                ],
              ),
              //ODD Atual
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(MyStrings.ODD_ATUAL),
                  Text(item.odd_atual),
                  Text(item.unidade),
                ],
              ),
              divider,
              //Minimos e maximos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(''),
                  Text(MyStrings.MINIMO),
                  Text(MyStrings.MAXIMO),
                ],
              ),
              //Odd
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(MyStrings.ODD),
                  Text(item.odd_minima),
                  Text(item.odd_maxima),
                ],
              ),
              //Horarios
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(MyStrings.HORARIO),
                  Text(item.horario_minimo),
                  Text(item.horario_maximo),
                ],
              ),
              divider,
            ],
          )
      ])
    );
  }

  _onMenuItemPostCliked(String value, Post post) {
    switch(value) {
      case MyMenus.ABRIR_LINK:
        Import.openUrl(context, post.link);
        break;
      case MyMenus.EXCLUIR:
        _onDelete(post);
        break;
      case MyMenus.DENUNCIAR:
        break;
    }
  }

  _onDelete(Post item) async {
    progressBarValue = 0;
    String titulo = MyStrings.EXCLUIR;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(MyTexts.EXCLUIR_POST_PERMANENTE),
        actions: [
          FlatButton(
            child: Text(MyStrings.CANCELAR),
            onPressed: () {Navigator.pop(context);},
          ),
          FlatButton(
            child: Text(MyStrings.SIM),
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                titulo = MyStrings.EXCLUIR;
                progressBarValue = null;
              });
              if (await item.excluir()) {
                setState(() {
                  data.removeWhere((e) => e.id == item.id);
                });
                getPosts.remove(item.id);
              } else {
                setState(() {
                  titulo = MyStrings.EXCLUIR + ': ' + MyErros.ERRO_GENERICO;
                  progressBarValue = 0;
                });
              }
              },
          ),
        ],
      )
    );
  }

  Future<void> _onRefresh() async {
    await getUsers.baixar();
    data.clear();
    data.addAll(getPosts.postes);
    setState(() {});
  }

  //endregion
}