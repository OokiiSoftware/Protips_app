import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/res/resources.dart';

import 'data_hora.dart';
import 'endereco.dart';

class UserDados {

  //region Variaveis
  static const String TAG = 'UserDados';

  String _id;
  String _nome;
  String _foto;
  String _fotoLocal;
  String _email;
  String _senha;
  String _tipname;
  String _telefone;
  String _descricao;
  bool _isPrivado;
  bool _isTipster;
  bool _isBloqueado;
  DataHora _nascimento;
  Endereco _endereco;
  //endregion

  UserDados() {
    endereco = new Endereco();
    nascimento = new DataHora();
  }

  UserDados.fromJson(Map<dynamic, dynamic> map) {
    id = map['id'];
    nome = map['nome'];
    email = map['email'];
    tipname = map['tipname'];
    descricao = map['descricao'];
    foto = map['foto'];
    telefone = map['telefone'];
    isPrivado = map['isPrivado'];
    isBloqueado = map['isBloqueado'];
    isTipster = map['isTipster'];
    endereco = Endereco.fromJson(map['endereco']);
    nascimento = DataHora.from(map['nascimento']);
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "foto": foto,
    "nome": nome,
    "email": email,
    "tipname": tipname,
    "isPrivado": isPrivado,
    "isTipster": isTipster,
    "telefone": telefone,
    "isBloqueado": isBloqueado,
    "descricao": descricao,
    "endereco": endereco.toJson(),
    "nascimento": nascimento.toMap(),
  };

  //region Metodos

  Future<bool> salvar(BuildContext context) async {
    Log.d(TAG, 'salvar', 'Iniciando');
    bool uploadOK = await _uploadPerfilPhoto();
    if (uploadOK != null && !uploadOK)
      return false;
    else if (uploadOK != null && uploadOK)
      if (!await _userUpdateInfo())
        return false;

    var result = await getFirebase.databaseReference()
        .child(FirebaseChild.USUARIO)
        .child(id)
        .child(FirebaseChild.DADOS)
        .set(toJson()).then((value) {
          Log.d(TAG, 'salvar', 'OK');
          return true;
        }).catchError((e) {
          Log.e(TAG, 'salvar fail', e);
          return false;
        });

    return result;
  }

  Future<bool> _uploadPerfilPhoto() async {
    File file = new File(foto);
    if (file == null || !await file.exists()) {
      Log.d(TAG, 'uploadUserPhoto', 'file Null');
      return null;
    }

    Log.d(TAG, 'uploadUserPhoto', 'Iniciando');
    Log.d(TAG, 'uploadUserPhoto', 'file path: ' + file.path);

    try {
      final StorageReference ref = getFirebase.storage()
          .child(FirebaseChild.USUARIO)
          .child(FirebaseChild.PERFIL)
          .child(id + '.jpg');

      var uploadTask = ref.putFile(file);
      var taskSnapshot = await uploadTask.onComplete;
      var fileUrl = await taskSnapshot.ref.getDownloadURL();

      file.delete();
      Log.d(TAG, 'uploadUserPhoto OK', fileUrl);
      foto = fileUrl;
      return true;
    } catch(e) {
      Log.e(TAG, 'uploadUserPhoto Fail', e);
      return false;
    }
  }

  Future<bool> _userUpdateInfo() async {
    Log.d(TAG, 'uploadUserInfo', 'Iniciando');

    int i = 0;
    UserUpdateInfo userUpdateInfo = UserUpdateInfo();
    if (foto!= null && foto.isNotEmpty) {
      userUpdateInfo.photoUrl = foto;
      i++;
    }
    if (nome!= null && nome.isNotEmpty) {
      userUpdateInfo.displayName = nome;
      i++;
    }
    try {
      if (i > 0)
        await getFirebase.fUser().updateProfile(userUpdateInfo);
      Log.d(TAG, 'uploadUserInfo', 'OK');
      return true;
    } catch (e) {
      Log.e(TAG, 'uploadUserInfo Fail', e);
      return false;
    }
  }

  Future<bool> addIdentificador() async {
    return await getFirebase.databaseReference()
        .child(FirebaseChild.IDENTIFICADOR)
        .child(tipname)
        .set(id)
        .then((value) => true)
        .catchError((e) => null);
  }

  //endregion

  //region get set

  bool get isTipster => _isTipster ?? false;

  set isTipster(bool value) {
    _isTipster = value;
  }

  bool get isBloqueado => _isBloqueado ?? false;

  set isBloqueado(bool value) {
    _isBloqueado = value;
  }

  bool get isPrivado => _isPrivado ?? false;

  set isPrivado(bool value) {
    _isPrivado = value;
  }

  DataHora get nascimento => _nascimento ?? DataHora();

  set nascimento(DataHora value) {
    _nascimento = value;
  }

  Endereco get endereco => _endereco ?? Endereco();

  set endereco(Endereco value) {
    _endereco = value;
  }

  String get telefone => _telefone ?? '';

  set telefone(String value) {
    _telefone = value;
  }

  String get foto => _foto ?? '';

  set foto(String value) {
    _foto = value;
  }


  bool get fotoLocalExist {
    File file = File(getUsers.localPath + '/' + fotoLocal);
    return file.existsSync();
  }

  File get fotoToFile {
    return File(getUsers.localPath + '/' + fotoLocal);
  }

  String get fotoLocal {
    if (_fotoLocal == null)
      _fotoLocal = id + '.jpg';
    return _fotoLocal;
  }

//  set fotoLocal(String value) {
//    _fotoLocal = value;
//  }

  String get senha => _senha ?? '';

  set senha(String value) {
    _senha = value;
  }

  String get descricao => _descricao ?? '';

  set descricao(String value) {
    _descricao = value;
  }

  String get tipname => _tipname ?? '';

  set tipname(String value) {
    _tipname = value;
  }

  String get email => _email ?? '';

  set email(String value) {
    _email = value;
  }

  String get nome => _nome ?? '';

  set nome(String value) {
    _nome = value;
  }

  String get id => _id ?? '';

  set id(String value) {
    _id = value;
  }

  //endregion

}