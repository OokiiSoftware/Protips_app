import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/auxiliar/import.dart';

class PostPerfil {

  //region Variáveis
  static const String TAG = "PostPerfil";

  String _id;
  String _foto;
  String _titulo;
  String _texto;
  String _data;
  String _idTipster;
  //endregion

  PostPerfil();

  PostPerfil.fromJson(Map<dynamic, dynamic> map) {
    id = map['id'];
    foto = map['foto'];
    titulo = map['titulo'];
    texto = map['texto'];
    data = map['data'];
    idTipster = map['id_tipster'];
  }

  static Map<String, PostPerfil> fromJsonList(Map map) {
    Map<String, PostPerfil> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = PostPerfil.fromJson(map[key]);
    return items;
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "foto": foto,
    "titulo": titulo,
    "texto": texto,
    "data": data,
    "id_tipster": idTipster,
  };

  //region Métodos

  Future<bool> postar() async {
    var result = await _uploadPhoto();
    if (!result)
      return false;

    result = await getFirebase.databaseReference
        .child(FirebaseChild.USUARIO)
        .child(idTipster)
        .child(FirebaseChild.POSTES_PERFIL)
        .child(data)
        .set(toJson())
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      getFirebase.user.postPerfil[id] = this;
    Log.d(TAG, 'Postar', result);
    return result;
  }

  Future<bool> excluir() async {
    var result = await getFirebase.databaseReference
        .child(FirebaseChild.USUARIO)
        .child(idTipster)
        .child(FirebaseChild.POSTES_PERFIL)
        .child(data)
        .remove()
        .then((value) => true)
        .catchError((e) => false);
    if (result) {
      await getFirebase.storage
          .child(FirebaseChild.USUARIO)
          .child(FirebaseChild.POSTES_PERFIL)
          .child(idTipster)
          .child(id + '.jpg').delete();

      getFirebase.user.postPerfil.remove(id);
    }
    Log.d(TAG, 'excluir', result);
    return result;
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
      final StorageReference ref = getFirebase.storage
          .child(FirebaseChild.USUARIO)
          .child(FirebaseChild.POSTES_PERFIL)
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

  //endregion

  //region gets sets

  String get id => _id ?? '';

  set id(String value) {
    _id = value;
  }

  String get idTipster => _idTipster ?? '';

  set idTipster(String value) {
    _idTipster = value;
  }

  String get data {
    if (_data == null)
      _data = '.';
    return _data;
  }

  set data(String value) {
    _data = value;
  }

  String get texto => _texto ?? '';

  set texto(String value) {
    _texto = value;
  }

  String get titulo => _titulo ?? '';

  set titulo(String value) {
    _titulo = value;
  }

  String get foto => _foto ?? '';

  set foto(String value) {
    _foto = value;
  }

  //endregion

}