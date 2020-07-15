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
  String _id_tipster;
  //endregion

  PostPerfil();

  PostPerfil.fromMap(Map map) {
    id = map['id'];
    foto = map['foto'];
    titulo = map['titulo'];
    texto = map['texto'];
    data = map['data'];
    id_tipster = map['id_tipster'];
  }

  static Map<String, PostPerfil> fromMapList(Map map) {
    Map<String, PostPerfil> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = PostPerfil.fromMap(map[key]);
    return items;
  }


  Map toMap() => {
    "id": id,
    "foto": foto,
    "titulo": titulo,
    "texto": texto,
    "data": data,
    "id_tipster": id_tipster,
  };

  //region Métodos

  Future<bool> postar() async {
    var result = await _uploadPhoto();
    if (!result)
      return false;

    result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(id_tipster)
        .child(FirebaseChild.POSTES_PERFIL)
        .child(data.substring(0, data.indexOf('.')))
        .set(toMap())
        .then((value) => true)
        .catchError((e) => false);

    if (result)
      getFirebase.user().post_perfil[id] = this;
    Log.d(TAG, 'Postar', result);
    return result;
  }

  Future<bool> excluir() async {
    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(id_tipster)
        .child(FirebaseChild.POSTES_PERFIL)
        .child(data)
        .remove()
        .then((value) => true)
        .catchError((e) => false);
    if (result) {
      await getFirebase.storage()
          .child(FirebaseChild.USUARIO)
          .child(FirebaseChild.POSTES_PERFIL)
          .child(id_tipster)
          .child(id + '.jpg').delete();

      getFirebase.user().post_perfil.remove(id);
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
      final StorageReference ref = getFirebase.storage()
          .child(FirebaseChild.USUARIO)
          .child(FirebaseChild.POSTES_PERFIL)
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

  //region gets sets

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get foto => _foto ?? '';

  String get id_tipster => _id_tipster;

  set id_tipster(String value) {
    _id_tipster = value;
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

  set foto(String value) {
    _foto = value;
  }

  //endregion

}