import 'package:firebase_auth/firebase_auth.dart';
import 'package:protips/auxiliar/import.dart';

class Token {

  String _value;
  String _data;
  String _device;
  String _provider;

  Token.from(Map map) {
    value = map['value'];
    data = map['data'];
    device = map['device'];
    provider = map['provider'];
  }

  Token.fromToken(IdTokenResult t) {
    data = t.authTime.toString();
    provider = t.signInProvider;
    device = Import.getDeviceName();
    value = t.token;
  }

  Map toMap() => {
    'id': value,
    'data': data,
    'device': device,
    'provider': provider,
  };

  //region get set

  String get value => _value ?? '';

  set value(String value) {
    _value = value;
  }

  String get data => _data ?? '';

  String get device => _device ?? '';

  set device(String value) {
    _device = value;
  }

  set data(String value) {
    _data = value;
  }

  String get provider => _provider ?? '';

  set provider(String value) {
    _provider = value;
  }

  //endregion

}