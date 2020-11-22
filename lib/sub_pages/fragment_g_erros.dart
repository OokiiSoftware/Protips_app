import 'package:flutter/material.dart';
import 'package:protips/model/error.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/res/strings.dart';

class FragmentErros extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<FragmentErros> with AutomaticKeepAliveClientMixin<FragmentErros> {

  //region Variaveis
  static const String TAG = 'FragmentErros';

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<Erro> _data = new List<Erro>();
  bool isAtualizando = false;
  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if(_data.length == 0) {
      _data.addAll(getErros.data);
    }
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
      floatingActionButton: isAtualizando ? CircularProgressIndicator() :
      FloatingActionButton(
        tooltip: 'Deletar Tudo',
        child: Icon(Icons.delete_forever),
        onPressed: _deleteAll,
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
        children: _data.map<ExpansionPanel>((Erro item) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(item.classe + ' (' + (item.similares.length + 1).toString() + ')' ),
                subtitle: Text(item.metodo),
                onTap: () {
                  setState(() {
                    item.isExpanded = !item.isExpanded;
                  });
                },
              );
            },
            body: ListTile(
              title: Text(item.data),
              subtitle: Text(item.valor),
              onLongPress: () async {
                _setAtualizando(true);
                if (await item.deleteAll()) {
                  getErros.remove(item.data);
                  _data.remove(item);
                }
                setState(() {});
                _setAtualizando(false);
              },
            ),
            isExpanded: item.isExpanded,
          );
        }).toList(),
      );
    } catch(e) {
      return Container();
    }
  }

  Future<void> _deleteAll() async {
    var result = await DialogBox.dialogCancelOK(context, title: 'Excluir todos os dados?');
    if (result.isPositive)
    try {
      _setAtualizando(true);
      var result = await FirebasePro.database
          .child(FirebaseChild.LOGS)
          .remove()
          .then((value) => true)
          .catchError((ex) => false);
      if (result) {
        setState(() {
          _data.clear();
        });
        Log.snackbar('Sucesso');
      }
      else
        Log.snackbar(MyErros.ERRO_GENERICO, isError: true);
    } catch(e) {
      //Todo \(ºvº)/
    }
    _setAtualizando(false);
  }

  Future<void> _onRefresh() async {
    await getErros.baixar();
    _data.clear();
    setState(() {
      _data.addAll(getErros.data);
    });
  }

  void _setAtualizando(bool b) {
    setState(() {
      isAtualizando = b;
    });
  }

  //endregion
}