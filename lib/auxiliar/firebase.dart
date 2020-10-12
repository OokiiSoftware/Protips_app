import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/strings.dart';
import 'import.dart';
import 'log.dart';
import 'notification_manager.dart';

enum FirebaseInitResult {
  ok, userNull, fUserNull, none
}

class FirebaseChild {
  static const String IDENTIFICADOR = "identificadores";
  static const String USUARIO = "usuarios";
  static const String CONTATO = "contatos";
  static const String DADOS = "dados";
  static const String CONVERSAS = "conversas";

  static const String PERFIL = "perfil";
  static const String POSTES = "postes";
  static const String POSTES_PERFIL = "post_perfil";

  static const String SEGUIDORES_PENDENTES = "seguidoresPendentes";
  static const String TELEFONE = "telefone";

  static const String TAGS = 'tags';
  static const String LOGS = 'logs';
  static const String PAGAMENTOS = 'pagamentos';
  static const String DENUNCIAS = 'denuncias';
  static const String COMPRAS_IDS = 'comprasIDs';

  static const String SOLICITACAO_NOVO_TIPSTER = "solicitacao_novo_tipster";
  static const String SEGUIDORES = "seguidores";
  static const String SEGUINDO = "seguindo";
  static const String BOM = "bom";
  static const String RUIM = "ruim";
  static const String ESPORTES = "esportes";
  static const String LINHAS = "linhas";
  //Use LINHAS
//  @deprecated
//  static final String MERCADOS = "mercados";
//  static final String BLOQUEADO = "bloqueado";
  static const String IS_BLOQUEADO = "isBloqueado";
  static const String ADMINISTRADORES = "administradores";
  static const String VERSAO = "versao";
  static const String APP = "app";
  static const String APK = "apk";
  static const String IOS = "ios";
  static const String IS_TIPSTER = "isTipster";
  static const String TOKENS = "tokens";
  static const String MESSAGES = "messages";
  static const String NOTIFICACOES = "notificacoes";
  static const String NOTIFICATIONS = "notifications";
  static const String NOTIFICATIONS_TOPIC = "notificationTopic";
  static const String AUTO_COMPLETE = "auto_complete";
  static const String CAMPEONATOS = "campeonatos";

  static const String CARDS = 'cards';
}

class Firebase {
  //region Variaveis
  static const String TAG = 'getFirebase';

  static FirebaseApp _firebaseApp;
  static FirebaseUser _firebaseUser;
  static FirebaseStorage _storage = FirebaseStorage.instance;
  static DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static NotificationManager _fcm;
  static GoogleSignIn _googleSignIn = GoogleSignIn();
//  static Token _token;

  static User _user;
  static bool _isAdmin;
  static Map<String, bool> _admins = Map();// <id, isEnabled>
  //endregion

  //region Firebase App

  static Future<FirebaseApp> app() async{
    if (_firebaseApp == null) {
      var iosOptions = FirebaseOptions(
        googleAppID: '1:721419790842:ios:ac0829d013db5cad509c43',
        gcmSenderID: '',
        storageBucket: _dataUrl['storageBucket'],
        databaseURL: _dataUrl['databaseURL'],
      );
      var androidOptions = FirebaseOptions(
        googleAppID: '1:721419790842:android:84815debd1879d3d509c43',
        apiKey: 'AIzaSyClZ-JCdZwUKQqVamI3C6LwRVWBmEP3x2A',
        storageBucket: _dataUrl['storageBucket'],
        databaseURL: _dataUrl['databaseURL'],
      );

      _firebaseApp = await FirebaseApp.configure(
          name: MyResources.APP_NAME,
          options: Platform.isIOS ? iosOptions : androidOptions
      );
    }

    return _firebaseApp;
  }

  static StorageReference get storage => _storage.ref();

  static FirebaseAuth get auth => _auth;

  static DatabaseReference get databaseReference => _databaseReference;

  static Future<FirebaseUser> googleAuth() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  //endregion

  //region Metodos

  static Future<FirebaseInitResult> init() async {
    Log.d(TAG, 'init', 'Firebase Iniciando');

    const firebaseUser_Null = 'firebaseUser Null';
    try {
      await OfflineData.createPerfilDirectory();
      await OfflineData.createPostDirectory();
      await OfflineData.readDirectorys();
      await app();

      _firebaseUser = await _auth.currentUser();
      if (_firebaseUser == null)
        throw new Exception(firebaseUser_Null);

      _checkAdmin();
      Log.d(TAG, 'init', 'Firebase OK');
      return FirebaseInitResult.ok;
    } catch (e) {
      if (e.toString().contains(firebaseUser_Null)) {
        Log.e(TAG, 'init', e, false);
        return FirebaseInitResult.fUserNull;
      } else
        Log.e(TAG, 'init', e);
      return FirebaseInitResult.none;
    }
  }

  static void initAdmin() async {
    databaseReference.child(FirebaseChild.SOLICITACAO_NOVO_TIPSTER).onValue.listen((event) async {
      Map<dynamic, dynamic> map = event.snapshot.value;
      if (map != null)
        for(String key in map.keys) {
          var item = await getUsers.get(key);
          if (item != null)
            getSolicitacoes.add(item);
        }
    });

    getDenuncias.baixar();
    getErros.baixar();
  }

  static void _checkAdmin() async {
    try {
      var snapshot = await Firebase.databaseReference
          .child(FirebaseChild.ADMINISTRADORES)/*.child(fUser().uid)*/.once();
      Map<dynamic, dynamic> map = snapshot.value;
      for (dynamic d in map.keys) {
        _admins[d] = map[d];
      }
      if (_admins.containsKey(fUser.uid))
        _isAdmin = map[fUser.uid] ?? false;
      if (isAdmin)
        initAdmin();
    } catch (e) {
      Log.e(TAG, '_checkAdmin', e);
    }
  }

  static void initNotificationManager(BuildContext context) {
    _fcm = NotificationManager(context);
    _fcm.init();
  }

  static void finalize() async {
    _firebaseUser = null;
    _isAdmin = false;
//    _token = null;
    getTipster.reset();
    getPosts.reset();
    await _user.logout();
    _fcm = null;
    _user = null;
  }

  static Map get _dataUrl => {
    'databaseURL': 'https://protips-oki.firebaseio.com',
    'storageBucket': 'gs://protips-oki.appspot.com'
  };

//  static Token get token => _token;

  static bool get isAdmin => _isAdmin ?? false;

  static NotificationManager get notificationManager => _fcm;

  static Future<List<User>> get admins async {
    List<User> list = [];
    for(String uid in _admins.keys)
      if (_admins[uid])
        list.add(await getUsers.get(uid));
    return list;
  }

  //endregion

  //region Usuario

  static User get user {
    if (_user == null)
      _user = new User();
    return _user;
  }

  static FirebaseUser get fUser => _firebaseUser;

  static void setUltinoEmail(String email) {
    Aplication.sharedPref.setString(SharedPreferencesKey.EMAIL, email);
  }

  static String getUltinoEmail() {
    return Aplication.sharedPref.getString(SharedPreferencesKey.EMAIL) ?? '';
  }

  static void setUser(User user) {
    _user = user;
  }

  static observMyFirebaseData() {
    databaseReference
        .child(FirebaseChild.USUARIO)
        .child(fUser.uid)
        .onValue.listen((event) {
      try {
        User user = User.fromJson(event.snapshot.value);
        if (user != null) {
          setUser(user);
          OfflineData.saveOfflineData();
        }
      } catch(e) {
        Log.e(TAG, 'observMyFirebaseData', e);
      }
    });
  }

  static Future<bool> atualizarOfflineUser() async {
    const user_Null = 'user Null';
    try {
      _user = await getUsers.baixarUser(_firebaseUser.uid);
      if (_user == null)
        throw new Exception(user_Null);
      return true;
    }catch(e) {
      if (e.toString().contains(user_Null))
        Log.e(TAG, 'atualizarOfflineUser', e, false);
      else
        Log.e(TAG, 'atualizarOfflineUser', e);
      return false;
    }
  }

//endregion

}
