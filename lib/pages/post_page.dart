import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/post.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/strings.dart';

class PostPage extends StatefulWidget {
  final Post post;
  PostPage(this.post);
  @override
  State<StatefulWidget> createState() => MyWidgetState(post);
}
class MyWidgetState extends State<PostPage> {

  MyWidgetState(this.post);
  //region Variaveis
  static const String TAG = 'PostPage';

  bool _inProgress = false;

  Post post;
  //endregion

  //region overrides

  @override
  Widget build(BuildContext context) {
    var item = ModalRoute.of(context).settings.arguments;
    if (item == null || !(item is Post))
      Navigator.of(context);
    post = item;
    return Scaffold(
      appBar: AppBar(title: Text(Titles.MAIN)),
      body: SingleChildScrollView(
        child: itemLayout(post),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
    );
  }

  //endregion

  //region Metodos

  Widget itemLayout(Post item) {
    String meuId = FirebasePro.user.uid;

    return Layouts.post(
        context,
        item,
        false,
        onMenuItemPostCliked,
        onGreenTap: () async {
          _setInProgress(true);
          if (item.bom.containsKey(meuId))
            await item.removeBom(meuId);
          else
            await item.addBom(meuId);
          _setInProgress(false);
          setState(() {});
        },
        onRedtap: () async {
          _setInProgress(true);
          if (item.ruim.containsKey(meuId))
            await item.removeRuim(meuId);
          else
            await item.addRuim(meuId);
          _setInProgress(false);
          setState(() {});
        }
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
    _setInProgress(false);
    String titulo = MyStrings.EXCLUIR;
    var content = Text(MyTexts.EXCLUIR_POST_PERMANENTE);
    var result = await DialogBox.dialogSimNao(context, title: titulo, content: [content]);
    if (!result.isPositive) return;
    _setInProgress(true);
    if (await item.excluir()) {
      getPosts.remove(item.id);
      Log.snackbar('Post excluido');
      Navigator.pop(this.context, 'excluido');
    } else {
      _setInProgress(false);
      Log.snackbar('Erro ao excluir Post', isError: true);
    }
  }

  _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion

}