import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/error.dart';
import 'package:protips/res/theme.dart';
import 'firebase.dart';

class Log {
  // static FlutterToast _toast;
  // static set setToast (BuildContext context) {
  //   _toast = FlutterToast(context);
  // }
  static final scaffKey = GlobalKey<ScaffoldState>();

  static void snackbar(String texto, {bool isError = false}) {
    try {
      scaffKey.currentState.hideCurrentSnackBar();

      var tint = isError ? MyTheme.textColor() : MyTheme.textColorInvert();
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
        backgroundColor: isError ? Colors.red : MyTheme.accent(),
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
  static void e(String tag, String metodo, dynamic e, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = e.toString();
    bool send = true;
    if (value != null) {
      if (value is bool && value == false)
        send = false;
      else
        msg += ': ' + value.toString();
    }
    if (value1 != null) msg += ': ' + value1.toString();
    if (value2 != null) msg += ': ' + value2.toString();
    if (value3 != null) msg += ': ' + value3.toString();
    print(tag + ": E/: " + metodo + ': ' + msg);
//    _saveLog(tag + msg);
    if (send)
      _sendError(tag, metodo, msg);
  }

  static _sendError(String tag, String metodo, String value) {
    String id = Firebase.fUser?.uid ?? 'deslogado';

    Error e = Error();
    e.data = DataHora.now();
    e.classe = tag;
    e.metodo = metodo;
    e.valor = value;
    e.userId = id;
    e.salvar();
  }
}