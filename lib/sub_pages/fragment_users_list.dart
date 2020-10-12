import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/animations/container_transition.dart';
import 'package:protips/model/user.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/pages/perfil_filiado_page.dart';
import 'package:protips/pages/perfil_tipster_page.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

class FragmentUsersList extends StatefulWidget {
  final bool isFiliadosList;
  final bool mostrarAppBar;
  final List<User> data;
  FragmentUsersList({this.data, @required this.isFiliadosList, @required this.mostrarAppBar});
  @override
  State<StatefulWidget> createState() => MyWidgetState(data, isFiliadosList, mostrarAppBar);
}
class MyWidgetState extends State<FragmentUsersList> with AutomaticKeepAliveClientMixin<FragmentUsersList> {

  MyWidgetState(this.data, this.isFiliadosList, this.mostrarAppBar);

  //region Variaveis
  static const String TAG = 'FragmentUsersList';

  List<User> data = new List<User>();
  User _eu;

  final bool mostrarAppBar;
  static var _ordemData = Import.getDropDownMenuItems(Arrays.orderUsers);
  static String _ordemCurrent = Arrays.orderUsers[0];//0 = Ranking
  static bool _ordemAsc = false;

  final bool isFiliadosList;
  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _eu = Firebase.user;
    if(data == null) {
      data = new List<User>();
      data.addAll(getTipster.data);
      _changeOrdem(_ordemCurrent, _ordemAsc);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var textStyle = TextStyle(color: MyTheme.textColor());
    return Scaffold(
      appBar: mostrarAppBar ? AppBar(
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
      ) : null,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(children: [
          isFiliadosList ?
          _itemLayoutFiliado() :
          _itemLayoutTipster()
        ]),
      ),
    );
  }

  //endregion

  //region Metodos

  void _changeOrdem(String value, bool asc) {
    switch(value) {
      case 'Ranking':
        data.sort((a, b) => asc ? a.media().compareTo(b.media()) : b.media().compareTo(a.media()));
        break;
      case 'Nome':
        data.sort((a, b) => asc ? b.dados.nome.compareTo(a.dados.nome) : a.dados.nome.compareTo(b.dados.nome));
        break;
      case 'Green':
        data.sort((a, b) => asc ? a.bomCount.compareTo(b.bomCount) : b.bomCount.compareTo(a.bomCount));
        break;
      case 'Red':
        data.sort((a, b) => asc ? a.ruimCount.compareTo(b.ruimCount) : b.ruimCount.compareTo(a.ruimCount));
        break;
      case 'Posts':
        data.sort((a, b) => asc ? a.postes.length.compareTo(b.postes.length) : b.postes.length.compareTo(a.postes.length));
        break;
    }
    _ordemCurrent = value;
    _ordemAsc = asc;
    setState(() {});
  }

  Widget _itemLayoutTipster() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          data[index].isExpanded = !isExpanded;
        });
      },
      children: data.map<ExpansionPanel>((User item) {
        String subTitleText = 'Green: ${item.bomCount} | Red: ${item
            .ruimCount} | Posts: ${item.postes.length}';

        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return MyLayouts.userTile(
              item,
              onTap: () {
                setState(() {
                  item.isExpanded = !item.isExpanded;
                });
              },
            );
          },

          // body: ListTile(
          //     title: Text('Visitar ' + item.dados.tipname),
          //     subtitle: Text(subTitleText),
          //     onTap: () async {
          //       await Navigate.to(context, PerfilTipsterPage(item));
          //       setState(() {});
          //     }),
          isExpanded: item.isExpanded,
          body: OpenContainerWrapper(
            statefulWidget: PerfilTipsterPage(item),
            child: ListTile(
                title: Text('Visitar ' + item.dados.tipname),
                subtitle: Text(subTitleText)
            ),
            onClosed: (value) => setState(() {}),
          )
        );
      }).toList(),
    );
  }

  Widget _itemLayoutFiliado() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          data[index].isExpanded = !isExpanded;
        });
      },
      children: data.map<ExpansionPanel>((User item) {
        String mensalidadeValue = _eu.seguidores[item.dados.id] ?? '';
        if (mensalidadeValue == UserTag.PRECO_PADRAO) {
          mensalidadeValue = '${_eu.dados.precoPadrao} (Padrão)';
        }

        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: MyLayouts.iconFormatUser(
                  radius: 50,
                  child: MyLayouts.fotoUser(item.dados)
              ),
              title: Text(item.dados.nome),
              subtitle: Text(mensalidadeValue),
              onTap: () {
                setState(() {
                  item.isExpanded = !item.isExpanded;
                });
              },
            );
          },
          // body: ListTile(
          //     title: Text('Visitar '+ item.dados.tipname),
          //     onTap: () async {
          //       await Navigate.to(context, PerfilFiliadoPage(item));
          //       setState(() {});
          //     }),
          isExpanded: item.isExpanded,
            body: OpenContainerWrapper(
              statefulWidget: PerfilFiliadoPage(item),
              child: ListTile(
                  title: Text('Visitar ' + item.dados.tipname),
              ),
              onClosed: (value) => setState(() {}),
            )
        );
      }).toList(),
    );
  }

  Future<void> _onRefresh() async {
    await getUsers.baixar();
    data.clear();
    setState(() {
      if (isFiliadosList) {
        String meuId = Firebase.fUser.uid;
        data.addAll(getUsers.data.values.where((e) => e.seguindo.containsKey(meuId)));
      }
      else
        data.addAll(getTipster.data);
      _changeOrdem(_ordemCurrent, _ordemAsc);
    });
  }

  //endregion
}
/*
*
        child: Column(
          children: [
            OpenContainerWrapper(
              // statefulWidget: Navigate.to(context, PerfilTipsterPage(user)),
              closedBuilder: (BuildContext _, VoidCallback openContainer) {
                return ExampleCard(
                    openContainer: openContainer,
                  child: itemLayout(Post()),
                );
              },
              onClosed: (value) {},
            ),
            _TransitionListTile(
              title: 'Container transform',
              subtitle: 'OpenContainer',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return OpenContainerTransformDemo();
                    },
                  ),
                );
              },
            ),
            _TransitionListTile(
              title: 'Shared axis',
              subtitle: 'SharedAxisTransition',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return SharedAxisTransitionDemo();
                    },
                  ),
                );
              },
            ),
            _TransitionListTile(
              title: 'Fade through',
              subtitle: 'FadeThroughTransition',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return FadeThroughTransitionDemo();
                    },
                  ),
                );
              },
            ),
            _TransitionListTile(
              title: 'Fade',
              subtitle: 'FadeScaleTransition',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return FadeScaleTransitionDemo();
                    },
                  ),
                );
              },
            ),
          ],
        ),
* */