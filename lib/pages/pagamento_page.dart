import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/pagamento.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/resources.dart';
import 'package:flutter_google_pay/flutter_google_pay.dart';
import 'package:protips/res/strings.dart';

class PagamentoPage extends StatefulWidget {
  final User valor;
  PagamentoPage(this.valor);
  @override
  State<StatefulWidget> createState() => MyWidgetState(valor);// MyWidgetState(valor);
}
class MyWidgetState extends State<PagamentoPage> {
  static const String TAG = 'PagamentoPage';

  MyWidgetState(this._user);

  //region Variaveis

  final User _user;

  String _log = '';

  bool _isAvailable = false;
  bool _comraResultOK = false;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _checkGooglePay();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _comraResultOK);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(Titles.PAGAMENTO)),
        body: Column(
          children: [
            MyLayouts.userTile(_user),

            if (_comraResultOK)
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                    Text('Sucesso.', style: TextStyle(fontSize: 15)),
                    Text('Pagamento realizado com o Google Pay.',
                        style: TextStyle(fontSize: 15)),
                  ],
                ),
              )
            else...[
              Container(
                color: Colors.black12,
                padding: EdgeInsets.all(20),
                child: Text('Realizar pagamento da mensalidade deste Tipster no valor de R\$ $valor.',
                    style: TextStyle(fontSize: 15)),
              ),
              if (_isAvailable)... [
                Divider(),
                Container(
                  height: 45,
                  width: 188,
                  child: GestureDetector(
                    child: Image.asset(MyAssets.googlePayButtonDark),
                    onTap: _makeStripePayment,
                  ),
                ),

                if(Firebase.isAdmin)
                  ElevatedButton(
                    child: Text('Google Pay [ADMIN TESTE]'),
                    onPressed: _makeCustomPayment,
                  ),
              ],
            ],

            if (_log.isNotEmpty)
              Text(_log, style: TextStyle(color: ThemeData.light().errorColor))
          ],
        ),
      ),
    );
  }

  //endregion

  //region Metodos

  _checkGooglePay() async {
    bool release = Aplication.isRelease;
    var environment = release ? 'production' : 'rest';
    if (await FlutterGooglePay.isAvailable(environment)) {
      setState(() {
        _isAvailable = true;
      });
    } else {
      _setLogError('Google Pay não disponível');
    }
  }

  _makeStripePayment() async {
    _setLogError();

    PaymentItem pm = PaymentItem(
        stripeToken: MyResources.stripeID,
        stripeVersion: "2020-03-02",
        currencyCode: "brl",
        amount: valor.replaceAll(',', '.'),
        gateway: 'stripe');

    FlutterGooglePay.makePayment(pm).then((Result result) {
      if (result.status == ResultStatus.SUCCESS) {
        _onSucesso();
      } else if (result.error != null) {
        _setLogError(result.error);
        Log.e(TAG, '_makeStripePayment', result.error, 1);
      }
    }).catchError((e) {
      _setLogError(e.toString());
      Log.e(TAG, '_makeStripePayment', e, 0);
    });
  }

  _makeCustomPayment() async {
    ///docs https://developers.google.com/pay/api/android/guides/tutorial
    PaymentBuilder pb = PaymentBuilder()
      ..addGateway("stripe")
      ..addTransactionInfo(valor, "BRL")
      ..addAllowedCardAuthMethods(["PAN_ONLY", "CRYPTOGRAM_3DS"])
      ..addAllowedCardNetworks(["AMEX", "DISCOVER", "JCB", "MASTERCARD", "VISA"])
      ..addBillingAddressRequired(true)
      ..addPhoneNumberRequired(true)
      ..addShippingAddressRequired(true)
      ..addShippingSupportedCountries(["BR"])
      ..addMerchantInfo(MyResources.merchantID);

    FlutterGooglePay.makeCustomPayment(pb.build()).then((Result result) {
      if (result.status == ResultStatus.SUCCESS) {
        _onSucesso();
      } else if (result.error != null) {
        _setLogError(result.error);
        Log.e(TAG, '_makeCustomPayment', result.error, 1);
      }
    }).catchError((e) {
      _setLogError('Desculpe. Ocorreu um erro.');
      Log.e(TAG, '_makeCustomPayment', e, 0);
    });
  }

  _onSucesso() async {
      Pagamento p = Pagamento(
          userOrigem: Firebase.user,
          userDestino: _user,
        data: DataHora.onlyDate,
        valor: valor
      );

      while (true) {
        if (await p.salvar())
          break;
      }

      setState(() {
        _comraResultOK = true;
        _isAvailable = false;
      });
      // Navigator.pop(context, _comraResultOK);
  }

  String get valor {
    String valor = _user.seguidores[Firebase.fUser.uid] ?? '';
    if (valor.isEmpty || valor == MyStrings.DEFAULT) valor = _user.dados.precoPadrao;
    return valor;
  }

  void _setLogError([String value = '']) {
    setState(() {
      _log = value;
    });
  }

  //endregion

}
