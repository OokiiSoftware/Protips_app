import 'package:firebase_auth/firebase_auth.dart';
import 'package:protips/auxiliar/device.dart';

class Token {

  String _value;
  String _data;
  String _device;
  String _provider;

  Token();

  Token.fromJson(Map map) {
    value = map['value'];
    data = map['data'];
    device = map['device'];
    provider = map['provider'];
  }

  Token.fromToken(IdTokenResult t) {
    data = t.authTime.toString();
    provider = t.signInProvider;
    device = Device.name;
    value = t.token;
  }

  Map toJson() => {
    'id': value,
    'data': data,
    'device': device,
    'provider': provider,
  };

  static Map<String, Token> fromJsonList(Map map) {
    Map<String, Token> items = Map();
    if (map == null)
      return items;
    for (String key in map.keys)
      items[key] = Token.fromJson(map[key]);
    return items;
  }

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