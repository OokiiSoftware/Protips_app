import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/notificacao.dart';
import 'package:protips/model/user.dart';
import 'package:protips/pages/perfil_tipster_page.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/res/strings.dart';
import 'package:random_string/random_string.dart';

class NotificacoesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<NotificacoesPage> {

  //region Variaveis
  static const String TAG = 'NotificacoesPage';

  List<Notificacao> _data = List<Notificacao>();
  User user;
  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    user = Firebase.user;
    _addSeguidoresPendentes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Titles.NOTIFICACOES),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(children: [
          _itemLayout()
        ]),
      ),
    );
  }

  //endregion

  //region Metodos

  Widget _itemLayout() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Notificacao item) {
        bool fotoLocal = item.isFotoLocal;
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: item.hasFoto ? MyLayouts.iconFormatUser(
                  radius: 50,
                  child: fotoLocal ?
                  MyLayouts.fotoUserFile(File(item.foto)) :
                  MyLayouts.fotoUserNetwork(item.foto)
              ) : Container(),
              title: Text(item.titulo),
              subtitle: Text(item.subtitulo),
              onTap: () {
                setState(() {
                  item.isExpanded = !item.isExpanded;
                });
              },
            );
          },
          body: ListTile(
              title: Text(item.eTitulo),
              subtitle: item.eSubtitulo,
              onTap: item.onTap,
            onLongPress: item.onLongPress,
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  Future<void> _onRefresh() async {
    user = Firebase.user;
    _data.clear();
    await _addSeguidoresPendentes();
    setState(() {});
  }

  _addSeguidoresPendentes() async {
    if (user.seguidoresPendentes.length > 0)
      for (String key in user.seguidoresPendentes.values) {
        User item = await getUsers.get(key);
        if (item== null)
          continue;
        String id = randomString(10);
        String subtitulo = 'Solicitação de Filial';
        String titulo = item.dados.nome;
        String eTitulo = 'Ver perfil';
        Widget eSubtitulo = Row(children: [
          FlatButton(
            child: Text('Recusar'.toUpperCase()),
            onPressed: () async {
              if (await user.removeSolicitacao(item.dados.id))
                setState(() {
                  _data.removeWhere((x) => x.id == id);
                });
            },
          ),
          FlatButton(
            child: Text('Aceitar'.toUpperCase()),
            onPressed: () async {
              if (await user.aceitarSeguidor(item))
                setState(() {
                  _data.removeWhere((x) => x.id == id);
                });
            },
          ),
        ]);
        String foto = item.dados.fotoLocalExist ? item.dados.fotoToFile.path : item.dados.foto;
        Notificacao n = Notificacao(id: id, titulo: titulo, subtitulo: subtitulo, isFotoLocal: item.dados.fotoLocalExist,
            eTitulo: eTitulo, eSubtitulo: eSubtitulo, foto: foto, onTap: () {
              Navigate.to(context, PerfilTipsterPage(item));
        });

        setState(() {
          _data.add(n);
        });
      }
  }

  //endregion

}