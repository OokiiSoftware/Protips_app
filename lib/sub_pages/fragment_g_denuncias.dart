import 'package:flutter/material.dart';
import 'package:protips/model/denuncia.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/pages/perfil_page_tipster.dart';
import 'package:protips/pages/post_page.dart';
import 'package:protips/auxiliar/firebase.dart';

class FragmentDenunciasG extends StatefulWidget {
  final UserPro user;
  FragmentDenunciasG([this.user]);
  @override
  State<StatefulWidget> createState() => MyWidgetState(user);
}
class MyWidgetState extends State<FragmentDenunciasG> with AutomaticKeepAliveClientMixin<FragmentDenunciasG> {

  MyWidgetState(this.user);
  //region Variaveis
  static const String TAG = 'FragmentErros';

  UserPro user;
  List<Denuncia> _data = new List<Denuncia>();

  bool _inProgress = false;
  bool _isAdmin = false;

  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isAdmin = FirebasePro.isAdmin;
    _preencherList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(children: [
          Container(child: _itemLayout())
        ]),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() : Container(),
    );
  }

  //endregion

  //region Metodos

  Widget _itemLayout() {
    try {
      return ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _data[index].isExpanded = !isExpanded;
          });
        },
        children: _data.map<ExpansionPanel>((Denuncia item) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(item.assunto + ' (' + item.quantidade.toString() + ')' ),
                subtitle: Text(item.isUser ? 'Usuário' : 'Post'),
                onTap: () {
                  setState(() {
                    item.isExpanded = !item.isExpanded;
                  });
                },
              );
            },
            body: ListTile(
              title: Row(children: [
                if (user == null || !item.isUser) Tooltip(message: 'Visualizar', child: IconButton(icon: Icon(Icons.visibility), onPressed: () async {
                  if (item.isUser) {
                    UserPro user = await getUsers.get(item.idUser);
                    Navigate.to(context, PerfilTipsterPage(user));
                  } else {
                    Post post = await getPosts.baixar(item.itemKey, item.idUser);
                    if (post != null)
                      Navigate.to(context, PostPage(post));
                  }
                })),
                if (_isAdmin) Tooltip(message: 'Deletar', child: IconButton(icon: Icon(Icons.delete_forever), onPressed: () async {
                    _setAtualizando(true);
                    if (user == null ? await item.delete() : await user.removeDenuncia(item.data)) {
                      getDenuncias.remove(item.data);
                      setState(() {
                        _data.remove(item);
                      });
                    }
                    _setAtualizando(false);
                  })),
                if (user == null) Tooltip(message: 'Aprovar Denúncia', child: IconButton(icon: Icon(Icons.offline_pin), onPressed: () async {
                  _onAprovarDenuncia(item);
                })),
              ]),
              subtitle: Text(item.texto),
            ),
            isExpanded: item.isExpanded,
          );
        }).toList(),
      );
    } catch(e) {
      return Container();
    }
  }

  Future<void> _onRefresh() async {
    await getDenuncias.baixar();
    _preencherList();
  }

  _onAprovarDenuncia(Denuncia item) async {
    var _controler = TextEditingController();
    _controler.text = item.texto;

    var result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Escreva o que o usuário verá'),
          content: TextField(
            controller: _controler,
          ),
          actions: [
            FlatButton(child: Text('Cancelar'), onPressed: () {Navigator.pop(context);}),
            FlatButton(child: Text('Enviar'), onPressed: () {Navigator.of(context).pop(_controler.text);})
          ],
        );
      }
    );
    if (result != null && result.toString().isNotEmpty) {
      item.texto = result;
      _setAtualizando(true);
      if (await item.aprovar()) {
        getDenuncias.remove(item.data);
        setState(() {
          _data.remove(item);
        });
      }
      _setAtualizando(false);
    }
  }

  _preencherList() {
    _data.clear();
    setState(() {
      _data.addAll(user == null ? getDenuncias.data : user.denuncias.values.toList());
    });
  }

  _setAtualizando(bool b) {
    setState(() {
      _inProgress = b;
    });
  }

  //endregion
}