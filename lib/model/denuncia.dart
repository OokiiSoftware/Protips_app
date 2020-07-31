import 'package:protips/auxiliar/import.dart';
import 'package:protips/res/resources.dart';

class Denuncia {

  static const String TAG = 'Denuncia';

  bool isExpanded = false;

  bool _isUser;
  String _data;
  String _texto;
  String _idUser;
  String _itemKey;
  String _assunto;
  String _idDenunciante;

  int quantidade = 1;

  Denuncia();

  Denuncia.fromJson(Map map) {
    data = map['data'];
    texto = map['texto'];
    idUser = map['idUser'];
    isUser = map['isUser'];
    itemKey = map['itemKey'];
    assunto = map['assunto'];
    idDenunciante = map['idDenunciante'];
  }

  Map toJson() => {
    'data': data,
    'texto': texto,
    'idUser': idUser,
    'isUser': isUser,
    'itemKey': itemKey,
    'assunto': assunto,
    'idDenunciante': idDenunciante,
  };

  static Map<String, Denuncia> fromJsonList(Map map) {
    Map<String, Denuncia> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = Denuncia.fromJson(map[key]);
    return items;
  }


  Future<bool> salvar() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.DENUNCIAS)
        .child(data)
        .set(toJson())
        .then((value) => true)
        .catchError((ex) => false);
    Log.d(TAG, 'salvar', result);
    return result;
  }

  Future<bool> delete() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.DENUNCIAS)
        .child(data)
        .remove()
        .then((value) => true)
        .catchError((ex) => false);
    Log.d(TAG, 'delete', result);
    return result;
  }

  Future<bool> aprovar() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(idUser)
        .child(FirebaseChild.DENUNCIAS)
        .child(data)
        .set(toJson())
        .then((value) => true)
        .catchError((ex) => false);
    if (result) {
      getFirebase.notificationManager.sendDenuncia(this);
      await delete();
    }
    Log.d(TAG, 'aprovar', result);
    return result;
  }

  //region get set

  String get assunto => _assunto ?? '';

  bool get isUser => _isUser ?? '';

  set isUser(bool value) {
    _isUser = value;
  }

  String get idUser => _idUser ?? '';

  set idUser(String value) {
    _idUser = value;
  }

  String get idDenunciante => _idDenunciante ?? '';

  set idDenunciante(String value) {
    _idDenunciante = value;
  }

  String get data => _data ?? '';

  set data(String value) {
    _data = value;
  }

  String get itemKey => _itemKey ?? '';

  set itemKey(String value) {
    _itemKey = value;
  }

  String get texto => _texto ?? '';

  set texto(String value) {
    _texto = value;
  }

  set assunto(String value) {
    _assunto = value;
  }

  //endregion
}