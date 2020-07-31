import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/model/error.dart';
import 'package:protips/auxiliar/import.dart';

class FragmentErros extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<FragmentErros> {

  //region Variaveis
  static const String TAG = 'FragmentErros';

  List<Error> _data = new List<Error>();

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    if(_data.length == 0) {
      _data.addAll(getErros.data);
    }
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
        children: _data.map<ExpansionPanel>((Error item) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(item.classe + ' (' + item.quantidade.toString() + ')' ),
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
                if (await item.delete()) {
                  getErros.remove(item.data);
                  setState(() {
                    _data.remove(item);
                  });
                }
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

  Future<void> _onRefresh() async {
    await getErros.baixar();
    _data.clear();
    setState(() {
      _data.addAll(getErros.data);
    });
  }

  //endregion
}