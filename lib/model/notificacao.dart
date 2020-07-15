import 'package:flutter/foundation.dart';
import 'package:random_string/random_string.dart';

class Notificacao {

  bool _isExpanded = false;
  bool get isExpanded => _isExpanded ?? false;
  set isExpanded(bool value) {
    _isExpanded = value;
  }

  String id;
  String titulo;
  String subtitulo;
  String eSubtitulo;
  String eTitulo;
  String foto;
  String tag;

  Notificacao({
    this.id = '',
    this.titulo = '',
    this.subtitulo = '',
    this.eSubtitulo = '',
    this.eTitulo = '',
    this.foto = '',
    this.tag = '',
    this.onTap,
    this.onLongPress});

  VoidCallback onTap;
  VoidCallback onLongPress;

}