import 'dart:async';
import 'dart:collection';
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/token.dart';
import 'package:protips/model/user.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/model/device_info.dart';
import 'package:url_launcher/url_launcher.dart';

class Import {
  static const String TAG = 'Import';
  static const double APP_VERSION = 1.0;
  static Map<String, dynamic> _deviceData;

  static String getDeviceName() {
    return (Platform.isAndroid ? _deviceData['model'] : _deviceData['name']) ?? '';
  }

  static Future<Map> readDeviceInfo() async {
    _deviceData  = await DeviceInfo.getDeviceInfo();
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

  static void openUrl(BuildContext context, String url) async {
    try {
      if (await canLaunch(url))
        await launch(url);
      else
        throw Exception(MyErros.ABRIR_LINK);
    } catch(e) {
      Log.toast(context, MyErros.ABRIR_LINK, isError: true);
      Log.e(TAG, 'openUrl', e);
    }
  }

  static void openWhatsApp(BuildContext context, String numero) async {
    try {
      var whatsappUrl ="whatsapp://send?phone=$numero";
      if (await canLaunch(whatsappUrl))
        await launch(whatsappUrl);
      else
        throw Exception(MyErros.ABRIR_WHATSAPP);
    } catch(e) {
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

enum getFirebaseResult {
  ok, userNull, fUserNull
}

class getFirebase {
  static const String TAG = 'getFirebase';

  static FirebaseApp _firebaseApp;
  static FirebaseUser _firebaseUser;
  static FirebaseStorage _storage = FirebaseStorage.instance;
  static DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();
  static Token _token;

  static User _user;

  static Future<getFirebaseResult> init(BuildContext context) async {
    Log.d(TAG, 'init', 'Firebase Iniciando');

    const firebaseUser_Null = 'firebaseUser Null';
    const user_Null = 'user Null';
    try {
      await Import.readDeviceInfo();
      await app();

      _firebaseUser = await _auth.currentUser();
      if (_firebaseUser == null)
        throw new Exception(firebaseUser_Null);

      _user = await baixarUser(_firebaseUser.uid);
      if (_user == null)
        throw new Exception(user_Null);

      _token  = Token.fromToken(await _firebaseUser.getIdToken());

      await _user.salvarToken(_token);

      Log.d(TAG, 'init', 'Firebase OK');
      return getFirebaseResult.ok;
    } catch (e) {
        Log.e(TAG, 'init', e);

        if (e.toString().contains(user_Null))
          return getFirebaseResult.userNull;
        else if (e.toString().contains(firebaseUser_Null))
          return getFirebaseResult.fUserNull;
    }
  }

  static void finalize() {
    _firebaseUser = null;
    _user = null;
    _token = null;
    getTipster.reset();
    getPosts.reset();
    getSeguindo.reset();
  }

  static Map map() => {
    'databaseURL': 'https://protips-oki.firebaseio.com',
    'storageBucket': 'gs://protips-oki.appspot.com'
  };

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

  static Token get token => _token;

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

  static FirebaseUser fUser() => _firebaseUser;

  static User user() {
    if (_user == null)
      _user = new User();
    return _user;
  }

  static UserDados getUsuario() => user().dados;

  static void setUltinoEmail(String email) {

  }

  static Future<User> baixarUser(String uid) async {
    try {
      var snapshot = await databaseReference().child(FirebaseChild.USUARIO).child(uid).once();
      User user = User.fromMap(snapshot.value);
      return user;
    } catch (e) {
      Log.e(TAG, 'baixarUser', e);
      return null;
    }
  }

  static void setfUser(FirebaseUser user) {
    _firebaseUser = user;
  }

  static void setUser(User user, bool save) {
//    if (save) {
//      Gson gson = new Gson();
//      String json = gson.toJson(user);
//
//      create(context, Const.files.USER_JSON, json);
//    }
//
    _user = user;
  }

}

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

  /*static Future<void> baixar() async {
    try {
      var snapshot = await getFirebase.databaseReference().child(FirebaseChild.USUARIO).once();
      Map<dynamic, dynamic> map = snapshot.value;
      for (String key in map.keys) {
        User item = User.fromMap(map[key]);
        if (item.dados.isTipster) {
          //Adiciona os Posts de quem eu sigo e meu Postes
          if (getFirebase.user().seguindo.containsKey(key) || key == getFirebase.fUser().uid) {
            getPosts.addAll(item.postes);
          } else {
            for (Post post in item.postes.values) {
              if (post.publico)
                getPosts.add(post);
            }
          }
          add(item);
        }
      }
      Log.e(TAG, 'baixa', 'OK');
    } catch (e) {
      Log.e(TAG, 'baixa', e);
    }
  }*/
}

class getUsers {
  static const String TAG = 'getUsers';
  static Map<String, User> _users = new Map();

  static Map<String, User> get users => _users;
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

  static Future<void> baixar() async {
    try {
      var snapshot = await getFirebase.databaseReference().child(FirebaseChild.USUARIO).once();
      Map<dynamic, dynamic> map = snapshot.value;
      for (String key in map.keys) {
        User item = User.fromMap(map[key]);
        if (item.dados.isTipster) {
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
        add(item);
      }
      Log.e(TAG, 'baixa', 'OK');
    } catch (e) {
      Log.e(TAG, 'baixa', e);
    }
  }
}

class getPosts {
  static const String TAG = 'getPosts';
  static Map<String, Post> _postes = new HashMap();

  static List<Post> get postes => _postes.values.toList()..sort((a, b) =>  b.data.compareTo(a.data));
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

  static void reset() {
    _postes.clear();
  }
}

class getSeguindo {
  static Map<String, User> _usersAux = new Map();
  static Map<String, User> _users = new Map();
//  static Map<String, Post> _postes = new Map();

  static Map<String, User> get usersAux => _usersAux;
  static Map<String, User> get users => _users;
//  static Map<String, Post> get postes => _postes;

  static void remove(String key) {
    _users.remove(key);
    _usersAux.remove(key);
  }
//  static void removePost(Post post) {
//    _postes.remove(post);
//  }

  static void add(User user) {
    _users[user.dados.id] = user;
    _usersAux[user.dados.id] = user;
//    User item = findUser(user.getDados().getId());
//    if (item == null) {
//      users.add(user);
//      usersAux.add(user);
//    } else {
//      users.set(users.indexOf(item), user);
//      usersAux.set(usersAux.indexOf(item), user);
//    }
//    Collections.sort(users, new User.sortByMedia());
  }
//  static void addPost(Post post) {
//    _postes[post.id] = post;
//    Post item = null;
//    for (Post p : postes)
//      if (p.getId().equals(post.getId())) {
//        item = p;
//        break;
//      }
//    if (item == null) {
//      postes.add(post);
//      Collections.sort(postes, new Post.sortByDate());
//    }
//  }
//  static void addAll(Map<String, Post> posts) {
//    _postes.addAll(posts);
//    for (Post p : posts.values()) {
//    Post i = findPost(p.getId());
//    if (i == null)
//    postes.add(p);
//    }
//    Collections.sort(postes, new Post.sortByDate());
//  }

  static User get(String key) => _users[key];

  /*static User findUser(String key) {
    for (User p : users)
      if (p.getDados().getId().equals(key)) {
        return p;
      }
    return null;
  }
  static Post findPost(String key) {
    for (Post p : _postes)
      if (p.getId().equals(key))
        return p;
    return null;
  }*/

  static void reset() {
    _usersAux.clear();
    _users.clear();
//    _postes.clear();
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
    _toast.showToast(child: body, gravity: ToastGravity.BOTTOM, toastDuration: Duration(seconds: 2));
  }

  static void d(String tag, String metodo, dynamic value, [dynamic value1, dynamic value2, dynamic value3]) {
    String msg = value.toString();
    if (value1 != null) msg += ': ' + value1.toString();
    if (value2 != null) msg += ': ' + value2.toString();
    if (value3 != null) msg += ': ' + value3.toString();
    print(tag + ": D/" + metodo + ": " + msg);
  }
  static void e(String tag, String metodo, dynamic e) {
    print(tag + ": E/" + metodo + ": " + e.toString());
  }
}