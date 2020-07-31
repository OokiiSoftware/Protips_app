import 'package:protips/res/resources.dart';
import 'package:protips/auxiliar/import.dart';

class Error {

  bool isExpanded = false;

  String classe;
  String userId;
  String metodo;
  String valor;
  String data;
  int quantidade = 1;

  Error();

  Error.fromJson(Map map) {
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
      var result = await getFirebase.databaseReference()
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

  Future<bool> delete() async {
    try {
      var result = await getFirebase.databaseReference()
          .child(FirebaseChild.LOGS)
          .child(data)
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

}