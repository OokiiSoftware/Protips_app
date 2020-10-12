import 'package:flutter/material.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/user.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';

class Pagamento {
  static const String TAG = 'Pagamento';

  bool isExpanded = false;

  Pagamento({@required this.userOrigem, @required this.userDestino, this.data, this.valor});

  final User userOrigem;
  final User userDestino;

  final String valor;
  final String data;

  Future<bool> salvar() async {
    try {
      var result = await Firebase.databaseReference
          .child(FirebaseChild.PAGAMENTOS)
          .child(userDestino.dados.id)
          .child(data)
          .child(userOrigem.dados.id)
          .set(valor)
          .then((value) => true)
          .catchError((e) => false);
      Log.d(TAG, 'salvar', result);

      if(result)
        EventListener.onPagamentoConcluido(userDestino);
      return result;
    } catch(e) {
      Log.e(TAG, 'salvar', e);
      return false;
    }
  }

  Future<bool> delete() async {
    try {
      var result = await Firebase.databaseReference
          .child(FirebaseChild.PAGAMENTOS)
          .child(userDestino.dados.id)
          .child(data)
          .child(userOrigem.dados.id)
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
      var result = await Firebase.databaseReference
          .child(FirebaseChild.PAGAMENTOS)
          .child(userID)
          .child(DataHora.onlyDate)
          .child(Firebase.fUser.uid)
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
      var result = await Firebase.databaseReference
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