import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protips/auxiliar/config.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/auxiliar/input_formatter.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/pages/cadastro_telefone_page.dart';
import 'package:protips/pages/crop_page.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';
import 'package:protips/sub_pages/fragment_g_denuncias.dart';

class PerfilPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<PerfilPage> {

  //region Variaveis
  static const String TAG = 'MeuPerfilPage';
  String _fotoWeb = '';
  UploadTask uploadTask;
  bool inProgress = false;

  final picker = ImagePicker();
  final cropKey = GlobalKey<CropState>();
  File _fotoLocal;

  final _textFormatterPhone = TextInputFormatterPhone();
  final _textFormatterMoney = TextInputFormatterMoney();
  bool soliciteiSerTipster;

  //region TextEditingController
  TextEditingController _nome = TextEditingController();
  TextEditingController _tipName = TextEditingController();
  TextEditingController _telefone = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _nascimento = TextEditingController();
  TextEditingController _descricao = TextEditingController();
//  TextEditingController _precoPadrao = TextEditingController();
  TextEditingController _souUm = TextEditingController();

  bool _nomeIsEmpyt = false;
  bool _tipNameExixte = false;
  bool _tipNameIsEmpyt = false;
//  bool _nascimentoIsEmpyt = false;
  bool _nascimentoIdadeMinima = false;
  //endregion

  //region DropdownMenuItem
  List<DropdownMenuItem<String>> _dropDownEstados;
  List<DropdownMenuItem<String>> _dropDownPrivacidade;
  List<DropdownMenuItem<String>> _dropDownPrecos;
  String _currentPreco;
  String _currentEstado;
  String _currentPrivacidade;
  //endregion

  DateTime selectedDate;
  bool isPrimeiroLogin = true;
  String dateNascimentoValue;
  String souUm = ' ';

  UserPro userPro = FirebasePro.userPro;
  User user = FirebasePro.user;

  //endregion

  //region overrides

  @override
  void initState() {
    try {
      //region variaveis
      var dados = userPro.dados;

      _dropDownPrecos = Import.getDropDownMenuItems(GoogleProductsID.precos.values.toList());
      _dropDownPrivacidade = Import.getDropDownMenuItems(Arrays.privacidade);
      _dropDownEstados = Import.getDropDownMenuItems(Arrays.estados);

      _currentPrivacidade = Arrays.privacidade[dados.isPrivado ? 1 : 0];//0 = Publico
      souUm = !userPro.solicitacaoEmAndamento() ? dados.isTipster ? MyStrings.TIPSTER : MyStrings.FILIADO : MyTexts.EM_ANDAMENTO;

      dateNascimentoValue = dados.nascimento.toString();
      isPrimeiroLogin = dados.tipname.isEmpty;

      selectedDate = DateTime.tryParse(dateNascimentoValue) ?? DateTime.now();

      String nome = dados.nome;
      String foto = dados.foto;
      String email = dados.email;
      String phone = dados.telefone;
      String tipname = dados.tipname;
      String estado = dados.endereco.estado;
      String descricao = dados.descricao;
      String precoPadrao = dados.precoPadrao;
      if (nome.isEmpty) nome = user.displayName ?? '';
      if (foto.isEmpty) foto = user.photoURL ?? '';
      if (email.isEmpty) email = user.email ?? '';
      if (phone.isEmpty) phone = user.phoneNumber ?? '';
//    if (tipname.isEmpty) tipname = '';
//    if (descricao.isEmpty) descricao = '';

//    currentPhoto = foto;

      _nome.text = nome;
      _fotoWeb = foto;
      _email.text = email;
      _telefone.text = phone;
      _tipName.text = tipname;
      _descricao.text = descricao;
      //endregion
      if (precoPadrao.isEmpty)
        precoPadrao = GoogleProductsID.precos['10'];
      if (estado.isEmpty)
        estado = Arrays.estados[0];
      _currentEstado = estado;
      _currentPreco = precoPadrao;
    } catch(e) {
      Log.e(TAG, 'initState', e);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis
//    double widthScreen = MediaQuery.of(context).size.width;
    double containerMargin = 20;
    double itemPaddingValue = 10;

    //region Container que contem os textField
    var itemPadding = EdgeInsets.only(left: itemPaddingValue, right: itemPaddingValue);

    var itemMargin = EdgeInsets.only(top: containerMargin);
    var itemDecoration = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: MyTheme.primary,
    );
    //endregion

    _souUm.text = souUm;
    _nascimento.text = dateNascimentoValue;
    //endregion

    return WillPopScope(
      onWillPop: () async {
        bool back = true;
        if (isPrimeiroLogin) {
          back = await showDialog(//TODO
              context: context,
            builder: (context) => AlertDialog(
              title: Text('Você não concluiu seu cadastro'),
              content: Text('Deseja sair mesmo assim?'),
              actions: [
                FlatButton(child: Text('Não'), onPressed: () {
                  Navigator.pop(context, false);
                }),
                FlatButton(child: Text('Sim'), onPressed: () {
                  Navigator.pop(context, true);
                }),
              ],
            )
          );
        }
        return back;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(Titles.MEU_PERFIL),
          actions: [
            if (RunTime.semInternet)
              Layouts.icAlertInternet,
            FlatButton(
              child: Text(MyStrings.SALVAR,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              textColor: Colors.white,
              onPressed: !inProgress ? () {
                _salvarUserManager(context);
              } : null,
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              if(isPrimeiroLogin)
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: containerMargin),
                  decoration: itemDecoration,
                  child: Text('Conclua seu cadastro'.toUpperCase(),
                      style: TextStyle(color: Colors.white)),
                ),
              //Foto
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      width: 90,
                      height: 90,
//                    margin: EdgeInsets.only(bottom: 10),
                      child: Layouts.clipRRectFormatUser(
                        radius: 100,
                        child: GestureDetector(
                          child: _fotoLocal == null ?
                          Layouts.fotoUser(userPro.dados) :
                          Image.file(_fotoLocal),
                          onTap: () {
                            _openCropImage();
                          },
                        ),
                      )
                  ),
                  Padding(padding: EdgeInsets.only(right: 10)),
                  //Tipname
                  Expanded(child: _customTextField(
                      _tipName, TextInputType.name, MyStrings.TIP_NAME,
                      readOnly: !isPrimeiroLogin,
                      valueIsEmpty: _tipNameIsEmpyt,
                      tipNameExiste: _tipNameExixte,
                      onTap: () {
                        setState(() {
                          _tipNameIsEmpyt = false;
                          _tipNameExixte = false;
                        });
                      })),
                ],
              ),
              //Nome
              _customTextField(_nome, TextInputType.name, MyStrings.NOME, valueIsEmpty: _nomeIsEmpyt, onTap: () { setState(() {_nomeIsEmpyt = false;}); }),
              //Email
              _customTextField(_email, TextInputType.emailAddress, MyStrings.EMAIL, readOnly: true),
              //Telefone
              _customTextField(_telefone, TextInputType.phone, MyStrings.TELEFONE, /*readOnly: true, onTap: _onPhonePress*/),
              //Nascimento
              _customTextField(_nascimento, TextInputType.datetime, MyStrings.NASCIMENTO, dataIdadeMinima: _nascimentoIdadeMinima, readOnly: true,
                  onTap: () {
                    _nascimentoIdadeMinima = false;
                    _selectDate(context);
                  }),

              //Outros dados
              Container(
                margin: itemMargin,
                padding: itemPadding,
                alignment: Alignment.bottomLeft,
                child: Text('Outros dados', style: TextStyle(/*color: MyTheme.textSubtitleColor*/)),
              ),
              //Descrição
              _customTextField(_descricao, TextInputType.multiline, MyStrings.DESCRICAO_USER),
              //Sou Um
              _customTextField(_souUm, TextInputType.name, MyTexts.SOU_UM, readOnly: true),
              //Preco Padrao
              if (userPro.dados.isTipster)
                _customDropdownButton(_dropDownPrecos, _currentPreco, MyTexts.PRECO_PADRAO, onChanged: (value) {
                  setState(() {
                    _currentPreco = value;
                  });
                }),
              // //Estado
              _customDropdownButton(_dropDownEstados, _currentEstado, MyStrings.ESTADO,
                  onChanged: (String value) {
                    Log.d(TAG, 'DropDown', 'Selected item: $value');
                    setState(() {
                      _currentEstado = value;
                    });
                  }),
              // //Privacidade
              _customDropdownButton(_dropDownPrivacidade, _currentPrivacidade, MyStrings.PRIVACIDADE,
                  onChanged: (String value) {
                    Log.d(TAG, 'DropDown', 'Selected item: $value');
                    setState(() {
                      _currentPrivacidade = value;
                    });
                  }),
              //Denuncias
              if (userPro.denuncias.length > 0)
                GestureDetector(
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: containerMargin),
                      decoration: itemDecoration,
                      child: Text('Você tem ${userPro.denuncias.length} denúncias',
                          style: TextStyle(color: Colors.yellow)),
                    ),
                    onTap: () {
                      DialogBox.dialogOK(context,
                          content: [FragmentDenunciasG(userPro)],
                          contentPadding: EdgeInsets.zero
                      );
                    }
                ),
              //Button Sotilitar Ser Tipster
              if (!isPrimeiroLogin)
                GestureDetector(
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: containerMargin),
                    decoration: itemDecoration,
                    child: Text(
                        !userPro.solicitacaoEmAndamento() ? userPro.dados.isTipster ?
                        MyTexts.CANCELAR_CONTA_TIPSTER.toUpperCase() :
                        MyTexts.QUERO_SER_TIPSTER.toUpperCase() :
                        MyTexts.CANCELAR_SOLICITACAO.toUpperCase(),
                        style: TextStyle(color: Colors.white)
                    ),
                  ),
                  onTap: _solicitarAlterarCategoria,
                ),
            ],
          ),
        ),
        floatingActionButton: inProgress ? Container(
          margin: EdgeInsets.only(top: 70),
          child: CircularProgressIndicator(),
        ) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }

  //endregion

  //region Metodos

  Widget _customTextField(TextEditingController _controller, TextInputType _inputType, String prefixText, {void onTap(), bool readOnly = false, bool valueIsEmpty,  bool dataIdadeMinima, bool tipNameExiste, bool isMoeda = false, Widget suffixIcon}) {
    //region Variaveis
    double containerMarginTop = 10;
    double itemPaddingValue = 10;

    bool isPhone = _inputType == TextInputType.phone;
    //region Container que contem os textField
    var itemPadding = EdgeInsets.only(left: itemPaddingValue, right: itemPaddingValue, top: 5);
    var itemContentPadding = EdgeInsets.fromLTRB(12, 0, 12, 0);

    var itemTextStyle = TextStyle(color: MyTheme.textColorSpecial);
    var itemPrefixStyle = TextStyle();
    var itemPrefixStyleErro = TextStyle(color: MyTheme.textColorError);
    //endregion

    //endregion

    return Container(
      height: 50,
      margin: EdgeInsets.only(top: containerMarginTop),
      padding: itemPadding,
      child: TextField(
        controller: _controller,
        keyboardType: _inputType,
        style: itemTextStyle,
        readOnly: readOnly,
        inputFormatters: [
          if (isPhone) ...[
            FilteringTextInputFormatter.digitsOnly,
            _textFormatterPhone,
          ]
          else if (isMoeda) ...[
            FilteringTextInputFormatter.digitsOnly,
            _textFormatterMoney,
          ]
        ],
        decoration: InputDecoration(
          contentPadding: itemContentPadding,
          suffixIcon: suffixIcon,
          labelStyle: (valueIsEmpty??false) || (tipNameExiste ?? false) || (dataIdadeMinima??false) ? itemPrefixStyleErro : itemPrefixStyle,
          labelText: tipNameExiste == null ? (dataIdadeMinima ?? false ? prefixText + ' ' + MyTexts.IDADE_MINIMA : prefixText) : (tipNameExiste ? prefixText + ' ' + MyStrings.EXISTE : prefixText),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _customDropdownButton(List<DropdownMenuItem<String>> items, String _currenValue, String prefixText, {void onChanged(String value)}) {
    //region Variaveis
    double containerMarginTop = 10;
    double itemPaddingValue = 10;

    //region Container que contem os textField
    var itemPaddingDropDown = EdgeInsets.only(left: itemPaddingValue + 10, right: itemPaddingValue + 10);
    var itemMargin = EdgeInsets.only(top: containerMarginTop);

    //endregion

    //endregion

    return Container(
      margin: itemMargin,
      padding: itemPaddingDropDown,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Text(prefixText, /*style: TextStyle(color: MyTheme.textSubtitleColor)*/),
          ),
          DropdownButton(
            items: items,
            value: _currenValue,
            onChanged: onChanged,
            style: TextStyle(color: MyTheme.textColorSpecial),
          )
        ],
      ),
    );
  }


  void _salvarUserManager(BuildContext context) async {
    _setInProgress(true);
    _resetErros();

    var dados = _criarUser();
    if (await _verificarDados(dados)) {
      bool resultOK = await dados.salvar();
      if (resultOK) {
        userPro.dados = dados;
        await OfflineData.saveOfflineData();
        if (isPrimeiroLogin) {
          await dados.addIdentificador();
          Navigator.pop(context, true);
        }
      }
      String text = resultOK ? MyTexts.PERFIL_USER_SALVO : MyErros.PERFIL_USER_SALVO;
      Log.snackbar(text, isError: !resultOK);
      // Log.toast(text, isError: !resultOK);
      Log.d(TAG, 'Salvar', text);
    }

    _setInProgress(false);
  }

  void _resetErros() {
    if(!mounted) return;
    setState(() {
      _nomeIsEmpyt = false;
      _tipNameExixte = false;
      _tipNameIsEmpyt = false;
      _nascimentoIdadeMinima = false;
    });
  }

  ///TODO Implementar futuramente [onPhonePress]
  onPhonePress() async {
    var result = await Navigate.to(context, CadastroTelefonePage(numero: _telefone.text));
    if (result != null) {}
  }

  UserDados _criarUser() {
    DataHora data = DataHora();
    data.setData(_nascimento.text);

    UserDados dados = UserDados();
    dados.id = FirebasePro.user.uid;
    dados.nome = _nome.text;
    dados.email = _email.text;
    dados.tipname = _tipName.text;
    dados.nascimento = data;
    dados.foto = _fotoLocal == null ? _fotoWeb : _fotoLocal.path;
    dados.telefone = _telefone.text;
    dados.descricao = _descricao.text;
    dados.isPrivado = _currentPrivacidade == Arrays.privacidade[1];
    dados.endereco.estado = _currentEstado;
    dados.precoPadrao = _currentPreco;

    dados.isTipster = userPro.dados.isTipster;
    dados.isBloqueado = userPro.dados.isBloqueado;
    return dados;
  }

  Future<bool> _verificarDados(UserDados dados) async {
    bool voltar = false;
    if(!mounted) return false;
    setState(() {
      if (dados.nome.trim().isEmpty) {
        voltar = _nomeIsEmpyt = true;
      }
      if (dados.tipname.trim().isEmpty) {
        voltar = _tipNameIsEmpyt = true;
      }

      if (dados.nascimento.idade() < 18) {
        voltar = _nascimentoIdadeMinima = true;
      }
    });
    if (voltar) {
      HapticFeedback.lightImpact();
      return false;
    }
    if (isPrimeiroLogin) {
      var resultOK = await _verificarTipname(dados.tipname);
      if (resultOK) {
        setState(() {
          _tipNameExixte = true;
        });
        HapticFeedback.lightImpact();
        return false;
      }
    }
      return true;
  }

  Future<bool> _verificarTipname(String tipName) async {
    return await FirebasePro.database
        .child(FirebaseChild.IDENTIFICADOR)
        .child(tipName)
        .once()
        .then((value) => value.value != null)
        .catchError((e) {
          Log.e(TAG, 'verificarTipname', e);
          return false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    var lastDate = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1950),
        lastDate: DateTime(lastDate.year, lastDate.month, lastDate.day)
    );
    if (picked != null)
      setState(() {
        selectedDate = picked;
        String data = selectedDate.toString();
        dateNascimentoValue = data.substring(0, data.indexOf(' '));
        Log.d(TAG, '_selectDate', dateNascimentoValue);
      });
  }

  void _openCropImage() async {
     var result = await Navigate.to(context, CropImagePage(1/1));
     if (result == null) {
       Log.d(TAG, '_openCropImage', 'result Null');
       return;
     } else if (result is File) {
       setState(() {
         _fotoLocal = result;
       });
       Log.d(TAG, '_openCropImage result OK', result.path);
     } else {
       Log.d(TAG, '_openCropImage', 'result Error');
     }
  }

  void _solicitarAlterarCategoria() {
    bool b = userPro.solicitacaoEmAndamento();
    if (userPro.dados.isTipster && !b) {
      _solicitarSerFiliado();
    } else {
      _solicitarSerTipster(b);
    }
  }


  void _solicitarSerFiliado() async {
    var title = '${MyTexts.solicitacao_filiado}?';
    var content = Text(MyTexts.solicitacao_filiado_mensagem);

    var result = await DialogBox.dialogSimNao(context, title: title, content: [content]);

    if (result.isPositive) {
      _setInProgress(true);
      if (await userPro.habilitarTipster(false)) {
        getTipster.remove(userPro.dados.id);
        getPosts.removeAll(userPro.dados.id);
      }
      _setInProgress(false);

      if(!mounted) return;
      setState(() {
        souUm = MyStrings.FILIADO;
      });
    }
  }

  void _solicitarSerTipster(final bool solicitei) async {
    String title = MyTexts.solicitacao_tipster;
    String mensagem = MyTexts.solicitacao_tipster_mensagem;
    String whatsapp = MyResources.app_whatsapp;
    String email = MyResources.app_email;

    var content = [
        Text(mensagem),
        GestureDetector(
          child: Text(email, style: TextStyle(color: MyTheme.primary)),
          onTap: () {Import.openEmail(email, context);},
        ),
        Text(MyStrings.whatsapp),
        GestureDetector(
          child: Text(whatsapp, style: TextStyle(color: MyTheme.primary)),
          onTap: () {Import.openWhatsApp(whatsapp, context);},
        ),
        if (solicitei)...[
          Divider(),
          Text('Clique em (Cancelar) para cancelar sua solicitação'),
        ]
      ];

    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);

    _setInProgress(true);
    if (result.isPositive)
      await solicitacao(solicitei);
    else if (result.isNegative)
      await solicitacaoCancelar(solicitei);
    _setInProgress(false);
  }

  Future<void> solicitacao(bool solicitei) async {
    if (!solicitei)
      if (await userPro.solicitarSerTipster()) {
        if (!mounted) return;
          setState(() {
            soliciteiSerTipster = true;
          });
      }
  }

  Future<void> solicitacaoCancelar(bool solicitei) async {
    if (solicitei)
     if (await userPro.solicitarSerTipsterCancelar()) {
       if(!mounted) return;
        setState(() {
          soliciteiSerTipster = false;
        });
     }
  }

  void _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      inProgress = b;
    });
  }

  //endregion

}
