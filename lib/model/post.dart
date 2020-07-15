import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/res/resources.dart';

class Post {

  //region Variáveis
  static const String TAG = "Post";

  String _id;
  String _id_tipster;
  String _titulo;
  String _link;
  String _descricao;
  String _foto;
  String _odd_maxima;
  String _odd_minima;
  String _odd_atual;
  String _unidade;
  String _horario_maximo;
  String _horario_minimo;
  String _data;
  String _esporte;
  String _linha;
  String _campeonato;
  bool _publico;
  Map<dynamic, dynamic> _bom, _ruim;
  //endregion

  Post();

  Post.fromMap(Map map) {
    id = map['id'];
    foto = map['foto'];
    titulo = map['titulo'];
    link = map['link'];
    descricao = map['descricao'];
//    texto = map['texto'];
    odd_maxima = map['odd_maxima'];
    odd_minima = map['odd_minima'];
    odd_atual = map['odd_atual'];
    unidade = map['unidade'];
    horario_maximo = map['horario_maximo'];
    horario_minimo = map['horario_minimo'];
    data = map['data'];
    id_tipster = map['id_tipster'];
    esporte = map['esporte'];
    linha = map['linha'];
//    mercado = map['mercado'];
    campeonato = map['campeonato'];
    publico = map['publico'];
    ruim = map['ruim'];
    bom = map['bom'];
  }

  Map toMap() => {
    "id": id,
    "foto": foto,
    "titulo": titulo,
    "link": link,
    "descricao": descricao,
    "odd_maxima": odd_maxima,
    "odd_minima": odd_minima,
    "odd_atual": odd_atual,
    "unidade": unidade,
    "horario_maximo": horario_maximo,
    "horario_minimo": horario_minimo,
    "data": data,
    "esporte": esporte,
    "linha": linha,
    "campeonato": campeonato,
    "publico": publico,
    "id_tipster": id_tipster,
    "bom": bom,
    "ruim": ruim,
  };

  static Map<String, Post> fromMapList(Map map) {
    Map<String, Post> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = Post.fromMap(map[key]);
    return items;
  }

  //region Métodos

  Future<bool> postar() async {
    Log.d(TAG, 'postar', 'Iniciando');
    var result = await _uploadPhoto();
    if (!result)
      return false;

    result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(id_tipster)
        .child(FirebaseChild.POSTES)
        .child(Cript.encript(data))
        .set(toMap())
        .then((value) {
//          for (User user in getSeguindo.users.values) {
//            MyNotificationManager.getInstance(activity).sendNewPost(this, user);
//          }
          return true;
        })
        .catchError((e) {
          Log.e(TAG, 'postar', e);
          return false;
        });

//    Import.get.seguindo.add(this);
//    Import.getFirebase.getTipster().getPostes().put(getId(), this);

    Log.d(TAG, 'postar', result);
    return result;
  }

  Future<bool> addBom(String userId) async {
    if (bom.containsValue(userId))
      return null;
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(id_tipster)
        .child(FirebaseChild.POSTES)
        .child(Cript.encript(data))
        .child(FirebaseChild.BOM)
        .child(userId)
        .set(userId)
        .then((value) => true)
        .catchError((e) => false);
    if (result) {
      removeRuim(userId);
      bom[userId] = userId;
    }
    return result ?? false;
  }

  Future<bool> addRuim(String userId) async {
    if (ruim.containsValue(userId))
      return null;
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(id_tipster)
        .child(FirebaseChild.POSTES)
        .child(Cript.encript(data))
        .child(FirebaseChild.RUIM)
        .child(userId)
        .set(userId)
        .then((value) => true)
        .catchError((e) => false);
    if (result) {
      removeBom(userId);
      ruim[userId] = userId;
    }
    return result ?? false;
  }

  Future<bool> removeBom(String userId) async {
    if (!bom.containsValue(userId))
    return null;
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(id_tipster)
        .child(FirebaseChild.POSTES)
        .child(Cript.encript(data))
        .child(FirebaseChild.BOM)
        .child(userId)
        .remove()
        .then((value) => true)
        .catchError((e) => false);
    if (result)
      bom.remove(userId);
    return result;
  }

  Future<bool> removeRuim(String userId) async {
    if (!ruim.containsValue(userId))
      return null;
     var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(id_tipster)
        .child(FirebaseChild.POSTES)
        .child(Cript.encript(data))
        .child(FirebaseChild.RUIM)
        .child(userId)
        .remove()
         .then((value) => true)
         .catchError((e) => false);
     if (result)
      ruim.remove(userId);
    return result;
  }

  Future<bool> excluir() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(id_tipster)
        .child(FirebaseChild.POSTES)
        .child(data)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    if (!result)
      return false;

    result = await getFirebase.storage()
        .child(FirebaseChild.USUARIO)
        .child(FirebaseChild.POSTES)
        .child(id_tipster)
        .child(id + '.jpg')
        .delete()
        .then((value) => true)
        .catchError((e) => false);

    getFirebase.user().postes.remove(id);

    return result ?? false;
  }

  Future<bool> _uploadPhoto() async {
    File file = new File(foto);
    if (file == null || !await file.exists()) {
      Log.d(TAG, 'uploadPhoto', 'file Null');
      return null;
    }

    Log.d(TAG, 'uploadPhoto', 'Iniciando');
    Log.d(TAG, 'uploadPhoto', 'file path: ' + file.path);

    try {
      final StorageReference ref = getFirebase.storage()
          .child(FirebaseChild.USUARIO)
          .child(FirebaseChild.POSTES)
          .child(id_tipster)
          .child(id + '.jpg');

      var uploadTask = ref.putFile(file);
      var taskSnapshot = await uploadTask.onComplete;
      var fileUrl = await taskSnapshot.ref.getDownloadURL();

      Log.d(TAG, 'uploadPhoto OK', fileUrl);
      foto = fileUrl;
      return true;
    } catch(e) {
      Log.e(TAG, 'uploadPhoto Fail', e);
      return false;
    }
  }

  //endregion

  //region get set

  String get id => _id ?? '';

  set id(String value) {
    _id = value;
  }

  String get id_tipster => _id_tipster ?? '';

  set id_tipster(String value) {
    _id_tipster = value;
  }

  String get titulo => _titulo ?? '';

  set titulo(String value) {
    _titulo = value;
  }

  Map<dynamic, dynamic> get ruim {
    if (_ruim == null)
      _ruim = Map();
    return _ruim;
  }


  set ruim(Map<dynamic, dynamic> value) {
    _ruim = value;
  }

  Map<dynamic, dynamic> get bom {
    if (_bom == null)
      _bom = Map();
    return _bom;
  }

  set bom(Map<dynamic, dynamic> value) {
    _bom = value;
  }

  bool get publico => _publico ?? false;

  set publico(bool value) {
    _publico = value;
  }

  String get campeonato => _campeonato ?? '';

  set campeonato(String value) {
    _campeonato = value;
  }

  /*String get mercado => _mercado ?? '';

  set mercado(String value) {
    _mercado = value;
  }*/

  String get linha => _linha ?? '';

  set linha(String value) {
    _linha = value;
  }

  String get esporte => _esporte ?? '';

  set esporte(String value) {
    _esporte = value;
  }

  String get data => _data ?? '';

  set data(String value) {
    _data = value;
  }

  String get horario_minimo => _horario_minimo ?? '';

  set horario_minimo(String value) {
    _horario_minimo = value;
  }

  String get horario_maximo => _horario_maximo ?? '';

  set horario_maximo(String value) {
    _horario_maximo = value;
  }

  String get unidade => _unidade ?? '';

  set unidade(String value) {
    _unidade = value;
  }

  String get odd_atual => _odd_atual ?? '';

  set odd_atual(String value) {
    _odd_atual = value;
  }

  String get odd_minima => _odd_minima ?? '';

  set odd_minima(String value) {
    _odd_minima = value;
  }

  String get odd_maxima => _odd_maxima ?? '';

  set odd_maxima(String value) {
    _odd_maxima = value;
  }

  String get foto => _foto ?? '';

  set foto(String value) {
    _foto = value;
  }

  /*String get texto => _texto ?? '';

  set texto(String value) {
    _texto = value;
  }*/

  String get descricao => _descricao ?? '';

  set descricao(String value) {
    _descricao = value;
  }

  String get link => _link ?? '';

  set link(String value) {
    _link = value;
  }

  //endregion

}
