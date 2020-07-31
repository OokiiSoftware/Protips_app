import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/model/denuncia.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/pages/post_page.dart';

// ignore: must_be_immutable
class FragmentDenunciasG extends StatefulWidget {
  User user;
  FragmentDenunciasG([this.user]);
  @override
  State<StatefulWidget> createState() => MyWidgetState(user);
}
class MyWidgetState extends State<FragmentDenunciasG> {

  User user;
  MyWidgetState(this.user);
  //region Variaveis
  static const String TAG = 'FragmentErros';

  List<Denuncia> _data = new List<Denuncia>();

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _preencherList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(children: [
          Container(child: _itemLayout())
        ]),
      ),
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
                    User user = await getUsers.get(item.idUser);
                    Navigator.of(context).pushNamed(PerfilPage.tag, arguments: user);
                  } else {
                    Post post = await getPosts.baixar(item.itemKey, item.idUser);
                    if (post != null)
                      Navigator.of(context).pushNamed(PostPage.tag, arguments: post);
                  }
                })),
                Tooltip(message: 'Deletar', child: IconButton(icon: Icon(Icons.delete_forever), onPressed: () async {
                  if (user == null ? await item.delete() : await user.removeDenuncia(item.data)) {
                    getDenuncias.remove(item.data);
                    setState(() {
                      _data.remove(item);
                    });
                  }
                })),
                if (user == null) Tooltip(message: 'Aprovar Denúncia', child: IconButton(icon: Icon(Icons.offline_pin), onPressed: () async {
                  if (await item.aprovar()) {
                    getDenuncias.remove(item.data);
                    setState(() {
                      _data.remove(item);
                    });
                  }
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

  _preencherList() {
    _data.clear();
    setState(() {
      _data.addAll(user == null ? getDenuncias.data : user.denuncias.values);
    });
  }

  //endregion
}