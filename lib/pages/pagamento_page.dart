import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/pagamento.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/resources.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;

  ProductDetails _product;
  String _queryProductError;
  String _log = '';
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  bool _comraResultOK = false;
  //endregion

  //region overrides

  @override
  void initState() {
    Stream purchaseUpdated = _connection.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (e) {
      Log.e(TAG, 'metodo', e);
    });
    initStoreInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = [];
    if (_queryProductError == null) {
      stack.add(
        ListView(
          children: [
            _buildConnectionCheckTile,
            _buildProductList,
          ],
        ),
      );
    } else {
      stack.add(Center(
        child: Text(_queryProductError),
      ));
    }
    if (_purchasePending) {
      stack.add(
        Stack(
          children: [
            Opacity(
              opacity: 0.3,
              child: const ModalBarrier(dismissible: false, color: Colors.grey),
            ),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    if (_log.isNotEmpty)
      stack.add(Center(child: Text(_log, style: TextStyle(color: ThemeData.light().errorColor))));

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _comraResultOK);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(Titles.PAGAMENTO),
        ),
        body: Stack(
          children: stack,
        ),
      ),
    );
  }

  //endregion

  //region Metodos

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    ProductDetailsResponse productDetailResponse =
    await _connection.queryProductDetails(GoogleProductsID.precos.keys.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
      });
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
      });
    }

    setState(() {
      _isAvailable = isAvailable;
      _product = productDetailResponse.productDetails.firstWhere((e) => e.id == itemID);
      _purchasePending = false;
      _loading = false;
    });
  }

  String get itemID {
    var valor = _user.seguidores[getFirebase.fUser.uid] ?? '';
    if (valor == MyStrings.DEFAULT) valor = _user.dados.precoPadrao;
    return valor.substring(0, valor.indexOf(','));
  }

  Card get _buildConnectionCheckTile {
    if (_loading) {
      return Card(child: ListTile(title: const Text('Tentando se conectar...')));
    }
    final Widget storeHeader = ListTile(
      leading: Icon(_isAvailable ? Icons.check : Icons.block,
          color: _isAvailable ? Colors.green : ThemeData.light().errorColor),
      title: Text((_isAvailable ? 'Tudo OK' : 'Temos um problema') + '.'),
    );
    final List<Widget> children = <Widget>[storeHeader];

    if (!_isAvailable) {
      children.addAll([
        Divider(),
        ListTile(
          title: Text('Não conectado', style: TextStyle(color: ThemeData.light().errorColor)),
          subtitle: const Text('Não foi possível conectar ao processador de pagamentos.'),
        ),
      ]);
    }
    return Card(child: Column(children: children));
  }

  Card get _buildProductList {
    if (_loading) {
      return Card(
          child: (ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Por favor, aguarde um pouco...'))));
    }
    if (!_isAvailable) {
      return Card();
    }
    final ListTile productHeader = ListTile(title: Text('Realizar pagamento'));
    List<ListTile> productList = <ListTile>[];

    productList.add(ListTile(
        title: Text(_product.title),
        subtitle: Text(_product.description),
        trailing: FlatButton(
          child: Text(_product.price),
          color: Colors.green[800],
          textColor: Colors.white,
          onPressed: _comraResultOK ? null : _onPagarClick,
        )));

    return Card(child: Column(children: <Widget>[productHeader, Divider()] + productList));
  }

  void _onPagarClick() {
    _setLogError();
    PurchaseParam purchaseParam = PurchaseParam(productDetails: _product);

    _connection.buyConsumable(purchaseParam: purchaseParam);
  }

  void _setLogError([String value = '']) {
    setState(() {
      _log = value;
    });
  }

  void _showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void _handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
    _setLogError('Desculpe. Ocorreu um erro com o seu pagamento.');
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) async {
    var meuID = getFirebase.fUser.uid;

    Pagamento p = Pagamento();
    p.tipsterId = _user.dados.id;
    p.data = DataHora.onlyDate;
    p.filiadoId = meuID;
    p.valor = itemID;

    while (true) {
      if (await p.salvar())
        break;
    }
    getFirebase.notificationManager.sendPagamento(_user);
    Log.toast('Pagamento concluido');

    setState(() {
      _purchasePending = false;
      _comraResultOK = true;
    });
    Navigator.pop(context, _comraResultOK);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // lidar com compra inválida aqui se _verifyPurchase` falhou.
    _setLogError('Parece que este pagamento não é válido.');
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANTE !! Sempre verifique uma compra antes de entregar o produto.
    // Para fins de exemplo, retornamos true diretamente.
    return Future<bool>.value(true);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showPendingUI();
        return;
      }

      if (purchaseDetails.status == PurchaseStatus.error) {
        _handleError(purchaseDetails.error);
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        if (!await _verifyPurchase(purchaseDetails)) {
          _handleInvalidPurchase(purchaseDetails);
          return;
        }
        _deliverProduct(purchaseDetails);
      }
      if (Platform.isAndroid) {
        await _connection.consumePurchase(purchaseDetails);
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _connection.completePurchase(purchaseDetails);
      }
    });
  }

  //endregion
}
