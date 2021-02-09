import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:protips/auxiliar/criptografia.dart';
import 'package:protips/auxiliar/preferences.dart';
import 'package:protips/model/user_pro.dart';
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

  static const String FILIADOS_PENDENTES = "filiadosPendentes";
  static const String TELEFONE = "telefone";

  static const String TAGS = 'tags';
  static const String LOGS = 'logs';
  static const String PAGAMENTOS = 'pagamentos';
  static const String ATIVOS = 'ativos';
  static const String DENUNCIAS = 'denuncias';
  static const String COMPRAS_IDS = 'comprasIDs';

  static const String SOLICITACAO_NOVO_TIPSTER = "solicitacao_novo_tipster";
  static const String TIPSTERS = "tipsters";
  static const String FILIADOS = "filiados";
  static const String SEGUINDO = "seguindo";
  static const String SEGUIDORES = "seguidores";
  static const String BOM = "bom";
  static const String RUIM = "ruim";
  static const String ESPORTES = "esportes";
  static const String LINHAS = "linhas";

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

class FirebasePro {
  //region Variaveis
  static const String TAG = 'FirebasePro';

  // static FirebaseApp _firebaseApp;
  static FirebaseStorage _storage = FirebaseStorage.instance;
  static DatabaseReference _database = FirebaseDatabase.instance.reference();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();
  // static NotificationManager _fcm;

  static UserPro _userPro;
  static bool _isAdmin;
  static Map<String, bool> _admins = Map();// <id, isEnabled>
  //endregion

  //region Firebase App

  static Reference get storage => _storage.ref();

  static FirebaseAuth get auth => _auth;

  static DatabaseReference get database => _database;

  static Future<bool> googleAuth() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);

    Log.d(TAG, 'signed in', user.displayName);
    return true;
  }

  //endregion

  //region Metodos

  static Future<FirebaseInitResult> init() async {
    Log.d(TAG, 'init', 'Iniciando');

    const firebaseUser_Null = 'firebaseUser Null';
    try {

      if (Firebase.apps.isEmpty) {
        String decript(String value) => Cript.decript(_firebaseData[value]);
        String encript(String value) => Cript.encript(_firebaseData[value]);

        // Log.d(TAG, 'appId', encript('appId'));
        // Log.d(TAG, 'projectId', encript('projectId'));
        // Log.d(TAG, 'messagingSenderId', encript('messagingSenderId'));
        // Log.d(TAG, 'apiKey', encript('apiKey'));
        // Log.d(TAG, 'storageBucket', encript('storageBucket'));
        // Log.d(TAG, 'databaseURL', encript('databaseURL'));

        await Firebase.initializeApp(
            name: MyResources.APP_NAME,
            options: FirebaseOptions(
              appId: decript('appId'),
              messagingSenderId: decript('messagingSenderId'),
              storageBucket: decript('storageBucket'),
              databaseURL: decript('databaseURL'),
              projectId: decript('projectId'),
              apiKey: decript('apiKey'),
            )
        ).catchError((e) {
          Log.e2(TAG, 'init', 'initializeApp', e);
        });
      }


      if (user == null || !user.emailVerified)
        throw new Exception(firebaseUser_Null);

      _checkAdmin();
      Log.d(TAG, 'init', 'OK');
      return FirebaseInitResult.ok;
    } catch (e) {
      if (e.toString().contains(firebaseUser_Null)) {
        Log.e2(TAG, 'init', e);
        return FirebaseInitResult.fUserNull;
      } else
        Log.e(TAG, 'init', e);
      return FirebaseInitResult.none;
    }
  }

  static void initAdmin() {
    getSolicitacoes.observe();
    getDenuncias.baixar();
    getErros.baixar();
  }

  static Future _checkAdmin() async {
    try {
      var snapshot = await FirebasePro.database.child(FirebaseChild.ADMINISTRADORES).once();
      Map<dynamic, dynamic> map = snapshot.value;
      for (dynamic d in map.keys) {
        _admins[d] = map[d];
      }
      if (_admins.containsKey(user.uid))
        _isAdmin = map[user.uid];
      if (isAdmin)
        initAdmin();
    } catch (e) {
      Log.e(TAG, '_checkAdmin', e);
    }
  }

  static void finalize() async {
    getPosts.reset();
    getTipster.reset();
    auth.signOut();
    _isAdmin = false;
    logado = false;
    _userPro = null;
    await NotificationManager.instance?.finalize();
    NotificationManager.instance = null;
  }

  static Map<String, String> get _firebaseData => {
    'appId': Platform.isAndroid ? 'ASH1IT☡iUWUOEZUMdQC0LFR43RZofRZM3vSRCf3HLLKUYiRFU41WPLNS4AZRXXG4dJMiOM7iHKFQxGWIPMvhWkvJU0xRTHEiVI7HT7iUzBHxxCVSo0M0sZClmZ[dEVmIZCz0K7AVXlCNT|OJxiWVFvLCNk0SZKvQWoiHUx☡TMBlUHX' :'ASH1IT☡iUWUOEZUMdQC0LFR43RZofRZM3vSRCf3HLLKUYiRFU41WPLNS4AZRXlWi4J[z4F☡dJMhYVNJxzWKP4V3OMDv1CxmGKAISJC|1U4|WKAiUNVkdHhsZClBFZWxhCdvUElGRi4MRDQ0RVUkYSPPKNB3RVDIdDWB',
    'apiKey': 'mHZhESZlBMfzGvmHFWQANxlFG3lGVXBGNf1UWVkYJKXiVUZsvHZWOhH0xZCFfvRPkVTxxZxYMVZE1ZTIQV☡zNRksNUO4JFd☡KCJ4fJKUzXVGkPR[PXKUK7PFD[7BRKh3FUAdDNO☡DBXRSsmFKmiDU☡QZJSivZf',
    'databaseURL': '|FOlNWzAG3BKGooDDEYGKZo|FZImRmoNSSs7SWDQxFTUOiUMiAMkoG[iiV|iKOlUfXTMVf1ZUmzCCSiPMv☡KhiWZSl3RUhEMv3KMX',
    'storageBucket': 'AUW4lZifGSiERdhGdYGKZo0ZFW03MHR☡fFTIfV4PTJE☡JDBBKhvM1EMilWioJ[lXTMVfiNK☡1FZh☡VMCfmSkBRNdYFkXJkdHRABTTTfvJVv',
    'messagingSenderId': 'mHZhIVI☡W4sJUJ4INIsDFAITQoJdYUDVXfFN1dDEQJUTlOG4QGHHflHDMBIWDMvhFC3|RExDVUklHFl1FHSEPJo|GolHNZBEMvkSSCs☡KDH☡lS|mFFfXJKsBDTovWGUmzHLdRCvLUDLmDhoKoPV1☡J1iRxkZDVmESWZAXUDU30TJKsOVkmFN0iCCoxNm☡SRI4G0ERZDh0Z7YTziSNWLzUMo3NS4ATBQHWNIfKXmHJZiLV7zRv|KW77ZxINIOZQoNVMmIDKP0HokVRU|iTkfJovHZWOLZC[ozDO4KC4dCNQfKCVv1ZUmQHRT1☡VMCf☡DWVOlTZ[QOU4hKTO☡KW4EVTCYIMIQGBoUEAUHIiWFivW7PRmPFYiTXIG|3T☡3MZ0☡H[XATWS4IZF41WDUifGSTimUOOJ☡PG☡IDTKv4FRoXKMXOFhlWT3iW[TL3DGk0SDkXMJxiRmYWMZfhJ14JTolVKoXUv|KW7PHTsxCUNOiF7iH3☡D0XMo|CHU3YUMSPhC0fTWkiDSliV|iRGsOMX|UUTlQG[XoCElKBzNRkmZFM|1VD|3ZWELMJvOUGLfZ[|sUD0zDV13W3hSC|',
    'projectId': '|FOlNWzAG3BKGooDDEYGKZo|FZImRmoNSSs7SWDQxFTUO',
  };

  static bool get isAdmin => _isAdmin ?? false;

  static Future<List<UserPro>> get admins async {
    List<UserPro> list = [];
    for(String uid in _admins.keys)
      if (_admins[uid])
        list.add(await getUsers.get(uid));
    return list;
  }

  //endregion

  //region Usuario

  static UserPro get userPro {
    if (_userPro == null)
      _userPro = new UserPro();
    return _userPro;
  }

  static User get user => auth.currentUser;

  static String get ultinoEmail => Preferences.getString(PreferencesKey.EMAIL) ?? '';
  static set ultinoEmail(String email) => Preferences.setString(PreferencesKey.EMAIL, email);

  static set userPro(UserPro user) =>  _userPro = user;
  static set logado(bool value) => Preferences.setBool(PreferencesKey.USER_LOGADO, value);

  static observMyFirebaseData() {
    database
        .child(FirebaseChild.USUARIO)
        .child(user.uid)
        .onValue.listen((event) {
      try {
        UserPro user = UserPro.fromJson(event.snapshot.value);
        if (user != null) {
          user = user;
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
      _userPro = await UserPro.baixar(user.uid);
      if (_userPro == null)
        throw new Exception(user_Null);
      return true;
    }catch(e) {
      if (e.toString().contains(user_Null))
        Log.e2(TAG, 'atualizarOfflineUser', e);
      else
        Log.e(TAG, 'atualizarOfflineUser', e);
      return false;
    }
  }

  //endregion

}
