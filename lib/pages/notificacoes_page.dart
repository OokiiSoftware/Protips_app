import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/config.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/notificacao.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/pages/perfil_page_tipster.dart';
import 'package:protips/res/layouts.dart';
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
  UserPro user;
  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    user = FirebasePro.userPro;
    _addSeguidoresPendentes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Titles.NOTIFICACOES),
        actions: [
          if (RunTime.semInternet)
            Layouts.icAlertInternet,
          Layouts.appBarActionsPadding,
        ],
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
              leading: item.hasFoto ? Layouts.clipRRectFormatUser(
                  radius: 50,
                  child: fotoLocal ?
                  Layouts.fotoUserFile(File(item.foto)) :
                  Layouts.fotoUserNetwork(item.foto)
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
    user = FirebasePro.userPro;
    _data.clear();
    await _addSeguidoresPendentes();
    if(!mounted) return;
    setState(() {});
  }

  _addSeguidoresPendentes() async {
    if (user.filiadosPendentes.length > 0)
      for (String key in user.filiadosPendentes.values) {
        UserPro item = await getUsers.get(key);
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
              if (await user.removeSolicitacao(item.dados.id)) {
                if(!mounted) return;
                setState(() {
                  _data.removeWhere((x) => x.id == id);
                });
              }
            },
          ),
          FlatButton(
            child: Text('Aceitar'.toUpperCase()),
            onPressed: () async {
              if (await user.aceitarFiliado(item)) {
                if(!mounted) return;
                setState(() {
                  _data.removeWhere((x) => x.id == id);
                });
              }
            },
          ),
        ]);
        String foto = item.dados.fotoLocalExist ? item.dados.fotoToFile.path : item.dados.foto;
        Notificacao n = Notificacao(id: id, titulo: titulo, subtitulo: subtitulo, isFotoLocal: item.dados.fotoLocalExist,
            eTitulo: eTitulo, eSubtitulo: eSubtitulo, foto: foto, onTap: () {
              Navigate.to(context, PerfilTipsterPage(item));
        });

        if(!mounted) return;
        setState(() {
          _data.add(n);
        });
      }
  }

  //endregion

}