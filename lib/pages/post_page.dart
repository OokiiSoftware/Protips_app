import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/res/resources.dart';

import 'meu_perfil_page.dart';

class PostPage extends StatefulWidget {
  static const String tag = 'PostPage';
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<PostPage> {

  //region Variaveis
  static const String TAG = 'PostPage';

  double progressBarValue = 0;

  Post _post;
  LinearProgressIndicator progressBar;
  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    progressBar = LinearProgressIndicator(value: progressBarValue);
  }

  @override
  Widget build(BuildContext context) {
    var item = ModalRoute.of(context).settings.arguments;
    if (item == null || !(item is Post))
      Navigator.of(context);
    _post = item;
    return Scaffold(
      appBar: AppBar(title: Text(Titles.MAIN)),
      body: SingleChildScrollView(
        child: itemLayout(_post),
      ),
    );
  }

  //endregion

  //region Metodos

  Widget itemLayout(Post item) {
    User user = getTipster.get(item.idTipster);
    double fotoUserSize = 40;
    bool isMyPost = item.idTipster == getFirebase.fUser().uid;

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
                          child: MyIcons.fotoUser(user.dados, fotoUserSize)
//                          Image.file(user.dados.fotoToFile, width: fotoUserSize, height: fotoUserSize) :
//                          Image.network(
//                              user.dados.foto, width: fotoUserSize, height: fotoUserSize,
//                              errorBuilder: (c, u, e) => Image.asset(MyIcons.ic_person, width: fotoUserSize, height: fotoUserSize)
//                          )
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
                        onMenuItemPostCliked(result, item);
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
            onTap: () {
              if (user.dados.id == getFirebase.fUser().uid)
                Navigator.of(context).pushNamed(MeuPerfilPage.tag);
              else
                Navigator.of(context).pushNamed(PerfilPage.tag, arguments: user);
            },
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
              child: MyIcons.fotoPost(item)
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
                  Text(item.oddAtual),
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
                  Text(item.oddMinima),
                  Text(item.oddMaxima),
                ],
              ),
              //Horarios
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(MyStrings.HORARIO),
                  Text(item.horarioMinimo),
                  Text(item.horarioMaximo),
                ],
              ),
              divider,
            ],
          )
        ])
    );
  }

  onMenuItemPostCliked(String value, Post post) {
    switch(value) {
      case MyMenus.ABRIR_LINK:
        Import.openUrl(post.link, context);
        break;
      case MyMenus.EXCLUIR:
        onDelete(post);
        break;
      case MyMenus.DENUNCIAR:
        break;
    }
  }

  onDelete(Post item) async {
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
                  getPosts.remove(item.id);
                  setState(() {
                    Navigator.pop(this.context, 'excluido');
                  });
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

  //endregion

}