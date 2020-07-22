import 'dart:io';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/notificacao.dart';
import 'package:protips/model/user.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/res/resources.dart';
import 'package:random_string/random_string.dart';

class NotificacoesPage extends StatefulWidget {
  static const String tag = 'NotificacoesPage';
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<NotificacoesPage> {

  //region Variaveis
  static const String TAG = 'NotificacoesPage';

  List<Notificacao> data = List<Notificacao>();
  User user;
  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    user = getFirebase.user();
    if (user.seguidoresPendentes.length > 0)
      _addSeguidoresPendentes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Titles.NOTIFICACOES),
      ),
      body: SingleChildScrollView(
          child: Container(
            child: _buildPanel(),
          )
      ),
    );
  }

  //endregion

  //region Metodos

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          data[index].isExpanded = !isExpanded;
        });
      },
      children: data.map<ExpansionPanel>((Notificacao item) {
        bool fotoLocal = item.isFotoLocal;
        double fotoUserSize = 50;
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: fotoLocal ?
                  Image.file(File(item.foto), width: fotoUserSize, height: fotoUserSize) :
                  Image.network(item.foto, width: fotoUserSize, height: fotoUserSize,
                      errorBuilder: (c, u, e) => Image.asset(MyIcons.ic_person, width: fotoUserSize, height: fotoUserSize)
                  )
              ),
              title: Text(item.titulo),
              subtitle: Text(item.subtitulo),
            );
          },
          body: ListTile(
              title: Text(item.eTitulo),
              subtitle: Text(item.eSubtitulo),
              trailing: Image.asset(MyIcons.ic_enter, width: 30, color: MyTheme.textColorInvert()),
              onTap: item.onTap,
            onLongPress: item.onLongPress,
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  _addSeguidoresPendentes() async {
    for (String key in user.seguidoresPendentes.values) {
      User item = await getUsers.get(key);
      if (item== null)
        continue;
      String id = randomString(10);
      String subtitulo = 'Solicitação de Filial';
      String titulo = item.dados.nome;
      String eTitulo = 'Clique para aceitar ou recurar esta solicitação';
      String eSubtitulo = 'Clique e segure para remover esta notificação';
      String foto = item.dados.fotoLocalExist ? item.dados.fotoLocal : item.dados.foto;
      Notificacao n = Notificacao(id: id, titulo: titulo, subtitulo: subtitulo, isFotoLocal: item.dados.fotoLocalExist,
          eTitulo: eTitulo, eSubtitulo: eSubtitulo, foto: foto, onTap: () {
        Navigator.of(context).pushNamed(PerfilPage.tag, arguments: item);
      },
      onLongPress: () {
        setState(() {
          data.removeWhere((element) => element.id == id);
        });
      });

      setState(() {
        data.add(n);
      });
    }
  }

  //endregion

}