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
import 'package:protips/model/data.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/resources.dart';
import 'file:///C:/Users/jhona/Documents/GitHub/protips_app/lib/auxiliar/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'notification_manager.dart';

class Import {
  static const String TAG = 'Import';
  static const double APP_VERSION = 1.134;
  static Map<String, dynamic> _deviceData;

  static String getDeviceName() {
    return (Platform.isAndroid ? _deviceData['model'] : _deviceData['name']) ?? '';
  }

  static Future<void> readDeviceInfo() async {
    _deviceData = await DeviceInfo.getDeviceInfo();
  }

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

  static Future<void> showPopup(BuildContext context, PostPerfil item) async {
    showDialog(
        context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyTheme.transparentColor(),
          content: GestureDetector(
            child: Image.network(item.foto),
            onTapUp: (value) {
              Navigator.pop(context);
            },
          ),
        );
      }
    );
  }

  static Future<String> buscarAtualizacao() async {
    Log.d(TAG, 'buscarAtualizacao', 'Iniciando');
    return await getFirebase.databaseReference()
        .child(FirebaseChild.VERSAO)
        .once()
        .then((value) async {
          String url;
          double _value = value.value;
          Log.d(TAG, 'buscarAtualizacao', 'Versão', _value);
          if (_value > APP_VERSION) {
            String folder = Platform.isAndroid ? FirebaseChild.APK : FirebaseChild.IOS;
            String ext = Platform.isAndroid ? '.apk': '' ;
            String fileName = MyStrings.APP_NAME + '_' + _value.toString() + ext;
            Log.d(TAG, 'buscarAtualizacao', 'fileName', fileName);
            url = await getFirebase.storage()
                .child(FirebaseChild.APP)
                .child(folder)
                .child(fileName)
                .getDownloadURL();
          }
          Log.d(TAG, 'buscarAtualizacao', 'url', url ?? 'Null');
          return url;
    }).catchError((e) {
      Log.e(TAG, 'buscarAtualizacao', e);
      return null;
    });
  }

  static void openUrl(String url, [BuildContext context]) async {
    try {
      if (await canLaunch(url))
        await launch(url);
      else
        throw Exception(MyErros.ABRIR_LINK);
    } catch(e) {
      if (context != null)
        Log.toast(context, MyErros.ABRIR_LINK, isError: true);
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
        Log.toast(context, MyErros.ABRIR_EMAIL, isError: true);
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
        Log.toast(context, MyErros.ABRIR_WHATSAPP, isError: true);
      Log.e(TAG, 'openUrl', e);
    }
  }
}

class Cript {
  static String encript(String value) {
//    return md5.convert(utf8.encode(value)).toString();
    return value;
  }
  static String dencript(String value) {
    return value;
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
  //endregion

  //region Firebase App

  static Future<FirebaseApp> app() async{
    if (_firebaseApp == null) {
      var iosOptions = FirebaseOptions(
        googleAppID: '1:721419790842:ios:ac0829d013db5cad509c43',
        gcmSenderID: '',
        storageBucket: map()['storageBucket'],
        databaseURL: map()['databaseURL'],
      );
      var androidOptions = FirebaseOptions(
        googleAppID: '1:721419790842:android:84815debd1879d3d509c43',
        apiKey: 'AIzaSyClZ-JCdZwUKQqVamI3C6LwRVWBmEP3x2A',
        storageBucket: map()['storageBucket'],
        databaseURL: map()['databaseURL'],
      );

      _firebaseApp = await FirebaseApp.configure(
          name: MyStrings.APP_NAME,
          options: Platform.isIOS ? iosOptions : androidOptions
      );
    }

    return _firebaseApp;
  }

  static StorageReference storage() => _storage.ref();

  static FirebaseAuth auth() => _auth;

  static DatabaseReference databaseReference() => _databaseReference;

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
      await Import.readDeviceInfo();
      await app();

      _firebaseUser = await _auth.currentUser();
      if (_firebaseUser == null)
        throw new Exception(firebaseUser_Null);

      Log.d(TAG, 'init', 'Firebase OK');
      return FirebaseInitResult.ok;
    } catch (e) {
      Log.e(TAG, 'init', e);
      if (e.toString().contains(firebaseUser_Null))
        return FirebaseInitResult.fUserNull;
      return FirebaseInitResult.none;
    }
  }

  static void initNotificationManager(BuildContext context) {
    _fcm = NotificationManager(context);
    _fcm.init();
  }

  static void finalize() async {
    _firebaseUser = null;
//    _token = null;
    getTipster.reset();
    getPosts.reset();
    getSeguindo.reset();
    await _user.logout();
    _fcm = null;
    _user = null;
  }

  static Map map() => {
    'databaseURL': 'https://protips-oki.firebaseio.com',
    'storageBucket': 'gs://protips-oki.appspot.com'
  };

//  static Token get token => _token;

  static bool get isAdmin => _isAdmin ?? false;

  static NotificationManager get notificationManager => _fcm;

  //endregion

  //region Usuario

  static User user() {
    if (_user == null)
      _user = new User();
    return _user;
  }

  static FirebaseUser fUser() => _firebaseUser;

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
    getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(getFirebase.fUser().uid)
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
    getUsers._localPath = directory + '/' + FirebaseChild.USUARIO;
    getPosts._localPath = directory + '/' + FirebaseChild.POSTES;
    appTempPath = directory + '/' + FirebaseChild.APP;
  }

  static Future<bool> saveOfflineData() async {
    try {
      File _pathUsers = _getUserFile(await _getDirectoryPath());
      String data = jsonEncode(getUsers.users);
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
      String data = await _pathUsers.readAsString();
      getUsers.dd(jsonDecode(data));
      Log.d(TAG, 'readOfflineData', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'readOfflineData', e);
      return false;
    }
  }
  static Future<bool> deleteOfflineData() async {
    try {
      File file = _getUserFile(getUsers._localPath);
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
    Directory dir = Directory(directory.path + '/' + FirebaseChild.USUARIO);
    if (!dir.existsSync())
      await dir.create();
  }
  static Future<void> createPostDirectory() async {
    Directory directory = await _getDirectory();
    Directory dir = Directory(directory.path + '/' + FirebaseChild.POSTES);
    if (!dir.existsSync())
      await dir.create();
  }

  static Future<bool> downloadFile(String url, String path, String fileName, {bool override = false, ProgressCallback onProgress, CancelToken cancelToken}) async {
    try {
      String _path = '$path/$fileName';
      File file = File(_path);
      if (await file.exists()) {
        if (override) {
          await file.delete();
        } else {
          return true;
        }
      }
      Log.d(TAG, 'downloadFile', _path);
      await _dio.download(url, _path, onReceiveProgress: onProgress, cancelToken: cancelToken);
      return true;
    } catch(e) {
      Log.e(TAG, 'downloadFile', e);
      return false;
    }
  }

  static Future<void> saveData(String data) async {
    var dir = await _getDirectoryPath();
    var fileName = Data.now() + '.txt';
    File file = File('$dir/$fileName');
    await file.writeAsString(data);
    Log.d(TAG, 'saveData', 'OK', fileName);
  }
}

// ignore: camel_case_types
class getUsers {
  static const String TAG = 'getUsers';
  static String _localPath;

  static Map<String, User> _users = new Map();

  static Map<String, User> get users => _users;
  static Future<User> get(String key) async {
    if (_users[key] == null) {
      var item = await baixarUser(key);
      if (item != null)
        add(item);
    }
    return _users[key];
  }

  static void add(User user) {
    _users[user.dados.id] = user;
  }
  static void addAll(Map<String, User> users) {
    _users.addAll(users);
  }
  static void remove(String key) {
    _users.remove(key);
  }

  static void reset() {
    _users.clear();
  }

  static Future<void> baixar() async {
    try {
      var snapshot = await getFirebase.databaseReference().child(FirebaseChild.USUARIO).once();
      Map<dynamic, dynamic> map = snapshot.value;
      dd(map);
      Log.d(TAG, 'baixa', 'OK');
    } catch (e) {
      Log.e(TAG, 'baixa', e);
    }
  }

  static Future<User> baixarUser(String uid) async {
    try {
      var snapshot = await getFirebase.databaseReference()
          .child(FirebaseChild.USUARIO).child(uid).once();
      User user = User.fromJson(snapshot.value);
      return user;
    } catch (e) {
      Log.e(TAG, 'baixarUser', e);
      return null;
    }
  }

  static void dd(Map<dynamic, dynamic> map) {
    if (map == null)
      return;
    for (String key in map.keys) {
      try {
        User item = User.fromJson(map[key]);
        bool addTipster = item.dados.isTipster && !item.dados.isBloqueado && !item.solicitacaoEmAndamento();

        if (addTipster) {
          //Adiciona os Posts de quem eu sigo e meu Postes
          if (getFirebase.user().seguindo.containsKey(key) || key == getFirebase.fUser().uid) {
            getPosts.addAll(item.postes);
          } else {
            for (Post post in item.postes.values) {
              if (post.publico)
                getPosts.add(post);
            }
          }
          getTipster.add(item);
        }
        if (getFirebase.user().seguidores.containsKey(key)) {
          getSeguidores.add(item);
        }
        add(item);
      } catch(e) {
        Log.e(TAG, 'dd', e);
        continue;
      }
    }
  }

  static Future<void> saveFotosPerfilLocal() async {
    await OfflineData.createPerfilDirectory();

    for (User item in _users.values) {
      try {
        await OfflineData.downloadFile(item.dados.foto, _localPath, item.dados.fotoLocal, override: true);
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
  static Map<String, User> _users = new Map();

  static List<User> get users => _users.values.toList();
  static User get(String key) => _users[key];

  static void add(User user) {
    _users[user.dados.id] = user;
  }
  static void addAll(Map<String, User> users) {
    _users.addAll(users);
  }
  static void remove(String key) {
    _users.remove(key);
  }

  static void reset() {
    _users.clear();
  }

}

// ignore: camel_case_types
class getSeguindo {
  static Map<String, User> _users = new Map();

  static Map<String, User> get users => _users;

  static void remove(String key) {
    _users.remove(key);
  }

  static void add(User user) {
    _users[user.dados.id] = user;
  }

  static User get(String key) => _users[key];

  static void reset() {
    _users.clear();
  }
}

// ignore: camel_case_types
class getSeguidores {
  static Map<String, User> _users = new Map();

  static Map<String, User> get users => _users;

  static void remove(String key) {
    _users.remove(key);
  }

  static void add(User user) {
    _users[user.dados.id] = user;
  }

  static User get(String key) => _users[key];

  static void reset() {
    _users.clear();
  }
}

// ignore: camel_case_types
class getPosts {
  static const String TAG = 'getPosts';
  static String _localPath;

  static Map<String, Post> _postes = new Map();

  static List<Post> get postes => _postes.values.toList()..sort((a, b) => b.data.compareTo(a.data));
  static Post get(String key) => _postes[key];

  static void add(Post item) {
    _postes[item.id] = item;
  }
  static void addAll(Map<String, Post> items) {
    _postes.addAll(items);
  }
  static void remove(String key) {
    _postes.remove(key);
  }
  static void removeAll(String userId) {
    _postes.removeWhere((key, value) => value.idTipster == userId);
  }

  static void reset() {
    _postes.clear();
  }

  static Future<void> saveFotosLocal() async {
    await OfflineData.createPostDirectory();

    for (Post item in _postes.values) {
      try {
        await OfflineData.downloadFile(item.foto, _localPath, item.fotoLocal);
      } catch(e) {
        Log.e(TAG, 'saveLocalFotos', e);
        continue;
      }
    }
    Log.d(TAG, 'saveLocalFotos', 'OK');
  }

}

class Log {

  static FlutterToast _toast;

  static void toast(BuildContext context, String texto, {bool isError = false}) {
    if (_toast == null)
      _toast = FlutterToast(context);
    Widget body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: MyTheme.accent(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isError ? Icons.clear : Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text(texto),
        ],
      ),
    );
    _toast.showToast(child: body, gravity: ToastGravity.BOTTOM, toastDuration: Duration(seconds: isError ? 4 : 2));
  }

  static void d(String tag, String metodo, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = '';
    if (value != null) msg += ': ' + value.toString();
    if (value1 != null) msg += ': ' + value1.toString();
    if (value2 != null) msg += ': ' + value2.toString();
    if (value3 != null) msg += ': ' + value3.toString();
    print(tag + ": D/" + metodo + ": " + msg);
  }
  static void e(String tag, String metodo, dynamic e, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = ": E/" + metodo + ": " + e.toString();
    if (value != null) msg += ': ' + value.toString();
    if (value1 != null) msg += ': ' + value1.toString();
    if (value2 != null) msg += ': ' + value2.toString();
    if (value3 != null) msg += ': ' + value3.toString();
    print(tag + msg);
//    _saveLog(tag + msg);
    _sendError(tag, msg);
  }

//  static _saveLog(String data) {
//    try {
//      OfflineData.saveData(data);
//    } catch(e) {
//      //Todo \(ºvº)/
//    }
//  }
  
  static _sendError(String tag, String value) {
    try {
      String data = tag + value;
      String id = getFirebase.fUser()?.uid ?? '_deslogado';
      getFirebase.databaseReference()
          .child(FirebaseChild.LOGS)
          .child(tag)
          .child(id)
          .child(Data.now())
          .set(data);
    } catch(e) {
      //Todo \(ºvº)/
    }
  }
}