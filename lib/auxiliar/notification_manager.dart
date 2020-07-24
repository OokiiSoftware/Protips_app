import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data.dart';
import 'package:protips/model/notificacao.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/token.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/resources.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static const String TAG = 'NotificationManager';

  BuildContext context;
  NotificationManager(this.context);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  FirebaseMessaging _fcm = FirebaseMessaging();
  SharedPreferences pref;

  String _currentToken = '';
  User _user;

  void init() async {
    pref = await SharedPreferences.getInstance();
    currentToken = pref.getString(SharedPreferencesKey.ULTIMO_TOKEM);

    //region FlutterLocalNotifications

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('ic_notification');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: _onSelectNotification);

    //endregion

    //region _fcm.configure

    _fcm.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );

    _fcm.configure(
        onMessage: (message) async {
          PushNotification notification = PushNotification();
          notification.title = message['notification']['title'];
          notification.body = message['notification']['body'];
          notification.action = message['data']['action'];
          _showNotification(notification);

//          String title = message['notification']['title'];
//          String body = message['notification']['body'];
//          var data = message['data'];
//          var action = data['action'];
//          var itemId = data['item_id'];
//          var remetenteId = data['remetente'];
          /*if (action != null) {
            switch(action.toString()) {
              case NotificationActions.ATUALIZACAO:
                Import.openUrl(await Import.buscarAtualizacao());
                break;
              case NotificationActions.SOLICITACAO_FILIAL:
                break;
              case NotificationActions.SOLICITACAO_TIPSTER:
              break;
              case NotificationActions.NOVO_TIP:
//                if (_context != null) {
//                  Map<String, String> args = Map();
//                  args['itemKey'] = itemId;
//                  args['canOpenPerfil'] = 'true';
//                  Navigator.of(_context).pushNamed(PostPage.tag, arguments: args);
//                }
                break;
            }
            Log.d(TAG, 'fcm', 'onMessage', 'action', action);
          }*/

//          Log.d(TAG, 'fcm', 'onMessage', 'action', action);
//          Log.d(TAG, 'fcm', 'onMessage', title, body);
          Log.d(TAG, 'fcm', 'onMessage', message);
        },
        onResume: (message) async {
          Log.d(TAG, 'fcm', 'onResume', message);
        },
        onLaunch: (message) async {
          Log.d(TAG, 'fcm', 'onLaunch', message);
        }
    );
    _fcm.onTokenRefresh.listen((event) {
      _updateToken(_createToken(event));
    });
    //endregion

    String tokem = await _fcm.getToken();
    await _saveTokem(_createToken(tokem));
    user.validarTokens();
    Log.d(TAG, 'fcm', 'tokem', tokem);
  }

  User get user {
    if (_user == null)
      _user = getFirebase.user();
    return _user;
}

  // ignore: unnecessary_getters_setters
  String get currentToken => _currentToken;
  // ignore: unnecessary_getters_setters
  set currentToken(String value) {
    _currentToken = value;
  }

  Future<bool> sendPost(Post post, User destino) async {
    try {
      await destino.validarTokens();
      Log.d(TAG, 'sendPost', 'destino', destino.dados.nome);
      for (String token in destino.tokens.keys) {
        String body = MyStrings.ESPORTE + ': ' + post.esporte;
        body += '\n'+ MyStrings.ODD_ATUAL + ': ' + post.oddAtual;

        if (post.campeonato.isNotEmpty)
          body += '\n'+ MyStrings.CAMPEONATO + ': ' + post.campeonato;

        if (post.oddMinima.isNotEmpty && post.oddMaxima.isNotEmpty)
          body += '\n'+ MyStrings.ODD + ': ' + post.oddMinima + ' - ' + post.oddMaxima;

        if (post.horarioMinimo.isNotEmpty && post.horarioMaximo.isNotEmpty)
          body += '\n'+ MyStrings.HORARIO + ': ' + post.horarioMinimo + ' - ' + post.horarioMaximo;

        PushNotification notificacao = PushNotification();
        notificacao.de = user.dados.id;
        notificacao.title = MyTexts.NOVO_TIP + ': ' + user.dados.nome;
        notificacao.body = body;
        notificacao.timestamp = post.data;
        notificacao.token = token;
        notificacao.action = NotificationActions.NOVO_TIP;
        notificacao.enviar();
      }
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<bool> sendSolicitacao(User destino) async {
    try {
      await destino.validarTokens();
      for (String token in destino.tokens.keys) {
        String titulo = MyTexts.SOLICITACAO_FILIAL;
        String texto = getFirebase.user().dados.nome;

        PushNotification notificacao = new PushNotification();
        notificacao.title = titulo;
        notificacao.body = texto;
        notificacao.timestamp = Data.now();
        notificacao.de = getFirebase.fUser().uid;
        notificacao.action = NotificationActions.SOLICITACAO_FILIAL;
        notificacao.token = token;
        notificacao.enviar();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendSolicitacaoAceita(User destino) async {
    try {
      await destino.validarTokens();
      for (String token in destino.tokens.keys) {
        String titulo = MyTexts.SOLICITACAO_ACEITA;
        String texto = getFirebase.user().dados.nome;

        PushNotification notificacao = new PushNotification();
        notificacao.title = titulo;
        notificacao.body = texto;
        notificacao.timestamp = Data.now();
        notificacao.de = getFirebase.fUser().uid;
        notificacao.action = NotificationActions.SOLICITACAO_ACEIRA;
        notificacao.token = token;
        notificacao.enviar();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Token _createToken(String token) {
    Token item = Token();
    item.data = Data.now();
    item.value = token;
    item.device = Import.getDeviceName();
    return item;
  }

  _saveTokem(Token token) async {
    await user.salvarToken(token);
    currentToken = token.value;

    pref.setString(SharedPreferencesKey.ULTIMO_TOKEM, currentToken);
  }

  _updateToken(Token token) async {
    await user.removeToken(currentToken);
    _saveTokem(token);
  }


  //======================

  Future _onSelectNotification (String payload) async {
//    if (context != null)
//      Navigator.of(context).pushNamed(MainPage.tag);
  }

  _showNotification(PushNotification notification) async {
    var android = AndroidNotificationDetails('channelId', 'channelName', 'channelDescription');
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, notification.title, notification.body, platform);
  }

}
//fgE0FyogCM8:APA91bFXdj8NuY8kZQukuezgHsPNVhyCmABwlvP53AAGtFggEcgu9Sw6bx4_ChznnuKZ3s9E74bHwtseu6Qu2CAa-uJzH-iqK_fCPOzFdaSIdSfHWDDKuRZsZeCpGio4dxZKEr6laV4t