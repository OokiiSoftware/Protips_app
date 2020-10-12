import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:random_string/random_string.dart';

import 'data_hora.dart';

class Post {

  //region Variáveis
  static const String TAG = "Post";

  String _id;
  String _idTipster;
  String _titulo;
  String _link;
  String _descricao;
  String _foto;
  String _fotoLocal;
  String _oddMaxima;
  String _oddMinima;
  String _oddAtual;
  String _unidade;
  String _horarioMaximo;
  String _horarioMinimo;
  String _data;
  String _esporte;
  String _linha;
  String _campeonato;
  bool _isPublico;
  Map<dynamic, dynamic> _bom, _ruim;
  //endregion

  Post();

  Post.fromJson(Map<dynamic, dynamic> map) {
    id = map['id'];
    foto = map['foto'];
    titulo = map['titulo'];
    link = map['link'];
    descricao = map['descricao'];
//    texto = map['texto'];
    oddMaxima = map['odd_maxima'];
    oddMinima = map['odd_minima'];
    oddAtual = map['odd_atual'];
    unidade = map['unidade'];
    horarioMaximo = map['horario_maximo'];
    horarioMinimo = map['horario_minimo'];
    data = map['data'];
    idTipster = map['id_tipster'];
    esporte = map['esporte'];
    linha = map['linha'];
//    mercado = map['mercado'];
    campeonato = map['campeonato'];
    isPublico = map['isPublico'];
    ruim = map['ruim'];
    bom = map['bom'];
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "foto": foto,
    "titulo": titulo,
    "link": link,
    "descricao": descricao,
    "odd_maxima": oddMaxima,
    "odd_minima": oddMinima,
    "odd_atual": oddAtual,
    "unidade": unidade,
    "horario_maximo": horarioMaximo,
    "horario_minimo": horarioMinimo,
    "data": data,
    "esporte": esporte,
    "linha": linha,
    "campeonato": campeonato,
    "isPublico": isPublico,
    "id_tipster": idTipster,
    "bom": bom,
    "ruim": ruim,
  };

  static Map<String, Post> fromJsonList(Map map) {
    Map<String, Post> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = Post.fromJson(map[key]);
    return items;
  }

  //region Métodos

  static Post criarTeste({bool isPublico = false}) {
    Post item = Post();
    item.id = randomString(10);
    item.horarioMaximo = '15:00 AM';
    item.horarioMinimo = '12:00 AM';
    item.linha = 'linha';
    item.esporte = 'futebol';
    item.campeonato = 'liga';
    item.oddMaxima = '3';
    item.oddMinima = '1';
    item.oddAtual = '1';
    item.unidade = '1';
    item.idTipster = Firebase.fUser.uid;
    item.titulo = 'Tip de teste';
    item.descricao = 'descricao do tip';
    item.link = 'link';
    item.isPublico = isPublico;
    item.data = DataHora.now();
    item.foto = '';
    return item;
  }

  Future<bool> postar({bool isTeste = false}) async {
    Log.d(TAG, 'postar', 'Iniciando');
    var result = await _uploadPhoto();
    if (!isTeste && (result == null || !result))
      return false;

    result = await Firebase.databaseReference
        .child(FirebaseChild.USUARIO)
        .child(idTipster)
        .child(FirebaseChild.POSTES)
        .child(data)
        .set(toJson())
        .then((value) => true)
        .catchError((e) {
          Log.e(TAG, 'postar', e);
          return false;
        });

    if (result)
      EventListener.onPostSend(this);
    else
      EventListener.onPostSendFail();

    Log.d(TAG, 'postar', result);
    return result;
  }

  Future<bool> addBom(String userId) async {
    if (bom.containsValue(userId))
      return true;
    var result = await Firebase.databaseReference
        .child(FirebaseChild.USUARIO)
        .child(idTipster)
        .child(FirebaseChild.POSTES)
        .child(data)
        .child(FirebaseChild.BOM)
        .child(userId)
        .set(userId)
        .then((value) => true)
        .catchError((e) => false);
    if (result) {
      await removeRuim(userId);
      bom[userId] = userId;
    }
    Log.d(TAG, 'addBom', result);
    return result ?? false;
  }

  Future<bool> addRuim(String userId) async {
    if (ruim.containsValue(userId))
      return true;
    var result = await Firebase.databaseReference
        .child(FirebaseChild.USUARIO)
        .child(idTipster)
        .child(FirebaseChild.POSTES)
        .child(data)
        .child(FirebaseChild.RUIM)
        .child(userId)
        .set(userId)
        .then((value) => true)
        .catchError((e) => false);
    if (result) {
      await removeBom(userId);
      ruim[userId] = userId;
    }
    Log.d(TAG, 'addRuim', result);
    return result ?? false;
  }

  Future<bool> removeBom(String userId) async {
    if (!bom.containsValue(userId))
    return null;
    var result = await Firebase.databaseReference
        .child(FirebaseChild.USUARIO)
        .child(idTipster)
        .child(FirebaseChild.POSTES)
        .child(data)
        .child(FirebaseChild.BOM)
        .child(userId)
        .remove()
        .then((value) => true)
        .catchError((e) => false);
    if (result)
      bom.remove(userId);
    Log.d(TAG, 'removeBom', result);
    return result;
  }

  Future<bool> removeRuim(String userId) async {
    if (!ruim.containsValue(userId))
      return true;
     var result = await Firebase.databaseReference
        .child(FirebaseChild.USUARIO)
        .child(idTipster)
        .child(FirebaseChild.POSTES)
        .child(data)
        .child(FirebaseChild.RUIM)
        .child(userId)
        .remove()
         .then((value) => true)
         .catchError((e) => false);
     if (result)
       ruim.remove(userId);
    Log.d(TAG, 'removeRuim', result);
    return result;
  }

  Future<bool> excluir() async {
    var result = await Firebase.databaseReference
        .child(FirebaseChild.USUARIO)
        .child(idTipster)
        .child(FirebaseChild.POSTES)
        .child(data)
        .remove()
        .then((value) => true)
        .catchError((e) => false);

    if (!result) return false;

    result = await Firebase.storage
        .child(FirebaseChild.USUARIO)
        .child(FirebaseChild.POSTES)
        .child(idTipster)
        .child(id + '.jpg')
        .delete()
        .then((value) => true)
        .catchError((e) => false);

    EventListener.onPostDelete(this);

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
      final StorageReference ref = Firebase.storage
          .child(FirebaseChild.USUARIO)
          .child(FirebaseChild.POSTES)
          .child(idTipster)
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

  /// Retorna TRUE se o post pertece ao usuário logado
  bool get isMyPost => idTipster == Firebase.fUser.uid;

  //endregion

  //region get set

  String get id => _id ?? '';

  set id(String value) {
    _id = value;
  }

  String get idTipster => _idTipster ?? '';

  set idTipster(String value) {
    _idTipster = value;
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

  bool get isPublico => _isPublico ?? false;

  set isPublico(bool value) {
    _isPublico = value;
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

  String get horarioMinimo => _horarioMinimo ?? '';

  set horarioMinimo(String value) {
    _horarioMinimo = value;
  }

  String get horarioMaximo => _horarioMaximo ?? '';

  set horarioMaximo(String value) {
    _horarioMaximo = value;
  }

  String get unidade => _unidade ?? '';

  set unidade(String value) {
    _unidade = value;
  }

  String get oddAtual => _oddAtual ?? '';

  set oddAtual(String value) {
    _oddAtual = value;
  }

  String get oddMinima => _oddMinima ?? '';

  set oddMinima(String value) {
    _oddMinima = value;
  }

  String get oddMaxima => _oddMaxima ?? '';

  set oddMaxima(String value) {
    _oddMaxima = value;
  }

  String get foto => _foto ?? '';

  set foto(String value) {
    _foto = value;
  }

  bool get fotoLocalExist {
    File file = File(getPosts.localPath + '/' + fotoLocal);
    return file.existsSync() ;
  }

  File get fotoToFile {
    return File(getPosts.localPath + '/' + fotoLocal);
  }

  String get fotoLocal {
    if (_fotoLocal == null)
      _fotoLocal = id + '.jpg';
    return _fotoLocal;
  }

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
