import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_google_pay/flutter_google_pay.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/res/strings.dart';
// import 'package:stripe_payment/stripe_payment.dart';

class PagamentoTestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();// MyWidgetState(valor);
}
class MyWidgetState extends State<PagamentoTestPage> {
  static const String TAG = 'PagamentoTestPage';

  //region Variaveis

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
        appBar: AppBar(title: Text('${Titles.PAGAMENTO} TESTES')),
        body: Column(
          children: [
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

                if(FirebasePro.isAdmin)
                  ElevatedButton(
                    child: Text('Google Pay [ADMIN TESTE]'),
                    onPressed: _makeCustomPayment,
                  ),
              ],
            ],

            if (_log.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(_log, style: TextStyle(color: ThemeData.light().errorColor)),
              )
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
      //   // var jCard = json['card'];
      //
      //   // CreditCard card = CreditCard(
      //   //     addressCity: jCard['address_city'],
      //   //     addressCountry: jCard['address_country'],
      //   //     addressLine1: jCard['address_line1'],
      //   //     addressLine2: jCard['address_line2'],
      //   //     addressState: jCard['address_state'],
      //   //     addressZip: jCard['address_zip'],
      //   //     brand: jCard['brand'],
      //   //     cardId: jCard['id'],
      //   //     currency: jCard['currency'],
      //   //     country: jCard['country'],
      //   //     expMonth: jCard['exp_month'],
      //   //     expYear: jCard['exp_year'],
      //   //     funding: jCard['funding'],
      //   //     last4: jCard['last4'],
      //   //     name: jCard['name'],
      //   //     cvc: jCard['cvc_check'],
      //   //     number: jCard['number'],//TODO precisa dessa bosta
      //   //     token: json['id'],
      //   // );
      //   // var created = json['created'];
      //   // Token token = Token(
      //   //     tokenId: json['id'],
      //   //     card: card,
      //   //     created: created is int ? created.toDouble() : created,
      //   //     livemode: json['livemode'],
      //   // );
      //
      //   try {
      //     PaymentMethod paymentMethod = await StripePayment.createPaymentMethod(
      //         PaymentMethodRequest(
      //           // token: token,
      //           card: CreditCard(token: json['id']),
      //         )
      //     );
      //
      //     Log.d(TAG, 'makeStripePayment', 'ON');
      //     PaymentIntentResult intentResult = await StripePayment.confirmPaymentIntent(
      //       PaymentIntent(
      //         clientSecret: '',
      //         paymentMethodId: paymentMethod.id,
      //       )
      //     );
      //
      //     _setLogError('Received ${intentResult.paymentMethodId}');
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

  _makeCustomPayment() async {
    try {

    } catch(e) {
      Log.e(TAG, 'makeCustomPayment', 0, e);
    }
  }


  _onSucesso() async {
    setState(() {
      _comraResultOK = true;
      _isAvailable = false;
    });
  }

  String get valor => '1.00';

  void _setLogError([String value = '']) {
    setState(() {
      _log = value;
    });
  }

  //endregion

}
