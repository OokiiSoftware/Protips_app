import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data.dart';
import 'package:protips/model/post.dart';
import 'package:protips/pages/crop_page.dart';
import 'package:protips/res/resources.dart';
import 'package:path/path.dart' as path;
import 'package:random_string/random_string.dart';

class PostPage extends StatefulWidget {
  static const String tag = 'PostPage';
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<PostPage> {
  static const String TAG = 'PostPage';

  bool isPublico = false;
  double progressBarValue = 0;
  File _foto;

  String currentHorarioMinino = '';
  String currentHorarioMaximo = '';

  //region TextEditingController
  TextEditingController _titulo = TextEditingController();
  TextEditingController _anexo = TextEditingController();
  TextEditingController _descricao = TextEditingController();
  TextEditingController _oddMaxima = TextEditingController();
  TextEditingController _oddMinima = TextEditingController();
  TextEditingController _oddAtual = TextEditingController();
  TextEditingController _unidades = TextEditingController();
  TextEditingController _horarioMaximo = TextEditingController();
  TextEditingController _horarioMinimo = TextEditingController();
  TextEditingController _esporte = TextEditingController();
  TextEditingController _linha = TextEditingController();
  TextEditingController _link = TextEditingController();
  TextEditingController _campeonato = TextEditingController();

  bool _tituloIsEmpty = false;
  bool _anexoIsEmpty = false;
  bool _oddAtualIsEmpty = false;
  bool _unidadesIsEmpty = false;
  bool _esporteIsEmpty = false;
  bool _linkIsEmpty = false;
  //endregion
  LinearProgressIndicator progressBar;
  FloatingActionButton fabPostar;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var rowSpacing = Padding(padding: EdgeInsets.only(right: 5));
    _horarioMaximo.text = currentHorarioMaximo;
    _horarioMinimo.text = currentHorarioMinino;
    fabPostar = FloatingActionButton.extended(
      label: Text(MyStrings.POSTAR),
      backgroundColor: MyTheme.accent(),
      onPressed: () {
        _postManager();
      },
    );
    progressBar = LinearProgressIndicator(value: progressBarValue);
    return Scaffold(
      appBar: AppBar(title: Text(Titles.POST_TIP)),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Stack(
          children: [
            progressBar,
            ListView(
              children:<Widget> [
                //Titulo
                CustomTextField(_titulo, TextInputType.name, _tituloIsEmpty, MyStrings.TITULO, () {setState(() {_tituloIsEmpty = false;});}),
                //Anexo
                CustomTextField(_anexo, TextInputType.name, _anexoIsEmpty, MyStrings.ANEXAR_IMAGEM, () async {
                  var file = await Navigator.of(context).pushNamed(CropImagePage.tag);
                  if(file != null && file is File && await file.exists()) {
                    _foto = file;
                    setState(() {
                      _anexoIsEmpty = false;
                      _anexo.text = path.basename(_foto.path);
                    });
                  }
                }),
                //Descrição
                CustomTextField(_descricao, TextInputType.multiline, false, MyStrings.DESCRICAO),
                //Odd
                Row(children:<Widget> [
                  //Minima
                  Expanded(child: CustomTextField(_oddMinima, TextInputType.number, false, MyStrings.ODD_MINIMA)),
                  rowSpacing,
                  //Maxima
                  Expanded(child: CustomTextField(_oddMaxima, TextInputType.number, false, MyStrings.ODD_MAXIMA)),
                ]),
                //Unidades
                Row(children:<Widget> [
                  //Odd Atual
                  Expanded(child: CustomTextField(_oddAtual, TextInputType.number, _oddAtualIsEmpty, MyStrings.ODD_ATUAL, () {setState(() {_oddAtualIsEmpty = false;});})),
                  rowSpacing,
                  //Unidades
                  Expanded(child: CustomTextField(_unidades, TextInputType.number, _unidadesIsEmpty, MyStrings.UNIDADES, () {setState(() {_unidadesIsEmpty = false;});})),
                ]),
                //Horarios
                Row(children:<Widget> [
                  //Minimo
                  Expanded(child: CustomTextField(_horarioMinimo, TextInputType.number, false, MyStrings.HORARIO_MINIMO, () async {
                    var result = await setHorario(currentHorarioMinino);
                    if (result != null) {
                      setState(() {
                        currentHorarioMinino = result.format(context);
                      });
                    }
                  })),
                  rowSpacing,
                  //Maximo
                  Expanded(child: CustomTextField(_horarioMaximo, TextInputType.number, false, MyStrings.HORARIO_MAXIMO, () async {
                    var result = await setHorario(currentHorarioMaximo);
                    if (result != null) {
                      setState(() {
                        currentHorarioMaximo = result.format(context);
                      });
                    }
                  })),
                ]),
                //Horarios Labels
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children:<Widget> [
                      //Minimo
                      Expanded(child: Text(MyStrings.HORARIO_MINIMO_ENTRADA, textAlign: TextAlign.center)),
                      //Maximo
                      Expanded(child: Text(MyStrings.HORARIO_MAXIMO_ENTRADA, textAlign: TextAlign.center)),
                    ]),
                //Esporte / Linha
                Row(children:<Widget> [
                  Expanded(child: CustomTextField(_esporte, TextInputType.name, _esporteIsEmpty, MyStrings.ESPORTE, () {setState(() {_esporteIsEmpty = false;});})),
                  rowSpacing,
                  Expanded(child: CustomTextField(_linha, TextInputType.name, false, MyStrings.LINHA)),
                ]),
                //Link
                CustomTextField(_link, TextInputType.url, _linkIsEmpty, MyStrings.LINK, () {setState(() {_linkIsEmpty = false;});}),
                //Campeonato / Tip Publico
                Row(children:<Widget> [
                  Expanded(child: CustomTextField(_campeonato, TextInputType.name, false, MyStrings.CAMPEONATO)),
                  rowSpacing,
                  Expanded(child: CheckboxListTile(
                      title: Text(MyStrings.TIP_PUBLICO),
                      value: isPublico,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool value) {
                        setState(() {
                          isPublico = value;
                        });
                      }
                  )),
                ]),
              ],
            ),
          ],
        )
      ),
      floatingActionButton: fabPostar,
    );
  }

  Widget CustomTextField(TextEditingController _controller, TextInputType _inputType, bool valueIsEmpty, String labelText, [void action()]) {
    //region Variaveis
    double itemPaddingValue = 10;

    //region Container que contem os textField
    var itemPadding = EdgeInsets.only(left: itemPaddingValue, right: itemPaddingValue, top: 10);

    var itemlBorder = OutlineInputBorder(borderSide: BorderSide(color: MyTheme.tintColor2()));
    var itemDecoration = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: MyTheme.tintColor2());
    var itemTextStyle = TextStyle(color: MyTheme.primaryDark(), fontSize: 14);
    var itemPrefixStyle = TextStyle(color: MyTheme.textColorInvert());
    var itemPrefixStyleErro = TextStyle(color: MyTheme.textColorError());
    //endregion

    //endregion

    return Container(
      height: 40,
      margin: EdgeInsets.only(top: 10),
      padding: itemPadding,
      decoration: itemDecoration,
      child: TextField(
        controller: _controller,
        keyboardType: _inputType,
        style: itemTextStyle,
        decoration: InputDecoration(
          enabledBorder: itemlBorder,
          focusedBorder: itemlBorder,
          labelStyle: valueIsEmpty ? itemPrefixStyleErro : itemPrefixStyle,
          labelText: labelText.toUpperCase(),
        ),
        onTap: action,
      ),
    );
  }

  Future<TimeOfDay> setHorario(String currentItem) async {
    DateTime atual;
    try {
      Log.e(TAG, 'setHorario currentItem', currentItem);
      atual = DateTime.parse(currentItem);
    } catch(e) {
      Log.e(TAG, 'setHorario', e);
      atual = DateTime.now();
    }
    TimeOfDay result = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(atual),
    );
    return result;
  }

  Future<void> _postManager() async {
    Post item = _criarTip();
    if(_verificar(item)) {
      setState(() {
        progressBarValue = null;
      });
      if (await item.postar()) {
        getPosts.add(item);
        Navigator.pop(context);
      }
    }
    setState(() {
      progressBarValue = 0;
    });
  }
  Post _criarTip() {
    Post item = Post();
    item.id = randomString(10);
    item.horario_maximo = _horarioMaximo.text;
    item.horario_minimo = _horarioMinimo.text;
    item.linha = _linha.text;
    item.esporte = _esporte.text;
    item.campeonato = _campeonato.text;
    item.odd_maxima = _oddMaxima.text;
    item.odd_minima = _oddMinima.text;
    item.odd_atual = _oddAtual.text;
    item.unidade = _unidades.text;
    item.id_tipster = getFirebase.fUser().uid;
    item.titulo = _titulo.text;
    item.descricao = _descricao.text;
    item.link = _link.text;
    item.publico = isPublico;
    item.data = Data.now();
    item.foto = _foto?.path;
    return item;
  }
  bool _verificar(Post item) {
    try{
      setState(() {
        if (item.titulo.isEmpty) {
          _tituloIsEmpty = true;
          throw Exception('titulo.isEmpty');
        }
        if (item.foto.isEmpty) {
          _anexoIsEmpty = true;
          throw Exception('foto.isEmpty');
        }
        if (item.odd_atual.isEmpty) {
          _oddAtualIsEmpty = true;
          throw Exception('odd_atual.isEmpty');
        }
        if (item.unidade.isEmpty) {
          _unidadesIsEmpty = true;
          throw Exception('unidade.isEmpty');
        }
        if (item.esporte.isEmpty) {
          _esporteIsEmpty = true;
          throw Exception('esporte.isEmpty');
        }
        if (item.link.isEmpty) {
          _linkIsEmpty = true;
          throw Exception('link.isEmpty');
        }
      });
      return true;
    }catch(e) {
      Log.e(TAG, '_criarTip', e);
      return false;
    }
  }

}