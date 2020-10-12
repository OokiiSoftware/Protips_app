import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/denuncia.dart';
import 'package:protips/model/notificacao.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/token.dart';
import 'package:protips/model/user.dart';
import 'package:protips/pages/gerencia_page.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase.dart';
import 'log.dart';

class NotificationManager {

  //region Variaveis
  static const String TAG = 'NotificationManager';

  BuildContext context;
  NotificationManager(this.context);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final SharedPreferences pref = Aplication.sharedPref;

  String _currentToken = '';
  User _user;

  //endregion

  void init() async {
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
        onMessage: _onReceiveMessage,
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

    _atualizarTopics();

    String tokem = await _fcm.getToken();
    await _saveTokem(_createToken(tokem));
    user.validarTokens();
    Log.d(TAG, 'fcm', 'tokem', tokem);
  }

  //region get set

  User get user {
    if (_user == null)
      _user = Firebase.user;
    return _user;
  }

  String get currentToken => _currentToken ?? '';
  set currentToken(String value) {_currentToken = value;}

  String get meuID => user.dados.id;

  //endregion

  //region sends

  Future<bool> _sendPost(Post item, User destino) async {
    try {
      if (!item.isPublico) {
        var pagamento = await destino.pagamento(user.dados.id, DataHora.onlyDate);
        Log.d(TAG, 'sendPost', 'pagamento', pagamento);
        // if (pagamento == null) return sendCobranca(destino);
      }

      await destino.validarTokens();

      Log.d(TAG, 'sendPost', 'destino', destino.dados.nome);
      for (String token in destino.tokens.keys) {
        String body = MyStrings.ESPORTE + ': ' + item.esporte;
        body += '\n'+ MyStrings.ODD_ATUAL + ': ' + item.oddAtual;

        if (item.campeonato.isNotEmpty)
          body += '\n'+ MyStrings.CAMPEONATO + ': ' + item.campeonato;

        if (item.oddMinima.isNotEmpty && item.oddMaxima.isNotEmpty)
          body += '\n'+ MyStrings.ODD + ': ' + item.oddMinima + ' - ' + item.oddMaxima;

        if (item.horarioMinimo.isNotEmpty && item.horarioMaximo.isNotEmpty)
          body += '\n'+ MyStrings.HORARIO + ': ' + item.horarioMinimo + ' - ' + item.horarioMaximo;

        PushNotification notificacao = PushNotification();
        notificacao.remetente = meuID;
        notificacao.title = MyTexts.NOVO_TIP + ': ' + user.dados.nome;
        notificacao.body = body;
        notificacao.timestamp = item.data;
        notificacao.token = token;
        notificacao.topic = NotificationTopics.receberTips(meuID);
        notificacao.action = NotificationActions.NOVO_TIP;
        notificacao.enviar();
      }
      return true;
    } catch(e) {
      Log.e(TAG, 'sendPost', e);
      return false;
    }
  }
  Future<bool> sendPostTopic(Post item) async {
    Log.d(TAG, 'sendPostTopic', 'init');
    await user.refresh();
    try {
      String pagantes = '';

      Log.d(TAG, 'sendPostTopic', 'seguidores', user.seguidores.keys);
      for (String key in user.seguidores.keys) {
        if(item.isPublico)
          pagantes += '$key,';
        else {
          var user = await getUsers.get(key);
          if (user != null) {
            String mensalidade = await user.pagamento(meuID, DataHora.onlyDate);
            if (mensalidade != null) pagantes += '$key,';
          }
        }
      }

      Log.d(TAG, 'sendPostTopic', 'pagantes', pagantes);
      if (pagantes.length > 5)
        await _sendPostTopicAux(item, pagantes);

      return true;
    } catch(e) {
      Log.e(TAG, 'sendPostTopic', e);
      return false;
    }
  }
  Future<bool> _sendPostTopicAux(Post item, String destinos) async {
    Log.d(TAG, 'sendPostTopicAux', 'destino', destinos);
    try {
      String body = MyStrings.ESPORTE + ': ' + item.esporte;
      body += '\n'+ MyStrings.ODD_ATUAL + ': ' + item.oddAtual;

      if (item.campeonato.isNotEmpty)
        body += '\n'+ MyStrings.CAMPEONATO + ': ' + item.campeonato;

      if (item.oddMinima.isNotEmpty && item.oddMaxima.isNotEmpty)
        body += '\n'+ MyStrings.ODD + ': ' + item.oddMinima + ' - ' + item.oddMaxima;

      if (item.horarioMinimo.isNotEmpty && item.horarioMaximo.isNotEmpty)
        body += '\n'+ MyStrings.HORARIO + ': ' + item.horarioMinimo + ' - ' + item.horarioMaximo;

      PushNotification notificacao = PushNotification();
      notificacao.remetente = meuID;
      notificacao.title = MyTexts.NOVO_TIP + ': ' + user.dados.nome;
      notificacao.body = body;
      notificacao.timestamp = item.data;
      notificacao.pagantes = destinos;
      notificacao.topic = NotificationTopics.receberTips(meuID);
      notificacao.action = NotificationActions.NOVO_TIP;
      notificacao.enviarTopic();

      return true;
    } catch (e) {
      Log.e(TAG, 'sendPostTopicAux', e);
      return false;
    }
  }

  Future<bool> _sendCobranca(User destino) async {
    try {
      await destino.validarTokens();
      for (String token in destino.tokens.keys) {
        String titulo = '${MyTexts.NOVO_TIP}: ${user.dados.nome}';
        String texto = MyTexts.REALIZAR_PAGAMENTO;

        PushNotification notificacao = new PushNotification();
        notificacao.title = titulo;
        notificacao.body = texto;
        notificacao.timestamp = DataHora.now();
        notificacao.remetente = user.dados.id;
        notificacao.action = NotificationActions.REALIZAR_PAGAMENTO;
        notificacao.token = token;
        notificacao.enviar();
      }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendCobranca', e);
      return false;
    }
  }
  Future<bool> _sendCobrancaTopic(List<String> destinos) async {
    try {
      // await destino.validarTokens();
      // for (String token in destino.tokens.keys) {
      //   String titulo = '${MyTexts.NOVO_TIP}: ${user.dados.nome}';
      //   String texto = MyTexts.REALIZAR_PAGAMENTO;
      //
      //   PushNotification notificacao = new PushNotification();
      //   notificacao.title = titulo;
      //   notificacao.body = texto;
      //   notificacao.timestamp = DataHora.now();
      //   notificacao.remetente = user.dados.id;
      //   notificacao.action = NotificationActions.REALIZAR_PAGAMENTO;
      //   notificacao.token = token;
      //   notificacao.enviar();
      // }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendCobranca', e);
      return false;
    }
  }

  Future<bool> sendSolicitacaoSeguidor(User destino) async {
    try {
      await destino.validarTokens();
      for (String token in destino.tokens.keys) {
        String titulo = MyTexts.SOLICITACAO_FILIADO;
        String texto = user.dados.nome;

        PushNotification notificacao = new PushNotification();
        notificacao.title = titulo;
        notificacao.body = texto;
        notificacao.timestamp = DataHora.now();
        notificacao.remetente = user.dados.id;
        notificacao.action = NotificationActions.SOLICITACAO_FILIALDO;
        notificacao.token = token;
        notificacao.enviar();
      }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoSeguidor', e);
      return false;
    }
  }

  Future<bool> sendSolicitacaoAceitaSeguidor(User destino) async {
    try {
      await destino.validarTokens();
      for (String token in destino.tokens.keys) {
        String titulo = MyTexts.SOLICITACAO_ACEITA;
        String texto = user.dados.nome;

        PushNotification notificacao = new PushNotification();
        notificacao.title = titulo;
        notificacao.body = texto;
        notificacao.timestamp = DataHora.now();
        notificacao.remetente = user.dados.id;
        notificacao.action = NotificationActions.SOLICITACAO_ACEITA_FILIALDO;
        notificacao.token = token;
        notificacao.enviar();
      }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoAceitaSeguidor', e);
      return false;
    }
  }

  Future<bool> sendSolicitacaoTipsterAceita(User destino) async {
    try {
      await destino.validarTokens();
      for (String token in destino.tokens.keys) {
        String titulo = MyTexts.SOLICITACAO_ACEITA;
        String texto = 'Parabéns. Agora você é um Tipster na ProTips';

        PushNotification notificacao = new PushNotification();
        notificacao.title = titulo;
        notificacao.body = texto;
        notificacao.timestamp = DataHora.now();
        notificacao.remetente = user.dados.id;
        notificacao.action = NotificationActions.SOLICITACAO_ACEITA_TIPSTER;
        notificacao.token = token;
        notificacao.enviar();
      }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoTipsterAceita', e);
      return false;
    }
  }

  Future<bool> sendSolicitacaoTipster(User destino) async {
    try {
      await destino.validarTokens();
      for (String token in destino.tokens.keys) {
        String titulo = MyTexts.SOLICITACAO_TIPSTER;
        String texto = user.dados.nome + ' | ' + user.dados.tipname;

        PushNotification notificacao = new PushNotification();
        notificacao.title = titulo;
        notificacao.body = texto;
        notificacao.timestamp = DataHora.now();
        notificacao.remetente = user.dados.id;
        notificacao.action = NotificationActions.SOLICITACAO_TIPSTER;
        notificacao.token = token;
        notificacao.enviar();
      }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoTipster', e);
      return false;
    }
  }

  Future<bool> sendDenuncia(Denuncia item) async {
    try {
      User destino = await getUsers.get(item.idUser);
      if (destino == null)
        return false;
      await destino.validarTokens();
      Log.d(TAG, 'sendDenuncia', 'destino', destino.dados.nome);
      for (String token in destino.tokens.keys) {
        String body = MyStrings.MOTIVO + ': ' + item.texto;

        PushNotification notificacao = PushNotification();
        notificacao.remetente = user.dados.id;
        notificacao.title = MyStrings.ATENCAO.toUpperCase() + ' ' + MyTexts.VC_FOI_DENUNCIADO;
        notificacao.body = body;
        notificacao.timestamp = item.data;
        notificacao.token = token;
        notificacao.action = NotificationActions.DENUNCIA;
        notificacao.enviar();
      }
      return true;
    } catch(e) {
      Log.e(TAG, 'sendDenuncia', e);
      return false;
    }
  }

  Future<bool> sendPagamento(User destino) async {
    try {
      await destino.validarTokens();
      for (String token in destino.tokens.keys) {
        String titulo = MyTexts.PAGAMENTO_REALIZADO;
        String texto = user.dados.nome + ' | ' + user.dados.tipname;

        PushNotification notificacao = new PushNotification();
        notificacao.title = titulo;
        notificacao.body = texto;
        notificacao.timestamp = DataHora.now();
        notificacao.remetente = user.dados.id;
        notificacao.action = NotificationActions.PAGAMENTO_REALIZADO;
        notificacao.token = token;
        notificacao.enviar();
      }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendPagamento', e);
      return false;
    }
  }

  //endregion

  //region Token

  Token _createToken(String token) {
    Token item = Token();
    item.data = DataHora.now();
    item.value = token;
    item.device = Device.name;
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

  //endregion

  Future _onReceiveMessage(message) async {
    PushNotification notification = PushNotification();
    String pagantes = message['data']['pagantes'];
    notification.action = message['data']['action'];
    notification.remetente = message['data']['remetente'];
    notification.title = message['notification']['title'];

    if (pagantes == null || pagantes.contains(meuID)) {
      notification.body = message['notification']['body'];
    } else {
      notification.body = MyTexts.REALIZAR_PAGAMENTO;
    }

    switch(notification.action) {
      case NotificationActions.SOLICITACAO_ACEITA_FILIALDO:
        _fcm.subscribeToTopic(NotificationTopics.receberTips(notification.remetente));
        break;
      case NotificationActions.FILIALDO_REMOVIDO:
        _fcm.unsubscribeFromTopic(NotificationTopics.receberTips(notification.remetente));
        break;
    }

    _showNotification(notification);
    Log.d(TAG, 'fcm', 'onMessage', message);
  }

  Future _onSelectNotification (String payload) async {
    if (payload != null && context != null) {
      Log.d(TAG, 'onSelectNotification', payload);
      switch(payload) {
        case NotificationActions.NOVO_TIP:
//        Navigator.of(context).pushNamed(PostPage.tag, arguments: await getPosts.baixar(postKey, userId));
          break;
        case NotificationActions.ATUALIZACAO:
          break;
        case NotificationActions.SOLICITACAO_TIPSTER:
          Navigate.to(context, GerenciaPage());
          break;
      }
    }
  }

  _showNotification(PushNotification notification) async {
    try {
      var android = AndroidNotificationDetails(
          'channelId', 'channelName', 'channelDescription',
        ledColor: MyTheme.primary(),
        vibrationPattern: Int64List(8),
        enableLights: true,
      );
      var iOS = IOSNotificationDetails();
      var platform = NotificationDetails(android, iOS);
      await flutterLocalNotificationsPlugin.show(0, notification.title, notification.body, platform, payload: notification.action);
    } catch (e) {
      Log.e(TAG, 'showNotification', e);
    }
  }

  void _atualizarTopics() async {
    for (String key in user.seguindo.keys) {
      User user = await getUsers.get(key);
      if (user != null) {
        if (user.seguidores.containsKey(meuID))
          await _fcm.subscribeToTopic(NotificationTopics.receberTips(key));
        else
          await _fcm.unsubscribeFromTopic(NotificationTopics.receberTips(key));
      }
    }
    Log.d(TAG, 'atualizarTopics', 'OK');
  }

}
