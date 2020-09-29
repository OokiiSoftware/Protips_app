import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user.dart';
import 'package:protips/pages/denuncia_page.dart';
import 'package:protips/pages/perfil_tipster_page.dart';
import 'package:protips/res/resources.dart';

// ignore: must_be_immutable
class FragmentInicio extends StatefulWidget {
  User user;
  FragmentInicio({this.user});
  @override
  State<StatefulWidget> createState() => MyWidgetState(user: user);
}
class MyWidgetState extends State<FragmentInicio> with AutomaticKeepAliveClientMixin<FragmentInicio> {

  MyWidgetState({this.user});

  //region Variaveis
  static const String TAG = 'FragmentInicio';

  User user;
  List<Post> data;
  bool canOpenPerfil = false;

  bool _inProgress = false;
//  double progressBarValue = 0;
//  CircularProgressIndicator progressBar;

  DateTime _dateTime;

  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    data = List<Post>();
    canOpenPerfil = user == null;
    _preencherLista();
//    progressBar = CircularProgressIndicator(value: progressBarValue);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
            itemCount: data.length,
            padding: EdgeInsets.only(bottom: 70),
            itemBuilder: (BuildContext context, int index) {
              final item = data[index];
              return itemLayout(item);
            }
        ),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() :
      user == null ?
      FloatingActionButton.extended(
          label: Stack(
              alignment: Alignment.center,
            children: [
              Icon(Icons.calendar_today),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(_dateTime.day.toString()),
              )
            ],
          ),
          onPressed: _onFloatingAtionPressed
      ) : null,
    );
  }

  //endregion

  //region Metodos

  Widget itemLayout(Post item) {
    //region Variaveis
    User user = getTipster.get(item.idTipster);
    String meuId = getFirebase.fUser.uid;
    bool isMyPost = item.idTipster == meuId;

    var divider = Divider(color: MyTheme.textColorInvert(), height: 1, thickness: 1);

    double fotoUserSize = 40;

    bool moreGreens = item.bom.length > item.ruim.length;
    bool moreReds = item.ruim.length > item.bom.length;

    //endregion

    return Container(
        alignment: Alignment.center,
        child: Column(children: [
          //header
          GestureDetector(
            child: Container(
              color: moreGreens ? Colors.green[200] : (moreReds ? Colors.red[200] : MyTheme.tintColor2()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Foto
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: item == null ?
                      Image.asset(MyAssets.ic_person, color: Colors.black) :
                      ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyLayouts.fotoUser(user.dados, iconSize: fotoUserSize)
                      )
                  ),
                  //Dados
                  Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.dados?.nome ?? '',
                          style: TextStyle(fontSize: 17)),
                      Text(item?.data)
                    ],
                  )),
                  //Menu
                  PopupMenuButton<String>(
                      onSelected: (String result) {
                        _onMenuItemPostCliked(result, item);
                      },
                      itemBuilder: (BuildContext context) {
                        var list = List<String>();
                        list.addAll(MyMenus.post);
                        if (isMyPost)
                          list.remove(MyMenus.DENUNCIAR);
                        else
                          list.remove(MyMenus.EXCLUIR);
                        if (item.link.isEmpty)
                          list.remove(MyMenus.ABRIR_LINK);

                        return list.map((item) =>
                            PopupMenuItem<String>(value: item,
                                child: Text(item))).toList();
                      }
                  ),
                ],
              ),
            ),
            onTap: () {
              if (canOpenPerfil)
                Navigate.to(context, PerfilTipsterPage(user));
            },
          ),
          Divider(
            color: MyTheme.accent(),
            height: 3,
            thickness: 3,
          ),
          //Titulo
          Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.all(7),
            child: Text(item?.titulo, style: TextStyle(fontSize: 17)),
          ),
          //Foto
          Container(
              child: MyLayouts.fotoPost(item)
          ),
          divider,
          //descricao
          if (item.descricao.isNotEmpty) Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
            child: Text(item.descricao),
          ),
          //Dados
          DataTable(
              headingRowHeight: 20,
              dataRowHeight: 20,
              columns: [
                DataColumn(label: Text(MyStrings.ESPORTE.toUpperCase() + ': ' + item.esporte)),
                DataColumn(label: Text(MyStrings.LINHA.toUpperCase() + ': ' + item.linha)),
              ], rows: [
            DataRow(cells: [
              DataCell(Text(
                  MyStrings.ODD_ATUAL.toUpperCase() + ': ' + item.oddAtual)),
              DataCell(
                  Text(MyStrings.UNIDADES.toUpperCase() + ': ' + item.unidade)),
            ]),
          ]),
          if (item.oddMinima.isNotEmpty || item.oddMaxima.isNotEmpty ||
              item.horarioMinimo.isNotEmpty || item.horarioMaximo.isNotEmpty)
            DataTable(
                headingRowHeight: 20,
                dataRowHeight: 20,
                columns: [
                  DataColumn(label: Text('')),
                  DataColumn(label: Text(MyStrings.MINIMO.toUpperCase())),
                  DataColumn(label: Text(MyStrings.MAXIMO.toUpperCase())),
                ], rows: [
              if (item.oddMinima.isNotEmpty || item.oddMaxima.isNotEmpty)
                DataRow(cells: [
                  DataCell(Text(MyStrings.ODD.toUpperCase())),
                  DataCell(Text(item.oddMinima)),
                  DataCell(Text(item.oddMaxima)),
                ]),
              if (item.horarioMinimo.isNotEmpty ||
                  item.horarioMaximo.isNotEmpty)
                DataRow(cells: [
                  DataCell(Text(MyStrings.HORARIO.toUpperCase())),
                  DataCell(Text(item.horarioMinimo)),
                  DataCell(Text(item.horarioMaximo)),
                ]),
            ]),
          //Green | Red Buttons
          if (isMyPost)
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('\tEste Tip teve: '),
                  Tooltip(message: 'Green', child: FlatButton(
                    child: Image.asset(MyAssets.ic_positivo, width: 30),
                    color: item.bom.containsKey(meuId) ? Colors.black12 : Colors.white,
                    onPressed: () async {
                      _setInProgress(true);
                      if (item.bom.containsKey(meuId))
                        await item.removeBom(meuId);
                      else
                        await item.addBom(meuId);
                      _setInProgress(false);
                      setState(() {});
                    },
                  )),
                  Tooltip(message: 'Red', child: FlatButton(
                    child: Image.asset(MyAssets.ic_negativo, width: 30),
                    color: item.ruim.containsKey(meuId)
                        ? Colors.black12 : Colors.white,
                    onPressed: () async {
                      _setInProgress(true);
                      if (item.ruim.containsKey(meuId))
                        await item.removeRuim(meuId);
                      else
                        await item.addRuim(meuId);
                      _setInProgress(false);
                      setState(() {});
                    },
                  )),
                ]),
//        Column(
//            children: [
          //categoria
//              Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                crossAxisAlignment: CrossAxisAlignment.end,
//                children: [
//                  Text(MyStrings.ESPORTE +': '),
//                  Text(item.esporte),
//                  Text('  |  '),
//                  Text(MyStrings.LINHA +': '),
//                  Text(item.linha),
//                ],
//              ),
//              //ODD Atual
//              Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: [
//                  Text(MyStrings.ODD_ATUAL +': '),
//                  Text(item.oddAtual),
//                  Text('  |  '),
//                  Text(MyStrings.UNIDADES +': '),
//                  Text(item.unidade),
//                ],
//              ),
//              divider,
          //Minimos e maximos
//              Row(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: [
//                  Text(''),
//                  Text(MyStrings.MINIMO),
//                  Text(MyStrings.MAXIMO),
//                ],
//              ),
          //Odd
//              if (item.oddMinima.isNotEmpty || item.oddMaxima.isNotEmpty) Row(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: [
//                  Text(MyStrings.ODD),
//                  Text(item.oddMinima),
//                  Text(item.oddMaxima),
//                ],
//              ),
          //Horarios
//              if (item.horarioMinimo.isNotEmpty || item.horarioMaximo.isNotEmpty) Row(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: [
//                  Text(MyStrings.HORARIO),
//                  Text(item.horarioMinimo),
//                  Text(item.horarioMaximo),
//                ],
//              ),
//              divider,
//            ],
//          )
        ])
    );
  }

  Future<void> _onRefresh() async {
    await getUsers.baixar();
    _preencherLista();
    setState(() {});
  }

  _onMenuItemPostCliked(String value, Post post) {
    switch(value) {
      case MyMenus.ABRIR_LINK:
        Import.openUrl(post.link, context);
        break;
      case MyMenus.EXCLUIR:
        _onDelete(post);
        break;
      case MyMenus.DENUNCIAR:
        Navigate.to(context, DenunciaPage.Post(post));
        break;
    }
  }

  _onFloatingAtionPressed() async {
    var lastDate = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: DateTime(1950),
        lastDate: DateTime(lastDate.year, lastDate.month, lastDate.day)
    );
    if (picked != null) {
      _dateTime = picked;
      _preencherLista();
      setState(() {});
    }
  }

  _onDelete(Post item) async {
    _setInProgress(false);
    String titulo = MyStrings.EXCLUIR;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(MyTexts.EXCLUIR_POST_PERMANENTE),
        actions: [
          FlatButton(
            child: Text(MyStrings.CANCELAR),
            onPressed: () {Navigator.pop(context);},
          ),
          FlatButton(
            child: Text(MyStrings.SIM),
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                titulo = MyStrings.EXCLUIR;
                _setInProgress(true);
              });
              if (await item.excluir()) {
                setState(() {
                  data.removeWhere((e) => e.id == item.id);
                });
                getPosts.remove(item.id);
              } else {
                setState(() {
                  titulo = MyStrings.EXCLUIR + ': ' + MyErros.ERRO_GENERICO;
                  _setInProgress(false);
                });
              }
              },
          ),
        ],
      )
    );
  }

  _setInProgress(bool b) {
    setState(() {
      _inProgress = b;
    });
  }

  _preencherLista() async {
    data.clear();
    List<Post> list = [];
    _setInProgress(true);
    if (user == null) {
      if (_dateTime == null) _dateTime = DateTime.now();

      String data = _dateTime.toString();
      data = data.substring(0, data.indexOf(' '));
      list.addAll(await getPosts.data(data));
    }
    else {
      String meuId = getFirebase.fUser.uid;
      if (user.seguidores.containsKey(meuId)) {
        String dataPagamentoTemp = '';
        bool inserir = false;
        for (var item in user.postes.values) {
          String data = item.data.substring(0, item.data.indexOf(' ')-3);
          if (dataPagamentoTemp != data) {
            var pagamento = await getPosts.loadPagamento(user.dados.id, data);
            inserir = pagamento != null;
          }
          if (inserir)
            list.add(item);
        }
      }
      else if (getFirebase.isAdmin || user.dados.id == meuId) {
        list.addAll(user.postes.values);
      }
      else
        list.addAll(user.postes.values.where((e) => e.isPublico).toList());
    }
    setState(() {
      data.addAll(list..sort((a, b) => b.data.compareTo(a.data)));
    });
    _setInProgress(false);
  }

  //endregion
}