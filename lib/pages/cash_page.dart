import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:protips/auxiliar/config.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/pagamento.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/pages/users_page.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/strings.dart';

class CashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<CashPage> {

  //region Variaveis
  static const String TAG = 'CashPage';
  static const ATIVOS = FirebaseChild.ATIVOS;

  String _currentData = DataHora.onlyDate;
  bool _inProgress = false;
  double _total = 0.0;
  DateTime _dateTime;
  UserPro _user = FirebasePro.userPro;
  List<UserPro> _data = [];

  Map<dynamic, dynamic> _pagamentosMap = Map();
  String currentAtivos = '0';
  //endregion

  //region override

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    _loadPagamentos();
  }

  @override
  Widget build(BuildContext context) {
    var titleText = TextStyle(
      fontSize: 20,
      // color: MyTheme.textSubtitleColor,
      fontWeight: FontWeight.bold,
    );
    var tableTextStyle = TextStyle(
      fontSize: 18,
      // color: MyTheme.textSubtitleColor,
    );

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(Titles.CASH)),
        actions: [
          if (RunTime.semInternet)
            Layouts.icAlertInternet,
          IconButton(
            tooltip: 'Filiados',
            icon: Icon(Icons.group),
            onPressed: _onMenuFiliados,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              color: Colors.black12,
              child: Text(_dateMesName.toUpperCase(),
                textAlign: TextAlign.center,
                style: titleText,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Receita Total'.toUpperCase(), style: tableTextStyle),
                      Text('Disponível Para Saque'.toUpperCase(), style: tableTextStyle),
                      Text('Taxa de Administração'.toUpperCase(), style: tableTextStyle),
                      Text('Filiados Ativos'.toUpperCase(), style: tableTextStyle),
                      Text('Inscritos'.toUpperCase(), style: tableTextStyle),
                    ],
                  )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('R\$ ${_total.toStringAsFixed(2)}', style: tableTextStyle),
                      Text('R\$ ${(_total /** 0.9*/).toStringAsFixed(2)}', style: tableTextStyle),
                      Text('R\$ ${(_total * 0/*.1*/).toStringAsFixed(2)}', style: tableTextStyle),
                      Text(_data.length.toString(), style: tableTextStyle),
                      Text(currentAtivos, style: tableTextStyle),
                    ],
                  )
                ],
              ),
            ),
            
            /*DataTable(
              headingRowHeight: 20,
              dataRowHeight: 25,
              columns: [
                DataColumn(label: Text('Data: $_currentData', style: tableTextStyle)),
                DataColumn(label: Text('VALOR', style: tableTextStyle)),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Total', style: tableTextStyle)),
                  DataCell(Text('R\$ ${_total.toStringAsFixed(2)}', style: tableTextStyle)),
                ]),
                DataRow(cells: [
                  DataCell(Text('SubTotal:', style: tableTextStyle)),
                  DataCell(Text('R\$ ${(_total * 0.9).toStringAsFixed(2)}', style: tableTextStyle)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Retenção:', style: tableTextStyle)),
                  DataCell(Text('R\$ ${(_total * 0.1).toStringAsFixed(2)}', style: tableTextStyle)),
                ]),
              ],
            ),*/
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              color: Colors.black12,
              child:  Text('Filiados Ativos'.toUpperCase(),
                textAlign: TextAlign.center,
                style: titleText,
              ),
            ),
            for (UserPro user in _data)...[
              ListTile(
                leading: Layouts.clipRRectFormatUser(child: Layouts.fotoUser(user.dados), radius: 70),
                title: Text(user.dados.nome),
                subtitle: Text('R\$: ${_pagamentoValue(user).toStringAsFixed(2)}'),
              )
            ]
          ],
        ),
      ),
      floatingActionButton: (_inProgress) ? CircularProgressIndicator():
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
          onPressed: _onFloatingAtionPressed),
    );
  }

  //endregion

  //region Metodos

  Map get _currentMap => _pagamentosMap[_currentData] ?? Map();

  double _pagamentoValue(UserPro user) {
    if (user == null || _currentMap[user.dados.id] == null)
      return 0.0;
    return double.parse(_currentMap[user.dados.id].toString().replaceAll(',', '.') ?? '0');
  }

  String get _dateMesName {
    final DateFormat formatter = DateFormat(/*'MMMM', 'pt'*/);
    return formatter.format(_dateTime);
  }

  _onFloatingAtionPressed() async {
    var lastDate = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        helpText: 'Selecione qualquer dia em um Mês',
        confirmText: 'Este Mês',
        // locale: Aplication.locale,
        initialDate: _dateTime,
        firstDate: DateTime(2020),
        lastDate: DateTime(lastDate.year, lastDate.month, lastDate.day)
    );
    if (picked != null) {
      _dateTime = picked;
      String mes = _dateTime.month.toString();
      if(mes.length == 1) mes = '0$mes';
      _currentData = '${_dateTime.year}-$mes';
      _somarPagamentos();
      _loadUsers();
      setState(() {});
    }
  }

  _onMenuFiliados() async {
    await Navigate.to(context, UsersPage());
    _setInProgress(true);
    await _loadPagamentos();
    _setInProgress(false);
  }

  _loadPagamentos() async {
    _setInProgress(true);
    var result = await Pagamento.loadAll(_user.dados.id);

    if(!mounted) return;
    setState(() {
      _pagamentosMap = result;
    });
    _somarPagamentos();
    await _loadUsers();
    _setInProgress(false);
  }

  _loadUsers() async {
    var list = List<UserPro>();
    for (var key in _currentMap.keys) {
      if (key == ATIVOS) continue;

      var user = await getUsers.get(key);
      if (user != null)
      list.add(user);
    }
    _data.clear();

    if(!mounted) return;
    setState(() {
      _data.addAll(list);
    });
  }

  _somarPagamentos() {
    var total = 0.0;
    currentAtivos = _currentMap[ATIVOS]?.toString() ?? '-';
    for (var value in _currentMap.values) {
      if (value is String)
        total += double.parse(value.toString().replaceAll(',', '.'));
    }
    setState(() {
      _total = total;
    });
  }

  _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion
}
