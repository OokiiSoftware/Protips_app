import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info/package_info.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/denuncia.dart';
import 'package:protips/model/error.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/resources.dart';
import 'file:///C:/Users/jhona/Documents/GitHub/protips_app/lib/auxiliar/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'notification_manager.dart';

class Aplication {
  static const String TAG = 'Aplication';

  static int appVersionInDatabase = 0;
  static PackageInfo packageInfo;
  static SharedPreferences sharedPref;

  static Future<void> init(BuildContext context) async {
    Log.setToast = context;
    packageInfo = await PackageInfo.fromPlatform();
    Device._deviceData = await DeviceInfo.getDeviceInfo();
    sharedPref = await SharedPreferences.getInstance();
    getFirebase.initNotificationManager(context);
  }

  static Future<String> buscarAtualizacao() async {
    Log.d(TAG, 'buscarAtualizacao', 'Iniciando');
    int _value = await getFirebase.databaseReference
        .child(FirebaseChild.VERSAO)
        .once()
        .then((value) => value.value)
        .catchError((e) {
      Log.e(TAG, 'buscarAtualizacao', e);
      return -1;
    });
    String url;

    Log.d(TAG, 'buscarAtualizacao', 'Web Version', _value, 'Local Version', packageInfo.buildNumber);
    appVersionInDatabase = _value;
    int appVersion = int.parse(packageInfo.buildNumber);

    if (_value > appVersion) {
      url = 'https://play.google.com/store/apps/details?id=com.ookiisoftware.protips';
//      String folder = Platform.isAndroid ? FirebaseChild.APK : FirebaseChild.IOS;
//      String ext = Platform.isAndroid ? '.apk' : '';
//      String fileName = MyStrings.APP_NAME + '_' + _value.toString() + ext;
//      Log.d(TAG, 'buscarAtualizacao', 'fileName', fileName);
//      try {
//        url = await getFirebase.storage()
//            .child(FirebaseChild.APP)
//            .child(folder)
//            .child(fileName)
//            .getDownloadURL();
//      } catch(e) {
//        Log.e(TAG, 'buscarAtualizacao', e);
//      }
    }

    return url;
  }

  static bool get isRelease => bool.fromEnvironment('dart.vm.product');
}

class Device {
  static Map<String, dynamic> _deviceData;

  static String get name =>
      (Platform.isAndroid ? _deviceData['model'] : _deviceData['name']) ?? '';

  static Future<bool> checkGoogleServices([bool showDialog = false]) async {
    GooglePlayServicesAvailability playStoreAvailability;
    try {
      playStoreAvailability = await GoogleApiAvailability.instance
          .checkGooglePlayServicesAvailability(showDialog);
    } on PlatformException {
      playStoreAvailability = GooglePlayServicesAvailability.unknown;
    }
    return playStoreAvailability.value == GooglePlayServicesAvailability.success.value;
  }
}

class Navigate {
  static dynamic to(BuildContext context, StatefulWidget widget) async {
    return await Navigator.of(context).push(MaterialPageRoute(builder: (context) => widget));
  }
  static toReplacement(BuildContext context, StatefulWidget widget) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => widget));
  }
}

class Import {
  static const String TAG = 'Import';

  static List<DropdownMenuItem<String>> getDropDownMenuItems(List list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String value in list) {
      items.add(new DropdownMenuItem(
          value: value,
          child: new Text(value)
      ));
    }
    return items;
  }

  static void openUrl(String url, [BuildContext context]) async {
    try {
      if (await canLaunch(url))
        await launch(url);
      else
        throw Exception(MyErros.ABRIR_LINK);
    } catch(e) {
      if (context != null)
        Log.toast(MyErros.ABRIR_LINK, isError: true);
      Log.e(TAG, 'openUrl', e);
    }
  }

  static void openEmail(String email, [BuildContext context]) async {
    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: '$email',
        queryParameters: {
          'subject': 'Solicitação Tipster'
        }
    );
    try {
      if (await canLaunch(_emailLaunchUri.toString()))
        await launch(_emailLaunchUri.toString());
      else
        throw Exception(MyErros.ABRIR_EMAIL);
    } catch(e) {
      if (context != null)
        Log.toast(MyErros.ABRIR_EMAIL, isError: true);
      Log.e(TAG, 'openUrl', e);
    }
  }

  static void openWhatsApp(String numero, [BuildContext context]) async {
    try {
      numero = numero.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '').replaceAll('-', '');
      var whatsappUrl ="whatsapp://send?phone=55$numero";
      if (await canLaunch(whatsappUrl))
        await launch(Uri.encodeFull(whatsappUrl));
      else
        throw Exception(MyErros.ABRIR_WHATSAPP);
    } catch(e) {
      if (context != null)
        Log.toast(MyErros.ABRIR_WHATSAPP, isError: true);
      Log.e(TAG, 'openUrl', e);
    }
  }
}

class EventListener {
  static onPostSend(Post item) async {
    getPosts.add(item);
    for (String key in getFirebase.user.seguidores.keys) {
      User user = await getUsers.get(key);
      if (user != null)
        getFirebase.notificationManager.sendPost(item, user);
    }
    Log.toast('TIP Postado');
  }

  static onPostSendFail() async {
    Log.toast('Ocorreu um erro ao enviar sua TIP');
  }

  static onPostDelete(Post item) {
    getFirebase.user.postes.remove(item.id);
    Log.toast('TIP Excluido');
  }
}

enum FirebaseInitResult {
  ok, userNull, fUserNull, none
}

// ignore: camel_case_types
class getFirebase {
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
          name: MyStrings.APP_NAME,
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
      var snapshot = await getFirebase.databaseReference
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

  static void setUltinoEmail(String email) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(SharedPreferencesKey.EMAIL, email);
  }

  static Future<String> getUltinoEmail() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(SharedPreferencesKey.EMAIL) ?? '';
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

class OfflineData {
  static const String TAG = 'offlineData';
  static String appTempName =  MyStrings.APP_NAME + '.apk';
  static String appTempPath;
  static Dio _dio = Dio();

  static Future<void> readDirectorys() async {
    String directory = await OfflineData._getDirectoryPath();
    getUsers.localPath = '$directory/${FirebaseChild.USUARIO}';
    getPosts.localPath = '$directory/${FirebaseChild.POSTES}';
    appTempPath = '$directory/${FirebaseChild.APP}';
  }

  static Future<bool> saveOfflineData() async {
    try {
      File _pathUsers = _getUserFile(await _getDirectoryPath());
      String data = jsonEncode(getUsers.data);
      await _pathUsers.writeAsString(data);
      Log.d(TAG, 'saveOfflineData', 'OK', _pathUsers.path);
      return true;
    } catch(e) {
      Log.e(TAG, 'saveOfflineData', e);
      return false;
    }
  }
  static Future<bool> readOfflineData() async {
    try {
      File _pathUsers = _getUserFile(await _getDirectoryPath());
      if (await _pathUsers.exists()) {
        String data = await _pathUsers.readAsString();
        getUsers.dd(jsonDecode(data));
      }
      Log.d(TAG, 'readOfflineData', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'readOfflineData', e);
      return false;
    }
  }
  static Future<bool> deleteOfflineData() async {
    try {
      File file = _getUserFile(getUsers.localPath);
      if (file.existsSync())
        await file.delete();
      Log.d(TAG, 'deleteOfflineData', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'deleteOfflineData', e);
      return false;
    }
  }
  static Future<bool> deletefile(String path, String fileName) async {
    try {
      File file = File('$path/$fileName');
      if (file.existsSync())
        await file.delete();
      Log.d(TAG, 'deletefile', 'OK', fileName);
      return true;
    } catch(e) {
      Log.e(TAG, 'deletefile', fileName, e);
      return false;
    }
  }

  static Future<String> _getDirectoryPath() async {
    Directory directory = await _getDirectory();
    return directory.path;
  }

  static Future<Directory> _getDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  static File _getUserFile(String path) {
    String s = '$path/' + FirebaseChild.USUARIO + '.json';
    return File(s);
  }

  static Future<void> createPerfilDirectory() async {
    Directory directory = await _getDirectory();
    Directory dir = Directory('${directory.path}/${FirebaseChild.USUARIO}');
    if (!await dir.exists()) {
      await dir.create();
    }
  }
  static Future<void> createPostDirectory() async {
    Directory directory = await _getDirectory();
    Directory dir = Directory('${directory.path}/${FirebaseChild.POSTES}');
    if (!dir.existsSync())
      await dir.create();
  }

  static Future<bool> downloadFile(String url, String path, String fileName, {bool override = false, ProgressCallback onProgress, CancelToken cancelToken}) async {
    if (url == null || url.isEmpty)
      return true;

    try {
      String _path = '$path/$fileName';
      String _pathTemp = '$path/temp';
      File file = File(_path);
      if (await file.exists()) {
        if (override) {
          await file.delete();
        } else {
          return true;
        }
      }
      Log.d(TAG, 'downloadFile', 'Iniciando');
      await _dio.download(url, _pathTemp, onReceiveProgress: onProgress, deleteOnError: true, cancelToken: cancelToken);
      File file2 = File(_pathTemp);
      if(await file2.exists())
        file2.rename(_path);
      Log.d(TAG, 'downloadFile', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'downloadFile', e, url);
      return false;
    }
  }

  static Future<void> saveData(String data) async {
    var dir = await _getDirectoryPath();
    var fileName = DataHora.now() + '.txt';
    File file = File('$dir/$fileName');
    await file.writeAsString(data);
    Log.d(TAG, 'saveData', 'OK', fileName);
  }
}

// ignore: camel_case_types
class getUsers {
  static const String TAG = 'getUsers';
  static String localPath;

  static Map<String, User> _data = new Map();

  static Map<String, User> get data => _data;
  static Future<User> get(String key) async {
    if (_data[key] == null) {
      var item = await baixarUser(key);
      if (item != null)
        add(item);
    }
    return _data[key];
  }

  static void add(User item) {
    _data[item.dados.id] = item;
    if(item.dados.id == getFirebase.user.dados.id)
      getFirebase.setUser(item);
  }
  static void addAll(Map<String, User> items) {
    _data.addAll(items);
  }
  static void remove(String key) {
    _data.remove(key);
  }

  static void reset() {
    _data.clear();
  }

  static Future<void> baixar() async {
    try {
      var snapshot = await getFirebase.databaseReference.child(FirebaseChild.USUARIO).once();
      Map<dynamic, dynamic> map = snapshot.value;
      dd(map);
      Log.d(TAG, 'baixa', 'OK');
    } catch (e) {
      Log.e(TAG, 'baixa', e);
    }
    saveFotosPerfilLocal();
  }

  static Future<User> baixarUser(String uid) async {
    try {
      var snapshot = await getFirebase.databaseReference
          .child(FirebaseChild.USUARIO).child(uid).once();
      if (snapshot.value == null)
        return null;
      return User.fromJson(snapshot.value);
    } catch (e) {
      Log.e(TAG, 'baixarUser', e);
      return null;
    }
  }

  static void dd(Map<dynamic, dynamic> map) {
    if (map == null) return;

    reset();
    getPosts.reset();
    getTipster.reset();

    for (String key in map.keys) {
      try {
        User item = User.fromJson(map[key]);
        bool addTipster = item.dados.isTipster && !item.dados.isBloqueado && !item.solicitacaoEmAndamento();

        if (addTipster) {
          //Adiciona os Posts de quem eu sigo e meu Postes
          if (getFirebase.user.seguindo.containsKey(key) || key == getFirebase.fUser.uid) {
            getPosts.addAll(item.postes.values.toList());
          } else {
            // for (Post post in item.postes.values) {
            //   if (post.isPublico)
            //     getPosts.add(post);
            // }
            getPosts.addAll(item.postes.values.where((e) => e.isPublico).toList());
          }
          getTipster.add(item);
        }
        add(item);
      } catch(e) {
        Log.e(TAG, 'dd', e);
        continue;
      }
    }
  }

  static Future<void> saveFotosPerfilLocal() async {
    //Salva minha foto
    await OfflineData.downloadFile(getFirebase.user.dados.foto, localPath, getFirebase.user.dados.fotoLocal, override: true);
    //Salva foto dos tipsters
    for (User item in getTipster.data) {
      try {
        await OfflineData.downloadFile(item.dados.foto, localPath, item.dados.fotoLocal, override: true);
      } catch(e) {
        Log.e(TAG, 'saveLocalFotos', e);
        continue;
      }
    }
    Log.d(TAG, 'saveLocalFotos', 'OK');
  }

}

// ignore: camel_case_types
class getTipster {
  static const String TAG = 'getUsers';
  static Map<String, User> _data = new Map();

  static List<User> get data => _data.values.toList();
  static User get(String key) => _data[key];

  static void add(User item) {
    _data[item.dados.id] = item;
  }
  static void addAll(Map<String, User> items) {
    _data.addAll(items);
  }
  static void remove(String key) {
    _data.remove(key);
  }

  static void reset() {
    _data.clear();
  }

}

// Solicitações para ser um Tipster
// ignore: camel_case_types
class getSolicitacoes {
  static Map<String, User> _data = new Map();

  static List<User> get data => _data.values.toList();

  static void remove(String key) {
    _data.remove(key);
  }

  static void add(User item) {
    _data[item.dados.id] = item;
  }

  static User get(String key) => _data[key];

  static void reset() {
    _data.clear();
  }
}

//Lista de erros que ocorre nos dispositivos dos usuários
// ignore: camel_case_types
class getErros {
  static const String TAG = 'getErros';
  static Map<String, Error> _data = new Map();

  static List<Error> get data => _data.values.toList();

  static void remove(String key) {
    _data.remove(key);
  }

  static void add(Error item) {
    _data[item.data] = item;
  }

  static Error get(String key) => _data[key];

  static Future<void> baixar() async {
    Map<dynamic, dynamic> result = await getFirebase.databaseReference.child(FirebaseChild.LOGS)
        .once().then((value) => value.value).catchError((ex) => null);
    if (result != null) {
      reset();
      for (dynamic item in result.values) {
        try {
          Error e = Error.fromJson(item);
          var e2 = _findSimilar(e);
          if(e2 != null)
            e2.similares.add(e.data);
          else
            add(e);
        } catch(e) {
          Log.d(TAG, 'ERROR: baixar', e);
          continue;
        }
      }
    }
  }

  static Error _findSimilar(Error e) {
    try {
      return _data.values.firstWhere((x) => x.metodo == e.metodo && x.classe == e.classe && x.valor == e.valor);
    } catch(e) {
      return null;
    }
  }

  static void reset() {
    _data.clear();
  }
}

//Lista de Denuncias feitas por usuários
// ignore: camel_case_types
class getDenuncias {
  static const String TAG = 'getErros';
  static Map<String, Denuncia> _data = new Map();

  static List<Denuncia> get data => _data.values.toList();

  static void remove(String key) {
    _data.remove(key);
  }

  static void add(Denuncia item) {
    _data[item.data] = item;
  }

  static Denuncia get(String key) => _data[key];

  static Future<void> baixar() async {
    Map<dynamic, dynamic> result = await getFirebase.databaseReference.child(FirebaseChild.DENUNCIAS)
        .once().then((value) => value.value).catchError((ex) => null);
    if (result != null) {
      reset();
      for (dynamic item in result.values) {
        try {
          Denuncia e = Denuncia.fromJson(item);
          var e2 = _findSimilar(e);
          if(e2 != null)
            e2.quantidade++;
          else
            add(e);
        } catch(e) {
          Log.d(TAG, 'ERROR: baixar', e);
          continue;
        }
      }
    }
  }

  static Denuncia _findSimilar(Denuncia e) {
    try {
      return _data.values.firstWhere((x) => x.texto == e.texto && x.assunto == e.assunto && (x.idUser == e.idUser || x.itemKey == e.itemKey));
    } catch(e) {
      return null;
    }
  }

  static void reset() {
    _data.clear();
  }
}

// ignore: camel_case_types
class getPosts {
  static const String TAG = 'getPosts';
  static String localPath;

  static Map<String, Post> _data = new Map();

  static Future<List<Post>> data(String data) async {
    var list = _data.values.where((e) => e.data.contains(data)).toList()..sort((a, b) => b.data.compareTo(a.data));
    var result = List<Post>();
    for (var item in list) {
      if (item.isMyPost)
        result.add(item);
      else{
        var pagamento = await loadPagamento(item.idTipster, data.substring(0, data.length-3));
        if (pagamento != null) result.add(item);
      }
    }
    return result;
  }
  static Post get(String key) => _data[key];

  static Future<Post> baixar(String postKey, String userId) async {
    if (_data[postKey] == null) {
      var result = await getFirebase.databaseReference.child(FirebaseChild.USUARIO)
      .child(userId).child(FirebaseChild.POSTES).child(postKey).once().then((value) => value.value);
      if (result != null) {
        Post item = Post.fromJson(result);
        add(item);
        return item;
      }
      return null;
    } else {
      return _data[postKey];
    }
  }

  static void add(Post item) {
    _data[item.id] = item;
  }
  static void addAll(List<Post> items) {
    for (var item in items)
      add(item);
  }
  static void remove(String key) {
    _data.remove(key);
  }
  static void removeAll(String userId) {
    _data.removeWhere((key, value) => value.idTipster == userId);
  }

  static void reset() {
    _data.clear();
  }

  static Future<void> saveFotosLocal() async {
    await OfflineData.createPostDirectory();

    for (Post item in _data.values) {
      try {
        await OfflineData.downloadFile(item.foto, localPath, item.fotoLocal);
      } catch(e) {
        Log.e(TAG, 'saveLocalFotos', e);
        continue;
      }
    }
    Log.d(TAG, 'saveLocalFotos', 'OK');
  }

  static Future<String> loadPagamento(String tipsterID, String data) async {
    var snapshot = await getFirebase.databaseReference
        .child(FirebaseChild.PAGAMENTOS)
        .child(tipsterID)
        .child(data)
        .child(getFirebase.fUser.uid)
        .once();

    return snapshot.value;
  }
}

class Log {
  static FlutterToast _toast;
  static set setToast (BuildContext context) {
    _toast = FlutterToast(context);
  }

  static void toast(String texto, {bool isError = false}) {
    var tint = isError ? MyTheme.textColor() : MyTheme.textColorInvert();
    Widget body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: isError ? Colors.red : MyTheme.accent(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isError ? Icons.clear : Icons.check, color: tint),
          SizedBox(width: 12.0),
          Text(texto, style: TextStyle(color: tint)),
        ],
      ),
    );
    _toast.showToast(child: body, gravity: ToastGravity.BOTTOM, toastDuration: Duration(seconds: isError ? 4 : 2));
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

//  static _saveLog(String data) {
//    try {
//      OfflineData.saveData(data);
//    } catch(e) {
//      //Todo \(ºvº)/
//    }
//  }
  
  static _sendError(String tag, String metodo, String value) {
    String id = getFirebase.fUser?.uid ?? 'deslogado';

    Error e = Error();
    e.data = DataHora.now();
    e.classe = tag;
    e.metodo = metodo;
    e.valor = value;
    e.userId = id;
    e.salvar();

    try {
//      String data = tag + value;
//      getFirebase.databaseReference()
//          .child(FirebaseChild.LOGS)
//          .child(tag)
//          .child(id)
//          .child(Data.now())
//          .set(data);
    } catch(e) {
      //Todo \(ºvº)/
    }
  }
}