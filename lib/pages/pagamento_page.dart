import 'package:flutter/material.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/pagamento.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/resources.dart';
// import 'package:flutter_google_pay/flutter_google_pay.dart';
import 'package:protips/res/strings.dart';
// import 'package:stripe_payment/stripe_payment.dart';

class PagamentoPage extends StatefulWidget {
  final UserPro valor;
  PagamentoPage(this.valor);
  @override
  State<StatefulWidget> createState() => MyWidgetState(valor);// MyWidgetState(valor);
}
class MyWidgetState extends State<PagamentoPage> {
  static const String TAG = 'PagamentoPage';

  MyWidgetState(this._user);

  //region Variaveis

  final UserPro _user;

  String _log = '';

  bool _isAvailable = false;
  bool _comraResultOK = false;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _checkGooglePay();
    // StripePayment.setOptions(
    //     StripeOptions(
    //         publishableKey: MyResources.stripeKey,
    //         merchantId: MyResources.merchantID
    //     )
    // );
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
            Layouts.userTile(_user),

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
                    child: Image.asset(Assets.googlePayButtonDark),
                    onTap: _makeStripePayment,
                  ),
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
    // bool release = Aplication.isRelease;
    // var environment = release ? 'production' : 'rest';
    // if (await FlutterGooglePay.isAvailable(environment)) {
    //   setState(() {
    //     _isAvailable = true;
    //   });
    // } else {
    //   _setLogError('Google Pay não disponível');
    // }
  }

  _makeStripePayment() async {
    _setLogError();

    try {
      // PaymentItem pm = PaymentItem(
      //     stripeToken: MyResources.stripeKey,
      //     stripeVersion: "2018-11-08",
      //     currencyCode: "brl",
      //     amount: valor.replaceAll(',', '.'),
      //     gateway: 'stripe');
      //
      // Result result = await FlutterGooglePay.makePayment(pm);
      //
      // if (result.status == ResultStatus.SUCCESS) {
      //   var json = result.data;
      //   var jCard = json['card'];
      //
      //   CreditCard card = CreditCard(
      //     addressCity: jCard['address_city'],
      //     addressCountry: jCard['address_country'],
      //     addressLine1: jCard['address_line1'],
      //     addressLine2: jCard['address_line2'],
      //     addressState: jCard['address_state'],
      //     addressZip: jCard['address_zip'],
      //     brand: jCard['brand'],
      //     cardId: jCard['id'],
      //     currency: jCard['currency'],
      //     country: jCard['country'],
      //     expMonth: jCard['exp_month'],
      //     expYear: jCard['exp_year'],
      //     funding: jCard['funding'],
      //     last4: jCard['last4'],
      //     name: jCard['name'],
      //     cvc: jCard['cvc_check'],
      //     number: jCard['number'],//TODO precisa dessa bosta
      //     token: json['id'],
      //   );
      //   var created = json['created'];
      //   Token token = Token(
      //     tokenId: json['id'],
      //     card: card,
      //     created: created is int ? created.toDouble() : created,
      //     livemode: json['livemode'],
      //   );
      //
      //   try {
      //     await StripePayment.createPaymentMethod(
      //         PaymentMethodRequest(
      //           token: token,
      //           card: token.card,
      //         )
      //     );
      //     _onSucesso();
      //   } catch(e) {
      //     _setLogError(MyErros.PAGAMENTO);
      //     Log.e(TAG, 'makeStripePayment', 2, e);
      //   }
      //
      // } else if (result.error != null) {
      //   _setLogError(MyErros.PAGAMENTO);
      //   Log.e(TAG, 'makeStripePayment', 1, result.error);
      // }
    } catch(e) {
      _setLogError(MyErros.PAGAMENTO);
      Log.e(TAG, 'makeStripePayment', 0, e);
    }
  }

  _onSucesso() async {
      Pagamento p = Pagamento(
          userOrigem: FirebasePro.userPro,
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
    String valor = _user.filiados[FirebasePro.user.uid] ?? '';
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
