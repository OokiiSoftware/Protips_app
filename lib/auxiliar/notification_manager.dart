import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/preferences.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/denuncia.dart';
import 'package:protips/model/notificacao.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/pages/gerencia_page.dart';
import 'package:protips/res/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'aplication.dart';
import 'firebase.dart';
import 'log.dart';

class NotificationManager {

  //region Variaveis
  static const String TAG = 'NotificationManager';

  static NotificationManager instance;

  BuildContext context;
  NotificationManager(this.context);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  //endregion

  void init() async {
    // currentToken = pref.getString(SharedPreferencesKey.ULTIMO_TOKEM);

    //region FlutterLocalNotifications

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('ic_notification');
    var iOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: _onSelectNotification);

    flutterLocalNotificationsPlugin.cancelAll();
    //endregion

    //region _fcm.configure

    _fcm.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));

    _fcm.configure(
        onMessage: _onReceiveMessage,
        onResume: (message) async {
          Log.d(TAG, 'fcm', 'onResume', message);
        },
        onLaunch: (message) async {
          Log.d(TAG, 'fcm', 'onLaunch', message);
        }
    );
    // _fcm.onTokenRefresh.listen((event) {
    //   _updateToken(_createToken(event));
    // });
    //endregion

    _atualizarTopics();

    // String tokem = await _fcm.getToken();
    // await _saveTokem(_createToken(tokem));
    // user.validarTokens();
    // Log.d(TAG, 'fcm', 'tokem', tokem);
  }

  Future finalize() async {
    await _removerAllTopics();
  }

  //region get set

  UserPro get user => FirebasePro.userPro;

  String get meuID => user.dados.id;

  //endregion

  //region sends

  Future<bool> _sendPost(Post item, UserPro destino) async {
    try {
      if (!item.isPublico) {
        var pagamento = await destino.pagamento(user.dados.id, DataHora.onlyDate);
        Log.d(TAG, 'sendPost', 'pagamento', pagamento);
        // if (pagamento == null) return sendCobranca(destino);
      }

      // await destino.validarTokens();

      Log.d(TAG, 'sendPost', 'destino', destino.dados.nome);
      // for (String token in destino.tokens.keys) {
      //   String body = MyStrings.ESPORTE + ': ' + item.esporte;
      //   body += '\n'+ MyStrings.ODD_ATUAL + ': ' + item.oddAtual;
      //
      //   if (item.campeonato.isNotEmpty)
      //     body += '\n'+ MyStrings.CAMPEONATO + ': ' + item.campeonato;
      //
      //   if (item.oddMinima.isNotEmpty && item.oddMaxima.isNotEmpty)
      //     body += '\n'+ MyStrings.ODD + ': ' + item.oddMinima + ' - ' + item.oddMaxima;
      //
      //   if (item.horarioMinimo.isNotEmpty && item.horarioMaximo.isNotEmpty)
      //     body += '\n'+ MyStrings.HORARIO + ': ' + item.horarioMinimo + ' - ' + item.horarioMaximo;
      //
      //   PushNotification notificacao = PushNotification();
      //   notificacao.remetente = meuID;
      //   notificacao.title = MyTexts.NOVO_TIP + ': ' + user.dados.nome;
      //   notificacao.body = body;
      //   notificacao.timestamp = item.data;
      //   notificacao.token = token;
      //   notificacao.topic = NotificationTopics.receberTips(meuID);
      //   notificacao.action = NotificationActions.NOVO_TIP;
      //   notificacao.enviar();
      // }
      return true;
    } catch(e) {
      Log.e(TAG, 'sendPost', e);
      return false;
    }
  }
  Future<bool> sendPostTopic(Post item) async {
    Log.d(TAG, 'sendPostTopic', 'init');
    await FirebasePro.atualizarOfflineUser();
    try {
      String pagantes = '';

      Log.d(TAG, 'sendPostTopic', 'seguidores', user.filiados.keys);
      for (String key in user.filiados.keys) {
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
      String body = '';// MyStrings.ESPORTE + ': ' + item.esporte;

      if(item.esporte.isNotEmpty) {
        body = MyStrings.ESPORTE + ': ' + item.esporte;
        body += '\n'+ MyStrings.ODD_ATUAL + ': ' + item.oddAtual;

        if (item.campeonato.isNotEmpty)
          body += '\n'+ MyStrings.CAMPEONATO + ': ' + item.campeonato;

        if (item.oddMinima.isNotEmpty && item.oddMaxima.isNotEmpty)
          body += '\n'+ MyStrings.ODD + ': ' + item.oddMinima + ' - ' + item.oddMaxima;

        if (item.horarioMinimo.isNotEmpty && item.horarioMaximo.isNotEmpty)
          body += '\n'+ MyStrings.HORARIO + ': ' + item.horarioMinimo + ' - ' + item.horarioMaximo;
      }
      else
        body = item.descricao;

      PushNotification notificacao = PushNotification();
      notificacao.remetente = meuID;
      notificacao.title = MyTexts.NOVO_TIP + ': ' + user.dados.nome;
      notificacao.body = body;
      notificacao.timestamp = item.data;
      notificacao.pagantes = destinos;
      notificacao.topic = NotificationTopics.receberTips(meuID);
      notificacao.action = NotificationActions.NOVO_TIP;
      await notificacao.enviarTopic();

      return true;
    } catch (e) {
      Log.e(TAG, 'sendPostTopicAux', e);
      return false;
    }
  }

  Future<bool> _sendCobranca(UserPro destino) async {
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


  Future<bool> _sendSolicitacaoSeguidor(UserPro destino) async {
    try {
      // await destino.validarTokens();
      // for (String token in destino.tokens.keys) {
      //   String titulo = MyTexts.SOLICITACAO_FILIADO;
      //   String texto = user.dados.nome;
      //
      //   PushNotification notificacao = new PushNotification();
      //   notificacao.title = titulo;
      //   notificacao.body = texto;
      //   notificacao.timestamp = DataHora.now();
      //   notificacao.remetente = user.dados.id;
      //   notificacao.action = NotificationActions.SOLICITACAO_FILIALDO;
      //   notificacao.token = token;
      //   notificacao.enviar();
      // }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoSeguidor', e);
      return false;
    }
  }
  Future<bool> sendSolicitacaoSeguidorTopic(UserPro destino) async {
    try {
      String titulo = MyTexts.SOLICITACAO_FILIADO;
      String texto = user.dados.nome;

      PushNotification notificacao = new PushNotification();
      notificacao.title = titulo;
      notificacao.body = texto;
      notificacao.timestamp = DataHora.now();
      notificacao.remetente = user.dados.id;
      notificacao.action = NotificationActions.SOLICITACAO_FILIALDO;
      notificacao.topic = NotificationTopics.solicitacaoFiliado(destino.dados.id);
      await notificacao.enviarTopic();
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoSeguidorTopic', e);
      return false;
    }
  }

  Future<bool> _sendSolicitacaoAceitaSeguidor(UserPro destino) async {
    try {
      // await destino.validarTokens();
      // for (String token in destino.tokens.keys) {
      //   String titulo = MyTexts.SOLICITACAO_ACEITA;
      //   String texto = user.dados.nome;
      //
      //   PushNotification notificacao = new PushNotification();
      //   notificacao.title = titulo;
      //   notificacao.body = texto;
      //   notificacao.timestamp = DataHora.now();
      //   notificacao.remetente = user.dados.id;
      //   notificacao.action = NotificationActions.SOLICITACAO_ACEITA_FILIALDO;
      //   notificacao.token = token;
      //   notificacao.enviar();
      // }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoAceitaSeguidor', e);
      return false;
    }
  }
  Future<bool> sendSolicitacaoAceitaSeguidorTopic(UserPro destino) async {
    try {
      String titulo = MyTexts.SOLICITACAO_ACEITA;
      String texto = user.dados.nome;

      PushNotification notificacao = new PushNotification();
      notificacao.title = titulo;
      notificacao.body = texto;
      notificacao.timestamp = DataHora.now();
      notificacao.remetente = user.dados.id;
      notificacao.action = NotificationActions.SOLICITACAO_ACEITA_FILIALDO;
      notificacao.topic = NotificationTopics.solicitacaoAceita(destino.dados.id);
      await notificacao.enviarTopic();
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoAceitaSeguidor', e);
      return false;
    }
  }

  Future<bool> _sendSolicitacaoTipsterAceita(UserPro destino) async {
    try {
      // await destino.validarTokens();
      // for (String token in destino.tokens.keys) {
      //   String titulo = MyTexts.SOLICITACAO_ACEITA;
      //   String texto = 'Parabéns. Agora você é um Tipster na ProTips';
      //
      //   PushNotification notificacao = new PushNotification();
      //   notificacao.title = titulo;
      //   notificacao.body = texto;
      //   notificacao.timestamp = DataHora.now();
      //   notificacao.remetente = user.dados.id;
      //   notificacao.action = NotificationActions.SOLICITACAO_ACEITA_TIPSTER;
      //   notificacao.token = token;
      //   notificacao.enviar();
      // }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoTipsterAceita', e);
      return false;
    }
  }
  Future<bool> sendSolicitacaoTipsterAceitaTopic(UserPro destino) async {
    try {
      String titulo = MyTexts.SOLICITACAO_ACEITA;
      String texto = 'Parabéns. Agora você é um Tipster na ProTips';

      PushNotification notificacao = new PushNotification();
      notificacao.title = titulo;
      notificacao.body = texto;
      notificacao.timestamp = DataHora.now();
      notificacao.remetente = user.dados.id;
      notificacao.action = NotificationActions.SOLICITACAO_ACEITA_TIPSTER;
      notificacao.topic = NotificationTopics.solicitacaoTipsterAceita(destino.dados.id);
      await notificacao.enviarTopic();
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoTipsterAceita', e);
      return false;
    }
  }

  Future<bool> _sendSolicitacaoTipster(UserPro destino) async {
    try {
      // await destino.validarTokens();
      // for (String token in destino.tokens.keys) {
      //   String titulo = MyTexts.SOLICITACAO_TIPSTER;
      //   String texto = user.dados.nome + ' | ' + user.dados.tipname;
      //
      //   PushNotification notificacao = new PushNotification();
      //   notificacao.title = titulo;
      //   notificacao.body = texto;
      //   notificacao.timestamp = DataHora.now();
      //   notificacao.remetente = user.dados.id;
      //   notificacao.action = NotificationActions.SOLICITACAO_TIPSTER;
      //   notificacao.token = token;
      //   notificacao.enviar();
      // }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoTipster', e);
      return false;
    }
  }
  Future<bool> sendSolicitacaoTipsterTopic(UserPro destino) async {
    try {
      String titulo = MyTexts.SOLICITACAO_TIPSTER;
      String texto = user.dados.nome + ' | ' + user.dados.tipname;

      PushNotification notificacao = new PushNotification();
      notificacao.title = titulo;
      notificacao.body = texto;
      notificacao.timestamp = DataHora.now();
      notificacao.remetente = user.dados.id;
      notificacao.action = NotificationActions.SOLICITACAO_TIPSTER;
      notificacao.topic = NotificationTopics.solicitacaoTipsterAdmin;
      await notificacao.enviarTopic();
      return true;
    } catch (e) {
      Log.e(TAG, 'sendSolicitacaoTipster', e);
      return false;
    }
  }

  Future<bool> _sendDenuncia(Denuncia item) async {
    try {
      UserPro destino = await getUsers.get(item.idUser);
      if (destino == null)
        return false;
      // await destino.validarTokens();
      Log.d(TAG, 'sendDenuncia', 'destino', destino.dados.nome);
      // for (String token in destino.tokens.keys) {
      //   String body = MyStrings.MOTIVO + ': ' + item.texto;
      //
      //   PushNotification notificacao = PushNotification();
      //   notificacao.remetente = user.dados.id;
      //   notificacao.title = MyStrings.ATENCAO.toUpperCase() + ' ' + MyTexts.VC_FOI_DENUNCIADO;
      //   notificacao.body = body;
      //   notificacao.timestamp = item.data;
      //   notificacao.token = token;
      //   notificacao.action = NotificationActions.DENUNCIA;
      //   notificacao.enviar();
      // }
      return true;
    } catch(e) {
      Log.e(TAG, 'sendDenuncia', e);
      return false;
    }
  }
  Future<bool> sendDenunciaTopic(Denuncia item) async {
    try {
      String body = MyStrings.MOTIVO + ': ' + item.texto;

      PushNotification notificacao = PushNotification();
      notificacao.remetente = user.dados.id;
      notificacao.title = MyStrings.ATENCAO.toUpperCase() + ' ' + MyTexts.VC_FOI_DENUNCIADO;
      notificacao.body = body;
      notificacao.timestamp = item.data;
      notificacao.topic = NotificationTopics.denuncia(item.idUser);
      notificacao.action = NotificationActions.DENUNCIA;
      await notificacao.enviarTopic();
      return true;
    } catch(e) {
      Log.e(TAG, 'sendDenuncia', e);
      return false;
    }
  }

  Future<bool> _sendPagamento(UserPro destino) async {
    try {
      // await destino.validarTokens();
      // for (String token in destino.tokens.keys) {
      //   String titulo = MyTexts.PAGAMENTO_REALIZADO;
      //   String texto = user.dados.nome + ' | ' + user.dados.tipname;
      //
      //   PushNotification notificacao = new PushNotification();
      //   notificacao.title = titulo;
      //   notificacao.body = texto;
      //   notificacao.timestamp = DataHora.now();
      //   notificacao.remetente = user.dados.id;
      //   notificacao.action = NotificationActions.PAGAMENTO_REALIZADO;
      //   notificacao.token = token;
      //   notificacao.enviar();
      // }
      return true;
    } catch (e) {
      Log.e(TAG, 'sendPagamento', e);
      return false;
    }
  }
  Future<bool> sendPagamentoTopic(UserPro destino) async {
    try {
      String titulo = MyTexts.PAGAMENTO_REALIZADO;
      String texto = user.dados.nome + ' | ' + user.dados.tipname;

      PushNotification notificacao = new PushNotification();
      notificacao.title = titulo;
      notificacao.body = texto;
      notificacao.timestamp = DataHora.now();
      notificacao.remetente = user.dados.id;
      notificacao.action = NotificationActions.PAGAMENTO_REALIZADO;
      notificacao.topic = NotificationTopics.pagamentoRecebido(destino.dados.id);
      await notificacao.enviarTopic();
      return true;
    } catch (e) {
      Log.e(TAG, 'sendPagamento', e);
      return false;
    }
  }

  Future<bool> sendDepuracaoTopic() async {
    try {
      String titulo = 'Notificação de Testes';
      String texto = 'Modo de Depuração';

      PushNotification notificacao = new PushNotification();
      notificacao.title = titulo;
      notificacao.body = texto;
      notificacao.timestamp = DataHora.now();
      notificacao.remetente = user.dados.id;
      notificacao.action = NotificationActions.DEPURACAO_TESTE;
      notificacao.topic = NotificationTopics.depuracao;
      await notificacao.enviarTopic();
      return true;
    } catch (e) {
      Log.e(TAG, 'sendDepuracaoTopic', e);
      return false;
    }
  }

  //endregion

  //region Token

  /*Token _createToken(String token) {
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
  }*/

  //endregion

  Future _onReceiveMessage(message) async {
    PushNotification notification = PushNotification();
    String pagantes = message['data']['pagantes'];
    notification.action = message['data']['action'];
    notification.remetente = message['data']['remetente'];
    notification.title = message['notification']['title'];

    if (pagantes == null || pagantes.isEmpty || pagantes.contains(meuID)) {
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
        Log.d(TAG, '_onReceiveMessage', 'FILIALDO_REMOVIDO');
        return;
    }

    /// Faz essa verificação no case de o usuário limpar os dados do app
    try {
      var pref = await SharedPreferences.getInstance();
      bool isLogado = pref.getBool(PreferencesKey.USER_LOGADO) ?? false;
      if (!isLogado) {
        _removerAllTopics();
        Log.d(TAG, '_onReceiveMessage', 'DesLogado');
        return;
      }
    } catch(e) {
      Log.e(TAG, '_onReceiveMessage', 'check is Logado', e);
    }


    /// O SO do emulador trava ao mostrar a notificação, então só mstro va versão Release
    if (Aplication.isRelease)
      _showNotification(notification);
    Log.d(TAG, 'fcm', 'onMessage', message);
  }

  Future _onSelectNotification (String payload) async {
    if (payload != null && context != null) {
      Log.d(TAG, 'onSelectNotification', payload);
      switch(payload) {
        case NotificationActions.NOVO_TIP:
          break;
        case NotificationActions.ATUALIZACAO:
          Import.openUrl(MyResources.playStoryLink, context);
          break;
        case NotificationActions.SOLICITACAO_TIPSTER:
          Navigate.to(context, GerenciaPage());
          break;
      }
    }
  }

  _showNotification(PushNotification notification) async {
    try {
      var android = AndroidNotificationDetails('ProtipsChannelId', 'ProtipsChannelName', 'ProtipsChannelDescription', icon: 'ic_notification');
      var iOS = IOSNotificationDetails();
      var platform = NotificationDetails(android, iOS);
      await flutterLocalNotificationsPlugin.show(0, notification.title, notification.body, platform, payload: notification.action);
    } catch (e) {
      Log.e(TAG, 'showNotification', e);
    }
  }

  Future _atualizarTopics() async {
    if (FirebasePro.isAdmin) {
      await _fcm.subscribeToTopic(NotificationTopics.solicitacaoTipsterAdmin);
      await _fcm.subscribeToTopic(NotificationTopics.depuracao);
    } else {
      await _fcm.unsubscribeFromTopic(NotificationTopics.solicitacaoTipsterAdmin);
      await _fcm.unsubscribeFromTopic(NotificationTopics.depuracao);
    }

    await _fcm.subscribeToTopic(NotificationTopics.solicitacaoTipsterAceita(meuID));
    await _fcm.subscribeToTopic(NotificationTopics.solicitacaoFiliado(meuID));
    await _fcm.subscribeToTopic(NotificationTopics.solicitacaoAceita(meuID));
    await _fcm.subscribeToTopic(NotificationTopics.pagamentoRecebido(meuID));
    await _fcm.subscribeToTopic(NotificationTopics.denuncia(meuID));

    for (String key in user.seguindo.keys) {
      UserPro user = await getUsers.get(key);
      if (user == null || !user.filiados.containsKey(meuID)) {
        await _fcm.unsubscribeFromTopic(NotificationTopics.receberTips(key));
      } else {
        await _fcm.subscribeToTopic(NotificationTopics.receberTips(key));
      }
    }

    Log.d(TAG, 'atualizarTopics', 'OK');
  }

  Future _removerAllTopics() async {
    for (String key in user.seguindo.keys)
      await _fcm.unsubscribeFromTopic(NotificationTopics.receberTips(key));
    await _fcm.unsubscribeFromTopic(NotificationTopics.solicitacaoTipsterAdmin);
    await _fcm.unsubscribeFromTopic(NotificationTopics.solicitacaoTipsterAceita(meuID));
    await _fcm.unsubscribeFromTopic(NotificationTopics.solicitacaoFiliado(meuID));
    await _fcm.unsubscribeFromTopic(NotificationTopics.solicitacaoAceita(meuID));
    await _fcm.unsubscribeFromTopic(NotificationTopics.pagamentoRecebido(meuID));
    await _fcm.unsubscribeFromTopic(NotificationTopics.denuncia(meuID));
    await _fcm.unsubscribeFromTopic(NotificationTopics.depuracao);
  }

}
