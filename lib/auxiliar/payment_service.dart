import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/pagamento.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/resources.dart';

class PaymentService {
  static const String TAG = 'PaymentService';

  static final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;

  static Future<bool> novoPagamento(User user) async {

    ProductDetailsResponse productDetailResponse =
    await _connection.queryProductDetails(GoogleProductsID.precos.keys.toSet());

    try {
      var meuID = getFirebase.fUser.uid;

      Pagamento p = Pagamento();
      p.tipsterId = user.dados.id;
      p.data = DataHora.onlyDate;
      p.valor = user.seguidores[meuID] ?? '';
      p.filiadoId = meuID;

      if(p.valor == MyStrings.DEFAULT)
        p.valor = user.dados.precoPadrao;

      var productID = p.valor.substring(0, p.valor.indexOf(','));

      PurchaseParam purchaseParam = PurchaseParam(
          productDetails: productDetailResponse.productDetails.firstWhere((e) => e.id == productID),
          applicationUserName: meuID
      );

      if (await _connection.buyConsumable(purchaseParam: purchaseParam)) {
        while (true) {
          if (await p.salvar())
            break;
        }
        getFirebase.notificationManager.sendPagamento(user);
        Log.toast('Pagamento concluido');
      }

      return true;
    } catch (e) {
      Log.e(TAG, 'novoPagamento', e, false);
      Log.toast('Não foi possível realizar esta ação', isError: true);
      return false;
    }
  }

}