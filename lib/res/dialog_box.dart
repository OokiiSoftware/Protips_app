import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:protips/res/strings.dart';

class DialogResult {
  static int none = 0;
  static int cancel = 3;
  static int ok = 4;

  DialogResult(this.result);

  int result;
  bool get isOk => result == ok;
  bool get isCancel => result == cancel;
  bool get isNone => result == none;
}

class DialogBox {
  static Future<DialogResult> dialogCancelOK(BuildContext context, {String title, Widget content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title, content: content, contentPadding: contentPadding);
  }
  static Future<DialogResult> dialogOK(BuildContext context, {String title, Widget content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title, content: content, contentPadding: contentPadding, cancelButton: false);
  }
  static Future<DialogResult> dialogCancel(BuildContext context, {String title, Widget content, EdgeInsets contentPadding}) async {
    return await _dialogAux(context, title: title, content: content, contentPadding: contentPadding, okButton: false);
  }

  static Future<DialogResult> _dialogAux(BuildContext context, {String title, Widget content, EdgeInsets contentPadding, bool okButton = true, bool cancelButton = true, bool noneButton = false}) async {
    if(contentPadding == null)
      contentPadding = EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0);
    return await showModal<DialogResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: title == null ? null : Text(title),
        content: content,
        contentPadding: contentPadding,
        actions: [
          if (noneButton) FlatButton(
            child: Text(MyStrings.FECHAR),
            onPressed: () => Navigator.pop(context, DialogResult(DialogResult.none)),
          ),
          if (cancelButton) FlatButton(
            child: Text(MyStrings.CANCELAR),
            onPressed: () => Navigator.pop(context, DialogResult(DialogResult.cancel)),
          ),
          if (okButton) FlatButton(
            child: Text(MyStrings.OK),
            onPressed: () => Navigator.pop(context, DialogResult(DialogResult.ok)),
          ),
        ],
      ),
    ) ?? DialogResult.none;
    // return await showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: title == null ? null : Text(title),
    //       content: content,
    //       contentPadding: contentPadding,
    //       actions: [
    //         if (noneButton) FlatButton(
    //           child: Text(MyStrings.FECHAR),
    //           onPressed: () => Navigator.pop(context, DialogResult(DialogResult.none)),
    //         ),
    //         if (cancelButton) FlatButton(
    //           child: Text(MyStrings.CANCELAR),
    //           onPressed: () => Navigator.pop(context, DialogResult(DialogResult.cancel)),
    //         ),
    //         if (okButton) FlatButton(
    //           child: Text(MyStrings.OK),
    //           onPressed: () => Navigator.pop(context, DialogResult(DialogResult.ok)),
    //         ),
    //       ],
    //     )
    // ) ?? false;
  }
}
