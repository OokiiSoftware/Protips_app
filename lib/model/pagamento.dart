import 'package:protips/model/data_hora.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/auxiliar/import.dart';

class Pagamento {
  static const String TAG = 'Pagamento';

  bool isExpanded = false;

  String tipsterId;
  String filiadoId;
  String valor;
  String data;

  Future<bool> salvar() async {
    try {
      var result = await getFirebase.databaseReference
          .child(FirebaseChild.PAGAMENTOS)
          .child(tipsterId)
          .child(data)
          .child(filiadoId)
          .set(valor)
          .then((value) => true)
          .catchError((ex) => false);
      Log.d(TAG, 'salvar', result);
      return result;
    } catch(e) {
      Log.e(TAG, 'salvar', e);
      return false;
    }
  }

  Future<bool> delete() async {
    try {
      var result = await getFirebase.databaseReference
          .child(FirebaseChild.PAGAMENTOS)
          .child(tipsterId)
          .child(data)
          .child(filiadoId)
          .remove()
          .then((value) => true)
          .catchError((ex) => false);
      Log.d(TAG, 'delete', result);
      return result;
    } catch(e) {
      Log.e(TAG, 'delete', e);
      return false;
    }
  }

  static Future<bool> load(String userID) async {
    try {
      var result = await getFirebase.databaseReference
          .child(FirebaseChild.PAGAMENTOS)
          .child(userID)
          .child(DataHora.onlyDate)
          .child(getFirebase.fUser.uid)
          .once()
          .then((value) => value.value != null)
          .catchError((ex) => false);
      Log.d(TAG, 'load', result);
      return result;
    } catch(e) {
      Log.e(TAG, 'load', e);
      return false;
    }
  }
  static Future<Map<dynamic, dynamic>> loadAll(String userID) async {
    try {
      var result = await getFirebase.databaseReference
          .child(FirebaseChild.PAGAMENTOS)
          .child(userID)
          .once()
          .then((value) => value.value)
          .catchError((ex) => null);
      Log.d(TAG, 'load', result);
      return result;
    } catch(e) {
      Log.e(TAG, 'load', e);
      return null;
    }
  }
}