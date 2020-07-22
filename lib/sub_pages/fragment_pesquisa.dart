import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/model/user.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/pages/meu_perfil_page.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/res/resources.dart';

class FragmentPesquisa extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<FragmentPesquisa> {

  //region Variaveis
  static const String TAG = 'FragmentPesquisa';

  List<User> _data = new List<User>();

  static var _ordemData = Import.getDropDownMenuItems(Arrays.orderUsers);
  static String _ordemCurrent = Arrays.orderUsers[0];//0 = Ranking
  static bool _ordemAsc = false;
  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    if(_data.length == 0) {
      _data.addAll(getTipster.users);
      _changeOrdem(_ordemCurrent, _ordemAsc);
    }
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(color: MyTheme.textColor());
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
        title: Row(children: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(MyTexts.ORDEM_POR, style: TextStyle(fontSize: 14)),
            ),
          Expanded(child: DropdownButton(
            value: _ordemCurrent,
            items: _ordemData,
            dropdownColor: MyTheme.primary(),
            style: textStyle,
            onChanged: (value) {_changeOrdem(value, _ordemAsc);},
          )),
          Container(
              width: 100,
              child: CheckboxListTile(
            title: Text('dsc', style: textStyle),
            value: _ordemAsc,
            contentPadding: EdgeInsets.all(0),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool value) {_changeOrdem(_ordemCurrent, value);},
          ))
          ]),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
            itemCount: _data.length,
            itemBuilder:  (BuildContext context, int index) {
              final item = _data[index];
              return _itemLayout(item);
            }
            ),
//        child: SingleChildScrollView(
//          child: Container(
//            child: _itemLayout(),
//          ),
//        ),
      ),
    );
  }

  //endregion

  //region Metodos

  void _changeOrdem(String value, bool asc) {
    setState(() {
      _ordemCurrent = value;
      _ordemAsc = asc;
    });
    switch(value) {
      case 'Ranking':
        _data.sort((a, b) => asc ? a.media().compareTo(b.media()) : b.media().compareTo(a.media()));
        break;
      case 'Nome':
        _data.sort((a, b) => asc ? b.dados.nome.compareTo(a.dados.nome) : a.dados.nome.compareTo(b.dados.nome));
        break;
      case 'Green':
        _data.sort((a, b) => asc ? a.bomCount().compareTo(b.bomCount()) : b.bomCount().compareTo(a.bomCount()));
        break;
      case 'Red':
        _data.sort((a, b) => asc ? a.ruimCount().compareTo(b.ruimCount()) : b.ruimCount().compareTo(a.ruimCount()));
        break;
      case 'Posts':
        _data.sort((a, b) => asc ? a.postes.length.compareTo(b.postes.length) : b.postes.length.compareTo(a.postes.length));
        break;
    }
  }

  Widget _itemLayout(User item) {
    double fotoUserSize = 50;
    bool fotoLocalExist = item.dados.fotoLocalExist;

    return ListTile(
      leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: fotoLocalExist ?
          Image.file(File(item.dados.fotoLocal), width: fotoUserSize, height: fotoUserSize) :
          Image.network(item.dados.foto, width: fotoUserSize, height: fotoUserSize,
              errorBuilder: (c, u, e) => Image.asset(MyIcons.ic_person, width: fotoUserSize, height: fotoUserSize)
          )
      ),
      title: Text(item.dados.nome),
      subtitle: Text(item.dados.descricao),
        onTap: () {
          if (item.dados.id == getFirebase.fUser().uid)
            Navigator.of(context).pushNamed(MeuPerfilPage.tag);
          else
            Navigator.of(context).pushNamed(PerfilPage.tag, arguments: item);
        }
    );

    //ExpansionPanelList
    /*return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((User item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                      item.dados.foto,
                      errorBuilder: (c, u, e) => Image.asset(MyIcons.ic_person)
                  )
              ),
              title: Text(item.dados.nome),
              subtitle: Text(item.dados.descricao),
            );
          },
          body: ListTile(
              title: Text(item.dados.tipname),
              subtitle: Text(
                  'Green: ' + item.bomCount().toString() +
                      '| Red: ' + item.ruimCount().toString() +
                  '| Posts: ' + item.postes.length.toString()
              ),
              trailing: Image.asset(MyIcons.ic_enter, width: 30, color: MyTheme.textColorInvert()),
              onTap: () {
                if (item.dados.id == getFirebase.fUser().uid)
                  Navigator.of(context).pushNamed(MeuPerfilPage.tag);
                else
                  Navigator.of(context).pushNamed(PerfilPage.tag, arguments: item);
              }),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );*/
  }

  Future<void> _onRefresh() async {
    await getUsers.baixar();
    _data.clear();
    setState(() {
      _data.addAll(getTipster.users);
      _changeOrdem(_ordemCurrent, _ordemAsc);
    });
  }

  //endregion
}