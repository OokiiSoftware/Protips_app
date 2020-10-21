import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/error.dart';
import 'package:protips/res/theme.dart';
import 'firebase.dart';

class Log {
  static final scaffKey = GlobalKey<ScaffoldState>();

  static void snackbar(String texto, {bool isError = false}) {
    try {
      scaffKey.currentState.hideCurrentSnackBar();

      var tint = isError ? Colors.white : Colors.black;
      var snack = SnackBar(
        content: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isError ? Icons.clear : Icons.check, color: tint),
              SizedBox(width: 12.0),
              Text(texto, style: TextStyle(color: tint)),
            ],
          ),
        ),
        backgroundColor: isError ? MyTheme.tintColorError : MyTheme.accent,
      );
      scaffKey.currentState.showSnackBar(snack);
    } catch (ex) {
      e('Log', 'snackbar', ex);
    }
  }

  static void d(String tag, String metodo, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = '';
    if (value != null) msg += value.toString();
    if (value1 != null) msg += ': ' + value1.toString();
    if (value2 != null) msg += ': ' + value2.toString();
    if (value3 != null) msg += ': ' + value3.toString();
    print(tag + ": D/" + metodo + ": " + msg);
  }

  /// Esse método (envia) o erro pro database se o app estiver no modo Release
  static void e(String tag, String metodo, dynamic e, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = e.toString();
    bool send = Aplication.isRelease;
    // if (value != null)
    //   if (value is bool) {
    //     send = value;
    //     value = null;
    //   }

    if (value != null) msg += ': ' + value.toString();
    if (value1 != null) msg += ': ' + value1.toString();
    if (value2 != null) msg += ': ' + value2.toString();
    if (value3 != null) msg += ': ' + value3.toString();
    print(tag + ": E/: " + metodo + ': ' + msg);

    if (send)
      _sendError(tag, metodo, msg);
  }

  /// Esse método (não envia) o erro pro database
  static void e2(String tag, String metodo, dynamic e, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = e.toString();

    if (value != null) msg += ': ' + value.toString();
    if (value1 != null) msg += ': ' + value1.toString();
    if (value2 != null) msg += ': ' + value2.toString();
    if (value3 != null) msg += ': ' + value3.toString();
    print(tag + ": E2/: " + metodo + ': ' + msg);
  }

  static _sendError(String tag, String metodo, String value) {
    String id = FirebasePro.user?.uid ?? 'deslogado';

    Erro e = Erro();
    e.data = DataHora.now();
    e.classe = tag;
    e.metodo = metodo;
    e.valor = value;
    e.userId = id;
    e.salvar();
  }
}