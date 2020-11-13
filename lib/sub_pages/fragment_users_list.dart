import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protips/animations/container_transition.dart';
import 'package:protips/auxiliar/input_formatter.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/pagamento.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/pages/perfil_page_filiado.dart';
import 'package:protips/pages/perfil_page_tipster.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

class FragmentUsersList extends StatefulWidget {
  final bool isFiliadosList;
  final bool mostrarAppBar;
  final List<UserPro> data;
  FragmentUsersList({this.data, @required this.isFiliadosList, @required this.mostrarAppBar});
  @override
  State<StatefulWidget> createState() => MyWidgetState(data, isFiliadosList, mostrarAppBar);
}
class MyWidgetState extends State<FragmentUsersList> with AutomaticKeepAliveClientMixin<FragmentUsersList> {

  MyWidgetState(this.data, this.isFiliadosList, this.mostrarAppBar);

  //region Variaveis
  static const String TAG = 'FragmentUsersList';

  List<UserPro> data = new List<UserPro>();
  UserPro _eu;

  final bool mostrarAppBar;
  static var _ordemData = Import.getDropDownMenuItems(Arrays.orderUsers);
  static String _ordemCurrent = Arrays.orderUsers[0];//0 = Ranking
  static bool _ordemAsc = false;

  final Map<String, Pagamento> _filiadosAtivos = Map();
  final bool isFiliadosList;

  bool inProgress = false;

  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _eu = FirebasePro.userPro;
    if(data == null) {
      data = new List<UserPro>();
      data.addAll(getTipster.data);
      _changeOrdem(_ordemCurrent, _ordemAsc);
    }
    if (isFiliadosList)
      _saveQuantAtivos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var headerTextStyle = TextStyle(fontSize: 14);

    return Scaffold(
      appBar: mostrarAppBar ? AppBar(
        elevation: 0,
        title: Row(children: [
          Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(MyTexts.ORDEM_POR, style: headerTextStyle),
            ),
          Expanded(child: DropdownButton(
            value: _ordemCurrent,
            items: _ordemData,
            style: headerTextStyle,
            dropdownColor: MyTheme.primary,
            onChanged: (value) {_changeOrdem(value, _ordemAsc);},
          )),
          Container(
              width: 50,
              child: CheckboxListTile(
                value: _ordemAsc,
                contentPadding: EdgeInsets.zero,

                onChanged: (bool value) {_changeOrdem(_ordemCurrent, value);},
            )
          ),
          GestureDetector(
            child: Text('DSC', style: headerTextStyle),
            onTap: () {
              _ordemAsc = !_ordemAsc;
              _changeOrdem(_ordemCurrent, _ordemAsc);
            }
          ),
          ]),
      ) : null,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(children: [
          isFiliadosList ?
          itemLayoutFiliado :
          itemLayoutTipster
        ]),
      ),
      floatingActionButton: inProgress ? CircularProgressIndicator() : null,
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

  Widget get itemLayoutTipster {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          data[index].isExpanded = !isExpanded;
        });
      },
      children: data.map<ExpansionPanel>((UserPro item) {
        String subTitleText = 'Green: ${item.bomCount} | Red: ${item.ruimCount} | Posts: ${item.postes.length}';

        return ExpansionPanel(
            canTapOnHeader: true,
            isExpanded: item.isExpanded,
            headerBuilder: (BuildContext context, bool isExpanded) => Layouts.userTile(item),
            body: OpenContainerWrapper(
              statefulWidget: PerfilTipsterPage(item),
              child: ListTile(
                title: Text('Visitar Perfil'),
                subtitle: Text(subTitleText),
              ),
              onClosed: (value) => setState(() {}),
            )
        );
      }).toList(),
    );
  }

  Widget get itemLayoutFiliado {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          data[index].isExpanded = !isExpanded;
        });
      },
      children: data.map<ExpansionPanel>((UserPro item) {
        String mensalidadeValue = _eu.filiados[item.dados.id] ?? '';
        if (mensalidadeValue == UserTag.PRECO_PADRAO) {
          mensalidadeValue = '${_eu.dados.precoPadrao} (Padrão)';
        }

        if (!_filiadosAtivos.containsKey(item.dados.id)) {
          void dd() async {
            _filiadosAtivos[item.dados.id] = null;
            var result = await item.pagamento(_eu.dados.id, DataHora.onlyDate);
            setState(() {
              if (result != null && result.isNotEmpty)
              _filiadosAtivos[item.dados.id] = criarPagamento(item, result);
              else
              _filiadosAtivos[item.dados.id] = criarPagamento(item, '');
            });
          }
          dd();
        }
        bool pagamentoOK;
        if (_filiadosAtivos[item.dados.id] != null)
          pagamentoOK = _filiadosAtivos[item.dados.id].valor.isNotEmpty;

        if (_filiadosAtivos.length == _eu.filiados.length)
          _setInProgress(false);

        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: Layouts.clipRRectFormatUser(
                  radius: 50,
                  child: Layouts.fotoUser(item.dados)
              ),
              title: Text(item.dados.nome),
              subtitle: Text(mensalidadeValue),
              trailing: pagamentoOK == null ? null : Icon(
                pagamentoOK ? Icons.offline_pin : Icons.clear,
                color: pagamentoOK ? Colors.green : Colors.red,
              ),
              onTap: () {
                setState(() {
                  item.isExpanded = !item.isExpanded;
                });
              },
            );
          },
          isExpanded: item.isExpanded,
            body: OpenContainerWrapper(
              statefulWidget: PerfilFiliadoPage(item),
              child: ListTile(
                title: Text('Visitar ' + item.dados.tipname),
                subtitle: Row(
                  children: [
                    if (pagamentoOK != null && pagamentoOK)...[
                      Text('Pagamento OK\t'),
                      FlatButton(
                        color: Colors.red,
                        child: Text('Remover', style: TextStyle(color: Colors.white)),
                        onPressed: () => _popupRemoverAtivo(item),
                      )
                    ]
                    else if (pagamentoOK != null)...[
                      ElevatedButton(
                        child: Text('Confirmar o pagamento'),
                        onPressed: () => _popupAddAtivo(item),
                      )
                    ]
                  ],
                ),
              ),
              onClosed: (value) => setState(() {}),
            )
        );
      }).toList(),
    );
  }

  Future<void> _onRefresh() async {
    await UserPro.baixarList();
    data.clear();
    setState(() {
      if (isFiliadosList) {
        String meuId = FirebasePro.user.uid;
        data.addAll(getUsers.data.values.where((e) => e.tipsters.containsKey(meuId)));
        data.sort((a, b) => a.dados.nome.toLowerCase().compareTo(b.dados.nome.toLowerCase()));
        Log.d(TAG, '_onRefresh', data.length);
      } else {
        data.addAll(getTipster.data);
        _changeOrdem(_ordemCurrent, _ordemAsc);
      }
    });
  }

  _popupAddAtivo(UserPro item) async {
    var valor = _eu.filiados[item.dados.id];
    if (valor == MyStrings.DEFAULT)
      valor = _eu.dados.precoPadrao;

    var title = item.dados.nome;
    var controller = TextEditingController();
    controller.text = 'R\$ $valor';
    var content = [
      Text('Confirmar o pagamento deste Filiado?'),
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          TextInputFormatterMoney.instance
        ],
        decoration: InputDecoration(labelText: 'Valor'),
      )
    ];
    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
    if (result.isPositive) {
      _setInProgress(true);
      var charSpecial = ' ';// criado por esse negócio => [TextInputFormatterMoney]
      valor = controller.text.trim().replaceAll('R\$', '').replaceAll(charSpecial, '');
      Pagamento p = criarPagamento(item, valor.toString());
      await p.salvar();
      _setInProgress(false);
      setState(() {
        _filiadosAtivos[item.dados.id] = p;
      });
    }
  }

  _popupRemoverAtivo(UserPro item) async {
    Pagamento p = _filiadosAtivos[item.dados.id];
    if (p != null) {
      var title = item.dados.nome;
      var content = [
            Text('Remover este Filiado da lista de ativos?'),
            IconButton(
              icon: Icon(Icons.info, color: MyTheme.primary),
              padding: EdgeInsets.zero,
              onPressed: _popupInfoAtivos,
            )
      ];
      var result = await DialogBox.dialogCancelOK(context, title: title, content: content);
      if (result.isPositive) {
        _setInProgress(true);
        await p.delete();
        _setInProgress(false);
        setState(() {
          _filiadosAtivos.remove(item.dados.id);
        });
      }
    }
  }

  _popupInfoAtivos() {
    var content = Text('Ativos são seus Filiados que realizaram o pagamento no último mês');
    DialogBox.dialogOK(context, title: 'Info', content: [content]);
  }

  _saveQuantAtivos() async {
    _setInProgress(true);
    await FirebasePro.database
        .child(FirebaseChild.PAGAMENTOS)
        .child(_eu.dados.id)
        .child(DataHora.onlyDate)
        .child(FirebaseChild.ATIVOS)
        .set(_eu.filiados.length);
    _setInProgress(false);
  }

  Pagamento criarPagamento(UserPro user, String valor) => Pagamento(
      userOrigem: user,
      userDestino: _eu,
      data: DataHora.onlyDate,
      valor: valor
  );

  _setInProgress(bool b) {
    if(mounted)
      setState(() {
        inProgress = b;
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