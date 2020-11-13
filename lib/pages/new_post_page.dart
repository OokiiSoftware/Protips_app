import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protips/auxiliar/config.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/post.dart';
import 'package:protips/pages/crop_page.dart';
import 'package:path/path.dart' as path;
import 'package:protips/res/layouts.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';
import 'package:random_string/random_string.dart';

class NewPostPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<NewPostPage> {

  //region Variaveis
  static const String TAG = 'NewPostPage';
  static Post _currentPost;

  bool _isAvancado = Config.postAvancado;
  bool _isPublico = false;
  bool _isPostando = false;
  bool _isBloqueadoPorDenuncias;
  double _progressBarValue = 0;
  File _foto;

  String _currentHorarioMinino = '';
  String _currentHorarioMaximo = '';

  //region TextField

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
  //endregion

  bool _tituloIsEmpty = false;
  bool _anexoIsEmpty = false;
  bool _oddAtualIsEmpty = false;
  bool _unidadesIsEmpty = false;
  bool _esporteIsEmpty = false;
  bool _linkIsEmpty = false;
  bool _descricaoIsEmpty = false;
  //endregion

  GlobalKey iconAvancadoKey = GlobalKey();

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    if (_currentPost != null) {
      _titulo.text = _currentPost.titulo;
      _foto = File(_currentPost.foto);
      if (_foto.existsSync())
        _anexo.text = path.basename(_foto.path);
      _descricao.text = _currentPost.descricao;
      _oddMaxima.text = _currentPost.oddMaxima;
      _oddMinima.text = _currentPost.oddMinima;
      _oddAtual.text = _currentPost.oddAtual;
      _unidades.text = _currentPost.unidade;
      _currentHorarioMaximo = _currentPost.horarioMaximo;
      _currentHorarioMinino = _currentPost.horarioMinimo;
      _esporte.text = _currentPost.esporte;
      _linha.text = _currentPost.linha;
      _link.text = _currentPost.link;
      _campeonato.text = _currentPost.campeonato;
    }
    _isBloqueadoPorDenuncias = FirebasePro.userPro.denuncias.length >= 5;
    if (_isBloqueadoPorDenuncias) {
      _setPostanto(true);//o botão ficará indisponível
    }
    _mostrarDicaInicial();
  }

  @override
  Widget build(BuildContext context) {
    var rowSpacing = Padding(padding: EdgeInsets.only(right: 5));
    _horarioMaximo.text = _currentHorarioMaximo;
    _horarioMinimo.text = _currentHorarioMinino;

    return WillPopScope(
      onWillPop: () async {
        _currentPost = _criarTip();
        Log.removeTooltip(iconAvancadoKey);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(Titles.POST_TIP),
          actions: [
            if (RunTime.semInternet)
              Layouts.icAlertInternet,
            IconButton(
              key: iconAvancadoKey,
              tooltip: _isAvancado ? 'Tip Avançado' : 'Tip Simples',
              icon: Icon(_isAvancado ? Icons.wb_incandescent : Icons.wb_incandescent_outlined),
              onPressed: _isAvancadoChanged,
            ),
            Tooltip(
              message: MyTexts.LIMPAR_TUDO,
              child: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () async {
                  _titulo = TextEditingController();
                  _anexo = TextEditingController();
                  _descricao = TextEditingController();
                  _oddMaxima = TextEditingController();
                  _oddMinima = TextEditingController();
                  _oddAtual = TextEditingController();
                  _unidades = TextEditingController();
                  _horarioMaximo = TextEditingController();
                  _horarioMinimo = TextEditingController();
                  _esporte = TextEditingController();
                  _linha = TextEditingController();
                  _link = TextEditingController();
                  _campeonato = TextEditingController();
                  _isPublico = false;
                  _currentPost = null;
                  _foto = null;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(children: [
                if(_isAvancado)...[
                  //Titulo
                  _customTextField(_titulo, TextInputType.name, MyStrings.TITULO, inputAction: TextInputAction.done, valueIsEmpty: _tituloIsEmpty, onTap: () {setState(() {_tituloIsEmpty = false;});}),
                  //Anexo
                  _textFAnexo,
                  //Descrição
                  _textFDescricao,
                  //Odd
                  Row(children: [
                    //Minima
                    Expanded(child: _customTextField(_oddMinima, TextInputType.number, MyStrings.ODD_MINIMA)),
                    rowSpacing,
                    //Maxima
                    Expanded(child: _customTextField(_oddMaxima, TextInputType.number, MyStrings.ODD_MAXIMA)),
                  ]),
                  //Unidades
                  Row(children: [
                    //Odd Atual
                    Expanded(child: _customTextField(_oddAtual, TextInputType.number, MyStrings.ODD_ATUAL, valueIsEmpty: _oddAtualIsEmpty, onTap: () {setState(() {_oddAtualIsEmpty = false;});})),
                    rowSpacing,
                    //Unidades
                    Expanded(child: _customTextField(_unidades, TextInputType.number, MyStrings.UNIDADES, inputAction: TextInputAction.done, valueIsEmpty: _unidadesIsEmpty, onTap: () {setState(() {_unidadesIsEmpty = false;});})),
                  ]),
                  //Horarios
                  Row(children: [
                    //Minimo
                    Expanded(child: _customTextField(_horarioMinimo, TextInputType.number, MyTexts.HORARIO_MINIMO, readOnly: true, onTap: () async {
                      var result = await _setHorario(_currentHorarioMinino);
                      if (result != null) {
                        setState(() {
                          _currentHorarioMinino = result.format(context);
                        });
                      }
                    })),
                    rowSpacing,
                    //Maximo
                    Expanded(child: _customTextField(_horarioMaximo, TextInputType.number, MyTexts.HORARIO_MAXIMO, readOnly: true, onTap: () async {
                      var result = await _setHorario(_currentHorarioMaximo);
                      if (result != null) {
                        setState(() {
                          _currentHorarioMaximo = result.format(context);
                        });
                      }
                    })),
                  ]),
                  //Horarios Labels
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //Minimo
                        Expanded(child: Text(MyTexts.HORARIO_MINIMO_ENTRADA, textAlign: TextAlign.center)),
                        //Maximo
                        Expanded(child: Text(MyTexts.HORARIO_MAXIMO_ENTRADA, textAlign: TextAlign.center)),
                      ]),
                  //Esporte / Linha
                  Row(children: [
                    Expanded(child: _customTextField(_esporte, TextInputType.name, MyStrings.ESPORTE, valueIsEmpty: _esporteIsEmpty, onTap: () {setState(() {_esporteIsEmpty = false;});})),
                    rowSpacing,
                    Expanded(child: _customTextField(_linha, TextInputType.name, MyStrings.LINHA)),
                  ]),
                  //Link
                  _textFLink,
                  //Campeonato / Tip Publico
                  Row(children: [
                    Expanded(child: _customTextField(_campeonato, TextInputType.name, MyStrings.CAMPEONATO)),
                    rowSpacing,
                    Expanded(child: _cbPublico),
                  ]),
                ]
                else...[
                  _textFAnexo,
                  _textFLink,
                  _textFDescricao,
                  _cbPublico,
                ]
                // Divider(height: 70),
              ]),
            ),
            LinearProgressIndicator(value: _progressBarValue),
          ],
        ),
        floatingActionButton:  FloatingActionButton.extended(
          label: Text(MyStrings.POSTAR),
          backgroundColor: !_isPostando ? MyTheme.accent : Colors.black26,
          onPressed: !_isPostando ? () {
            _postManager();
          } : _isBloqueadoPorDenuncias ? () {
            Log.snackbar('Você tem muitas denúncias.\nEntre em contato com o suporte', isError: true);
          } : null,
        ),
      ),
    );
  }

  //endregion

  //region Metodos

  Widget _customTextField(TextEditingController _controller, TextInputType _inputType, String labelText, {bool valueIsEmpty = false, TextInputAction inputAction = TextInputAction.next, bool readOnly = false, void onTap()}) {
    //region Variaveis
    double itemPaddingValue = 10;
    double itemHeight = 50;

    var tintColor = MyTheme.darkModeOn ? MyTheme.cardColor2 : Color.fromRGBO(222, 229, 237, 1);

    //region Container que contem os textField
    var itemPadding = EdgeInsets.only(left: itemPaddingValue, right: itemPaddingValue, top: 7);
    var itemContentPadding = EdgeInsets.fromLTRB(12, 0, 12, 0);

    var itemlBorder = OutlineInputBorder(
      borderSide: BorderSide(color: MyTheme.transparentColor()),
    );
    var itemDecoration = BoxDecoration(
      color: tintColor,
      borderRadius: BorderRadius.all(Radius.circular(5)),
    );
    var itemTextStyle = TextStyle(color: MyTheme.textColorSpecial, fontSize: 14);
    var itemPrefixStyle = TextStyle(color: valueIsEmpty ? MyTheme.textColorError : null);
    //endregion

    //endregion

    return Container(
      height: itemHeight,
      margin: EdgeInsets.only(top: 10),
      padding: itemPadding,
      decoration: itemDecoration,
      child: TextField(
        textInputAction: inputAction,
        controller: _controller,
        readOnly: readOnly,
        keyboardType: _inputType,
        style: itemTextStyle,
        decoration: InputDecoration(
          contentPadding: itemContentPadding,
          enabledBorder: itemlBorder,
          focusedBorder: itemlBorder,
          labelStyle: itemPrefixStyle,
          labelText: labelText.toUpperCase(),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget get _textFAnexo {
    return _customTextField(_anexo, TextInputType.name, MyTexts.ANEXAR_IMAGEM, readOnly: true, valueIsEmpty: _anexoIsEmpty, onTap: () async {
      var file = await Navigate.to(context, CropImagePage());
      if(file != null && file is File && await file.exists()) {
        _foto = file;
        setState(() {
          _anexoIsEmpty = false;
          _anexo.text = path.basename(_foto.path);
        });
      }
    });
  }
  Widget get _textFLink {
    return _customTextField(_link, TextInputType.url, MyStrings.LINK,
        valueIsEmpty: _linkIsEmpty,
        onTap: () => setState(() {_linkIsEmpty = false;})
    );
  }
  Widget get _textFDescricao {
    return _customTextField(_descricao, TextInputType.multiline, MyStrings.DESCRICAO_TIPS,
        valueIsEmpty: _descricaoIsEmpty,
        onTap: () => setState(() {_descricaoIsEmpty = false;})
    );
  }
  Widget get _cbPublico {
    return CheckboxListTile(
        title: Text(MyTexts.TIP_PUBLICO),
        value: _isPublico,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (bool value) {
          setState(() {
            _isPublico = value;
          });
        }
    );
  }

  _mostrarDicaInicial() async {
    await Future.delayed(Duration(seconds: 1)); // espera um tempo pra tela ser montada
    Log.tooltip(context, iconAvancadoKey, 'Modo de edição');
  }

  Future<TimeOfDay> _setHorario(String currentItemData) async {
    DateTime atual;
    try {
      Log.d(TAG, 'setHorario currentItemData', currentItemData);
      atual = DateTime(1, 1, 1, DataHora.toHour(currentItemData), DataHora.toMinute(currentItemData));
    } catch(e) {
      Log.e(TAG, 'setHorario', e, currentItemData);
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
      _setInProgress(true);
      _setPostanto(true);
      if (await item.postar()) {
        if (_foto != null && _foto.existsSync())
          await _foto.delete();
        Navigator.pop(context);
      }
    }

    _setInProgress(false);
    _setPostanto(false);
  }
  Post _criarTip() {
    Post item = Post();
    item.id = randomString(10);
    item.horarioMaximo = _horarioMaximo.text;
    item.horarioMinimo = _horarioMinimo.text;
    item.linha = _linha.text;
    item.esporte = _esporte.text;
    item.campeonato = _campeonato.text;
    item.oddMaxima = _oddMaxima.text;
    item.oddMinima = _oddMinima.text;
    item.oddAtual = _oddAtual.text;
    item.unidade = _unidades.text;
    item.idTipster = FirebasePro.user.uid;
    item.titulo = _titulo.text;
    item.descricao = _descricao.text;
    item.link = _link.text;
    item.isPublico = _isPublico;
    item.data = DataHora.now();
    item.foto = _foto?.path;
    return item;
  }
  bool _verificar(Post item) {
    try{
      bool noError = true;
      setState(() {
        if(_isAvancado) {
          if (item.titulo.isEmpty) {
            _tituloIsEmpty = true;
            noError = false;
          }
          if (item.oddAtual.isEmpty) {
            _oddAtualIsEmpty = true;
            noError = false;
          }
          if (item.unidade.isEmpty) {
            _unidadesIsEmpty = true;
            noError = false;
          }
          if (item.esporte.isEmpty) {
            _esporteIsEmpty = true;
            noError = false;
          }
          if (item.link.isEmpty) {
            _linkIsEmpty = true;
            noError = false;
          }
        } else {
          if (item.descricao.isEmpty) {
            _descricaoIsEmpty = true;
            noError = false;
          }
        }

        if (item.foto.isEmpty) {
          _anexoIsEmpty = true;
          noError = false;
        }

      });
      return noError;
    } catch(e) {
      Log.e(TAG, '_criarTip', e);
      HapticFeedback.lightImpact();
//      _PatternVibrate();
      return false;
    }
  }

  _isAvancadoChanged() {
    setState(() {
      _isAvancado = !_isAvancado;
    });
    String dica = _isAvancado ? 'Tip Avançado' : 'Tip Simples';
    Log.tooltip(context, iconAvancadoKey, dica);
    Config.postAvancado = _isAvancado;
  }

  _setPostanto(bool b) {
    if(!mounted) return;
    setState(() {
      _isPostando = b;
    });
  }
  _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      _progressBarValue = b ? null : 0;
    });
  }

  //endregion

  /*_PatternVibrate() {
    HapticFeedback.mediumImpact();

    sleep(
      const Duration(milliseconds: 200),
    );

    HapticFeedback.mediumImpact();

    sleep(
      const Duration(milliseconds: 500),
    );

    HapticFeedback.mediumImpact();

    sleep(
      const Duration(milliseconds: 200),
    );
    HapticFeedback.mediumImpact();
  }*/

}