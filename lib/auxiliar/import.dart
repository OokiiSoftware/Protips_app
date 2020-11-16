import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/denuncia.dart';
import 'package:protips/model/error.dart';
import 'package:protips/model/post_perfil.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/res/strings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase.dart';
import 'log.dart';
import 'notification_manager.dart';

class Navigate {
  static dynamic to(BuildContext context, StatefulWidget widget) async {
    return await Navigator.of(context).push(
        PageRouteBuilder(
            pageBuilder: (context, ani, ani2) => widget,
          transitionsBuilder: (context, ani, ani2, child) {
            var begin = Offset(-1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.fastOutSlowIn;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = ani.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          }
        )
    );
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
      // Log.snackbar(MyErros.LINK_REMOVIDO, isError: true);
      if (await canLaunch(url))
        await launch(url);
      else
        throw Exception(MyErros.ABRIR_LINK);
    } catch(e) {
      if (context != null)
        Log.snackbar(MyErros.ABRIR_LINK, isError: true);
      Log.e2(TAG, 'openUrl', e);
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
      // Log.snackbar(MyErros.LINK_REMOVIDO, isError: true);
      if (await canLaunch(_emailLaunchUri.toString()))
        await launch(_emailLaunchUri.toString());
      else
        throw Exception(MyErros.ABRIR_EMAIL);
    } catch(e) {
      if (context != null)
        Log.snackbar(MyErros.ABRIR_EMAIL, isError: true);
      Log.e(TAG, 'openEmail', e);
    }
  }

  static void openWhatsApp(String numero, [BuildContext context]) async {
    try {
      // Log.snackbar(MyErros.LINK_REMOVIDO, isError: true);
      numero = numero.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '').replaceAll('-', '');
      var link ="whatsapp://send?phone=55$numero";
      if (await canLaunch(link))
        await launch(Uri.encodeFull(link));
      else
        throw Exception(MyErros.ABRIR_WHATSAPP);
    } catch(e) {
      if (context != null)
        Log.snackbar(MyErros.ABRIR_WHATSAPP, isError: true);
      Log.e(TAG, 'openWhatsApp', e);
    }
  }

  static void openInstagram(String usuario, [BuildContext context]) async {
    try {
      // Log.snackbar(MyErros.LINK_REMOVIDO, isError: true);
      usuario = usuario.replaceAll('@', '');
      var link ="https://www.instagram.com/$usuario/";
      if (await canLaunch(link))
        await launch(Uri.encodeFull(link));
      else
        throw Exception(MyErros.ABRIR_INSTAGRAM);
    } catch(e) {
      if (context != null)
        Log.snackbar(MyErros.ABRIR_INSTAGRAM, isError: true);
      Log.e(TAG, 'openInstagram', e);
    }
  }
}

class EventListener {
  static onPostSend(Post item) async {
    getPosts.add(item);
    await NotificationManager.instance.sendPostTopic(item);
    Log.snackbar('TIP Postado');
  }
  static onPostPerfilSend(PostPerfil item) {
    FirebasePro.userPro.postPerfil[item.id] = item;
    Log.snackbar('Postado no Perfil');
  }

  static onPostSendFail() async {
    Log.snackbar('Ocorreu um erro ao enviar sua TIP');
  }

  static onPostDelete(Post item) {
    FirebasePro.userPro.postes.remove(item.id);
    getPosts.remove(item.id);
    Log.snackbar('TIP Excluido');
  }
  static onPostPerfilDelete(PostPerfil item) {
    FirebasePro.userPro.postPerfil.remove(item.id);
    Log.snackbar('Post Excluido');
  }

  static onSolicitacaoTipster(UserPro user) async {
      await NotificationManager.instance.sendSolicitacaoTipsterTopic(user);
  }
  static onSolicitacaoTipsterAceita(UserPro user) async {
    await NotificationManager.instance.sendSolicitacaoTipsterAceitaTopic(user);
  }

  static onSolicitacaoFiliado(UserPro user) async {
      await NotificationManager.instance.sendSolicitacaoSeguidorTopic(user);
  }

  static onSolicitacaoFiliadoAceita(UserPro user) async {
    await NotificationManager.instance.sendSolicitacaoAceitaSeguidorTopic(user);
  }

  static onPagamentoConcluido(UserPro user) async {
    // await FirebasePro.notificationManager.sendPagamentoTopic(user);
    Log.snackbar('Pagamento concluido');
  }

  static onDenunciaAprovada(Denuncia item) async {
    await NotificationManager.instance.sendDenunciaTopic(item);
    await item.delete();
  }
}

class OfflineData {
  static const String TAG = 'offlineData';
  static String appTempName =  MyResources.APP_NAME + '.apk';
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
        getUsers.dd(UserPro.fromJsonList(jsonDecode(data)));
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

  static Map<String, UserPro> _data = new Map();

  static Map<String, UserPro> get data => _data;
  static Future<UserPro> get(String key) async {
    if (_data[key] == null) {
      var item = await UserPro.baixar(key);
      if (item != null)
        add(item);
    }
    return _data[key];
  }

  static void add(UserPro item) {
    _data[item.dados.id] = item;
    if(item.dados.id == FirebasePro.userPro.dados.id)
      FirebasePro.userPro = item;
  }
  static void addAll(Map<String, UserPro> items) {
    _data.addAll(items);
  }
  static void remove(String key) {
    _data.remove(key);
  }

  static void reset() {
    _data.clear();
  }

  static void dd(Map<String, UserPro> map) {
    if (map == null) return;

    reset();
    getPosts.reset();
    getTipster.reset();

    String meuID = FirebasePro.user.uid;
    for (String key in map.keys) {
      try {
        UserPro item = map[key];
        bool addTipster = item.dados.isTipster && !item.dados.isBloqueado && !item.solicitacaoEmAndamento();

        if (addTipster) {
          var list;
          //Adiciona os Posts de quem eu sigo e meu Postes
          if (item.filiados.containsKey(meuID) || key == meuID) {
            list = item.postes.values.toList();
          } else if (item.seguidores.containsKey(meuID)) {
            list = item.postes.values.where((e) => e.isPublico).toList();
          }
          if (list != null) {
            getPosts.addAll(list);
          }

          getTipster.add(item);
        }
        add(item);
      } catch(e) {
        Log.e(TAG, 'dd', e);
        continue;
      }
    }
    Log.d(TAG, 'dd', 'OK', map.length);
  }

  static Future<void> saveFotosPerfilLocal() async {
    //Salva minha foto
    await OfflineData.downloadFile(FirebasePro.userPro.dados.foto, localPath, FirebasePro.userPro.dados.fotoLocal, override: true);
    //Salva foto dos tipsters
    for (UserPro item in getTipster.data) {
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
  static Map<String, UserPro> _data = new Map();

  static List<UserPro> get data => _data.values.toList();
  static UserPro get(String key) => _data[key];

  static void add(UserPro item) {
    _data[item.dados.id] = item;
  }
  static void addAll(Map<String, UserPro> items) {
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
  static const String TAG = 'getSolicitacoes';
  static Map<String, UserPro> _data = new Map();

  static List<UserPro> get data => _data.values.toList();

  static void remove(String key) {
    _data.remove(key);
  }

  static void _add(UserPro item) {
    _data[item.dados.id] = item;
  }

  static UserPro get(String key) => _data[key];

  static void reset() {
    _data.clear();
  }

  static void observe() async {
    FirebasePro.database
        .child(FirebaseChild.SOLICITACAO_NOVO_TIPSTER)
        .onValue.listen((event) async {
      Map<dynamic, dynamic> map = event.snapshot.value;
      if (map != null)
        for(String key in map.keys) {
          var item = await getUsers.get(key);
          if (item != null)
            _add(item);
        }
    });
  }

  static Future baixar() async {
    Map<dynamic, dynamic> result = await FirebasePro.database
        .child(FirebaseChild.SOLICITACAO_NOVO_TIPSTER)
        .once().then((value) => value.value)
        .catchError((ex) => null);
    if (result != null) {
      reset();
      for (dynamic key in result.keys) {
        try {
          var e = await getUsers.get(key);
          if(e != null)
            _add(e);
        } catch(e) {
          Log.e(TAG, 'baixar', e);
          continue;
        }
      }
    }
  }
}

//Lista de erros que ocorre nos dispositivos dos usuários
// ignore: camel_case_types
class getErros {
  static const String TAG = 'getErros';
  static Map<String, Erro> _data = new Map();

  static List<Erro> get data => _data.values.toList();

  static void remove(String key) {
    _data.remove(key);
  }

  static void add(Erro item) {
    _data[item.data] = item;
  }

  static Erro get(String key) => _data[key];

  static Future<void> baixar() async {
    Map<dynamic, dynamic> result = await FirebasePro.database.child(FirebaseChild.LOGS)
        .once().then((value) => value.value).catchError((ex) => null);
    if (result != null) {
      reset();
      for (dynamic item in result.values) {
        try {
          Erro e = Erro.fromJson(item);
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

  static Erro _findSimilar(Erro e) {
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
    Map<dynamic, dynamic> result = await FirebasePro.database.child(FirebaseChild.DENUNCIAS)
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
      if (item.isMyPost || item.isPublico)
        result.add(item);
      else {
        var pagamento = await loadPagamento(item.idTipster, data.substring(0, data.length-3));
        if (pagamento != null) result.add(item);
      }
    }
    return result;
  }
  static Post get(String key) => _data[key];

  static Future<Post> baixar(String postKey, String userId) async {
    if (_data[postKey] == null) {
      var result = await FirebasePro.database.child(FirebaseChild.USUARIO)
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
    var snapshot = await FirebasePro.database
        .child(FirebaseChild.PAGAMENTOS)
        .child(tipsterID)
        .child(data)
        .child(FirebasePro.user.uid)
        .once();

    return snapshot.value;
  }
}

