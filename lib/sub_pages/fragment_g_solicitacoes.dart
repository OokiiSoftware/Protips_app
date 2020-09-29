import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/model/user.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/pages/perfil_tipster_page.dart';
import 'package:protips/res/resources.dart';

class FragmentSolicitacoes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<FragmentSolicitacoes> with AutomaticKeepAliveClientMixin<FragmentSolicitacoes> {

  //region Variaveis
  static const String TAG = 'FragmentSolicitacoes';

  List<User> _data = new List<User>();

  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if(_data.length == 0) {
      _data.addAll(getSolicitacoes.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
      children: _data.map<ExpansionPanel>((User item) {
        double fotoUserSize = 50;

        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: MyLayouts.iconFormatUser(
                  radius: 50,
                  child:  MyLayouts.fotoUser(item.dados, iconSize: fotoUserSize)
              ),
              title: Text(item.dados.nome),
              subtitle: Text(item.dados.tipname),
              onTap: () {
                Navigate.to(context, PerfilTipsterPage(item));
              },
            );
          },
          body: ListTile(
              title: Row(children: [
                FlatButton(
                  child: Text('Aprovar'.toUpperCase()),
                  onPressed: () async {
                    if (await item.solicitarSerTipsterAprovar())
                      _acao(item);
                  },
                ),
                FlatButton(
                  child: Text('Recusar'.toUpperCase()),
                  onPressed: () async {
                    if (await item.solicitarSerTipsterCancelar())
                      _acao(item);
                  },
                ),
              ]),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  void _acao(User item) {
    getSolicitacoes.remove(item.dados.id);
    setState(() {
      _data.remove(item);
    });
  }

  Future<void> _onRefresh() async {
//    await getUsers.baixar();
    _data.clear();
    setState(() {
      _data.addAll(getSolicitacoes.data);
    });
  }

  //endregion
}