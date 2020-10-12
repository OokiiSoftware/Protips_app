import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PagamentoTestPage extends StatefulWidget {
  final double valor;
  PagamentoTestPage(this.valor);
  @override
  State<StatefulWidget> createState() => MyWidgetState();// MyWidgetState(valor);
}
class MyWidgetState extends State<PagamentoTestPage> {
  static const String TAG = 'PagamentoTestPage';

  //region variaveis

  //endregion

  //region overrides

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text('Pagamento Testes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text('VALOR: R\$ 5,00'),
          Divider(),
        ],
      ),
    );
  }

  //endregion

  //region metodos

  //endregion

}
