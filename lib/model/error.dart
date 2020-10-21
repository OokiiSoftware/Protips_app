import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/log.dart';

class Erro {

  bool isExpanded = false;

  String classe;
  String userId;
  String metodo;
  String valor;
  String data;
  List<String> _similares;

  Erro();

  Erro.fromJson(Map map) {
    classe = map['classe'];
    userId = map['userId'];
    metodo = map['metodo'];
    valor = map['valor'];
    data = map['data'];
  }
  Map toJson() => {
    "classe": classe,
    "userId": userId,
    "metodo": metodo,
    "valor": valor,
    "data": data,
  };

  Future<bool> salvar() async {
    try {
      var result = await FirebasePro.database
          .child(FirebaseChild.LOGS)
          .child(data)
          .set(toJson())
          .then((value) => true)
          .catchError((ex) => false);
      Log.d('Error', 'salvar', result);
      return result;
    } catch(e) {
      //Todo \(ºvº)/
      return false;
    }
  }

  Future<bool> _delete(String key) async {
    try {
      var result = await FirebasePro.database
          .child(FirebaseChild.LOGS)
          .child(key)
          .remove()
          .then((value) => true)
          .catchError((ex) => false);
      Log.d('Error', 'delete', result);
      return result;
    } catch(e) {
      //Todo \(ºvº)/
      return false;
    }
  }

  Future<bool> deleteAll() async {
    List<bool> list = [];
    for (String key in similares) {
      list.add(await _delete(key));
    }
    var quantidade = list.where((x) => x == false).length;
    return quantidade == 0;
  }

  List<String> get similares {
    if (_similares == null)
      _similares = [];
    return _similares;
  }

}