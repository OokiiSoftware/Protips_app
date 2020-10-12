import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/log.dart';

class Notificacao {

  bool isExpanded = false;
  bool isFotoLocal = false;

  String id;
  String titulo;
  String subtitulo;
  Widget eSubtitulo;
  String eTitulo;
  String foto;
  String tag;

  Notificacao({
    this.id = '',
    this.titulo = '',
    this.subtitulo = '',
    this.eSubtitulo,
    this.eTitulo = '',
    this.foto = '',
    this.tag = '',
    this.isFotoLocal = false,
    this.onTap,
    this.onLongPress});

  get hasFoto => foto.isNotEmpty;

  VoidCallback onTap;
  VoidCallback onLongPress;

}

class PushNotification {
  static const String TAG = "PushNotification";

  String _title;
  String _body;
  String _remetente;
  String _token;
  String _topic;
  String _action;
  String _timestamp;
  String _itemId;
  String _pagantes;
//  Map<dynamic, dynamic> _destinos;

  Map toJson() => {
    'title': title,
    'body': body,
    'remetente': remetente,
    'token': token,
    'topic': topic,
    'action': action,
    'item_id': itemId,
    'timestamp': timestamp,
    'pagantes': pagantes,
  };

  PushNotification();

  PushNotification.fromJson(Map map) {
    title = map['title'];
    body = map['body'];
    remetente = map['remetente'];
    token = map['token'];
    action = map['action'];
    itemId = map['item_id'];
    timestamp = map['timestamp'];
    pagantes = map['pagantes'];
  }

  Future<bool> enviar() async {
    var result = await Firebase.databaseReference
        .child(FirebaseChild.NOTIFICATIONS)
        .child(token)
        .child(timestamp)
        .set(toJson())
        .then((value) => true)
        .catchError((e) => false);

    Log.d(TAG, 'enviar', result);
    return result;
  }
  Future<bool> enviarTopic() async {
    var result = await Firebase.databaseReference
        .child(FirebaseChild.NOTIFICATIONS_TOPIC)
        .child(remetente)
        .child(timestamp)
        .set(toJson())
        .then((value) => true)
        .catchError((e) => false);

    Log.d(TAG, 'enviar', result);
    return result;
  }

  Future<bool> delete() async {
    var result = await Firebase.databaseReference
        .child(FirebaseChild.NOTIFICATIONS)
//        .child(para)
        .child(remetente)
        .child(timestamp)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    Log.d(TAG, 'delete', result);
    return result;
  }

  //region get set

  String get action => _action ?? '';

  set action(String value) {
    _action = value;
  }

  String get topic => _topic ?? '';

  set topic(String value) {
    _topic = value;
  }

  String get pagantes => _pagantes ?? null;

  set pagantes(String value) {
    _pagantes = value;
  }

  String get token => _token ?? '';

  set token(String value) {
    _token = value;
  }

  String get remetente => _remetente ?? '';

  set remetente(String value) {
    _remetente = value;
  }

  String get timestamp => _timestamp ?? '';

  set timestamp(String value) {
    _timestamp = value;
  }

  String get body => _body ?? '';

  set body(String value) {
    _body = value;
  }

  String get title => _title ?? '';

  set title(String value) {
    _title = value;
  }

  String get itemId => _itemId ?? '';

  set itemId(String value) {
    _itemId = value;
  }

  //endregion

}

class NotificationActions {
  static const String NOVO_TIP = 'NOVO_TIP';
  static const String SOLICITACAO_TIPSTER = 'SOLICITACAO_TIPSTER';
  static const String SOLICITACAO_FILIALDO = 'SOLICITACAO_FILIALDO';
  static const String SOLICITACAO_ACEITA_TIPSTER = 'SOLICITACAO_ACEITA_TIPSTER';
  static const String SOLICITACAO_ACEITA_FILIALDO = 'SOLICITACAO_ACEITA_FILIALDO';
  static const String FILIALDO_REMOVIDO = 'FILIALDO_REMOVIDO';
  static const String PAGAMENTO_REALIZADO = 'PAGAMENTO_REALIZADO';
  static const String REALIZAR_PAGAMENTO = 'REALIZAR_PAGAMENTO';
  static const String ATUALIZACAO = 'ATUALIZACAO';
  static const String DENUNCIA = 'DENUNCIA';
}

class NotificationTopics {
  static String receberTips(String uid) {
    return 'receberTips_$uid';
  }
}