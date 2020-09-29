import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/pagamento.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/resources.dart';

class CashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<CashPage> {

  static const String TAG = 'CashPage';

  //region Variaveis
  bool _inProgress = false;
  double _total = 0.0;
  DateTime _dateTime;
  String _currentData = '';
  User _user = getFirebase.user;
  List<User> _data = [];

  Map<dynamic, dynamic> _pagamentosMap = Map();
  //endregion

  //region override

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    _currentData = DataHora.onlyDate;
    _loadPagamentos();
  }

  @override
  Widget build(BuildContext context) {
    var tableTextStyle = TextStyle(fontSize: 16);
    return Scaffold(
      appBar: AppBar(title: Text(Titles.CASH)),
      body: SingleChildScrollView(
        // padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              color: Colors.black12,
              child:  Text('Mês de $_dateMesName',
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center,
              ),
            ),
            Center(child: DataTable(
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
            )),
            Divider(),
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              color: Colors.black12,
              child:  Text('Filiados que realizaram o pagamento no mês de $_dateMesName',
                style: TextStyle(fontSize: 16), textAlign: TextAlign.center,
              ),
            ),
            for (User user in _data)...[
              ListTile(
                leading: MyLayouts.iconFormatUser(child: MyLayouts.fotoUser(user.dados), radius: 70),
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
      ), onPressed: _onFloatingAtionPressed),
    );
  }

  //endregion

  //region Metodos

  Map get _currentMap => _pagamentosMap[_currentData] ?? Map();

  double _pagamentoValue(User user) {
    return double.parse(_currentMap[user.dados.id] ?? '0');
  }

  String get _dateMesName {
    final DateFormat formatter = DateFormat('MMMM');
    return formatter.format(_dateTime);
  }

  _onFloatingAtionPressed() async {
    var lastDate = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
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

  _loadPagamentos() async {
    _setInProgress(true);
    var result = await Pagamento.loadAll(_user.dados.id);
    setState(() {
      _pagamentosMap = result;
    });
    _somarPagamentos();
    await _loadUsers();
    _setInProgress(false);
  }

  _loadUsers() async {
    var list = List<User>();
    for (var key in _currentMap.keys) {
      list.add(await getUsers.get(key));
    }
    _data.clear();
    setState(() {
      _data.addAll(list);
    });
  }

  _somarPagamentos() {
    var total = 0.0;
    for (var value in _currentMap.values) {
      total += double.parse(value.toString().replaceAll(',', '.'));
    }
    setState(() {
      _total = total;
    });
  }

  _setInProgress(bool b) {
    setState(() {
      _inProgress = b;
    });
  }

  //endregion
}
