import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/auxiliar/input_formatter.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/user.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/pages/crop_page.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/resources.dart';
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
  StorageUploadTask uploadTask;
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
  List<DropdownMenuItem<String>> _precos;
  String _currentPreco;
  String _currentEstado;
  String _currentPrivacidade;
  //endregion

  DateTime selectedDate;
  bool isPrimeiroLogin = true;
  String dateNascimentoValue;
  String souUm = ' ';

  User user = Firebase.user;
  FirebaseUser fUser = Firebase.fUser;

  //endregion

  //region overrides

  @override
  void initState() {
    //region variaveis
    var dados = user.dados;

    _precos = Import.getDropDownMenuItems(GoogleProductsID.precos.values.toList());
    _dropDownEstados = Import.getDropDownMenuItems(Arrays.estados);
    _dropDownPrivacidade = Import.getDropDownMenuItems(Arrays.privacidade);
    _currentEstado = dados.endereco.estado;
    _currentPrivacidade = _dropDownPrivacidade[dados.isPrivado ? 1 : 0].value;//0 = Publico
    souUm = !user.solicitacaoEmAndamento() ? dados.isTipster ? MyStrings.TIPSTER : MyStrings.FILIADO : MyTexts.EM_ANDAMENTO;

    dateNascimentoValue = dados.nascimento.toString();
    isPrimeiroLogin = dados.tipname.isEmpty;

    selectedDate = DateTime.tryParse(dateNascimentoValue) ?? DateTime.now();

    String nome = dados.nome;
    String foto = dados.foto;
    String email = dados.email;
    String phone = dados.telefone;
    String tipname = dados.tipname;
    String descricao = dados.descricao;
    String precoPadrao = dados.precoPadrao;
    if (nome.isEmpty) nome = fUser.displayName ?? '';
    if (foto.isEmpty) foto = fUser.photoUrl ?? '';
    if (email.isEmpty) email = fUser.email ?? '';
    if (phone.isEmpty) phone = fUser.phoneNumber ?? '';
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
    _currentPreco = precoPadrao;
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
        color: MyTheme.primary(),
    );
    //endregion

    _souUm.text = souUm;
    _nascimento.text = dateNascimentoValue;
    //endregion

    return WillPopScope(
      onWillPop: () async {
        bool back = true;
        if (isPrimeiroLogin) {
          back = await showDialog(
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
          title: Text(Titles.MEU_PERFIL, style: TextStyle(
              color: MyTheme.textColor(), fontWeight: FontWeight.bold)),
          actions: [
            FlatButton(
              child: Text(MyStrings.SALVAR,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              textColor: MyTheme.textColor(),
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
                      child: MyLayouts.iconFormatUser(
                        radius: 100,
                        child: GestureDetector(
                          child: _fotoLocal == null ?
                          MyLayouts.fotoUser(user.dados) :
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
              _customTextField(_telefone, TextInputType.phone, MyStrings.TELEFONE),
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
                child: Text('Outros dados'),
              ),
              //Descrição
              _customTextField(_descricao, TextInputType.multiline, MyStrings.DESCRICAO),
              //Sou Um
              _customTextField(_souUm, TextInputType.name, MyTexts.SOU_UM, readOnly: true),
              //Preco Padrao
              if (user.dados.isTipster)
                _customDropdownButton(_precos, _currentPreco, MyTexts.PRECO_PADRAO, onChanged: (value) {
                  setState(() {
                    _currentPreco = value;
                  });
                }),
//                _customTextField(_precoPadrao, TextInputType.number, MyTexts.PRECO_PADRAO, isMoeda: true,
//                    suffixIcon: IconButton(
//                      tooltip: 'Info',
//                      icon: Icon(Icons.info, color: MyTheme.primary()),
//                      onPressed: () {
//                        var title = 'Este é um preço padrão';
//                        var content = Text('Você poderá atribuir preços diferentes para cada filiado como desejar.');
//                        MyLayouts.dialogOK(context, title: title, content: content);
//                      },
//                )),
              //Estado
              _customDropdownButton(_dropDownEstados, _currentEstado, MyStrings.ESTADO,
                  onChanged: (String value) {
                    Log.d(TAG, 'DropDown', 'Selected item: $value');
                    setState(() {
                      _currentEstado = value;
                    });
                  }),
              //Privacidade
              _customDropdownButton(_dropDownPrivacidade, _currentPrivacidade, MyStrings.PRIVACIDADE,
                  onChanged: (String value) {
                    Log.d(TAG, 'DropDown', 'Selected item: $value');
                    setState(() {
                      _currentPrivacidade = value;
                    });
                  }),
              //Denuncias
              if (user.denuncias.length > 0)
                GestureDetector(
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: containerMargin),
                      decoration: itemDecoration,
                      child: Text('Você tem ${user.denuncias.length} denúncias',
                          style: TextStyle(color: Colors.yellow)),
                    ),
                    onTap: () {
                      DialogBox.dialogOK(context,
                          content: FragmentDenunciasG(user),
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
                        !user.solicitacaoEmAndamento() ? user.dados
                            .isTipster ?
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
        ) : Container(),
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

//    var itemlBorder = OutlineInputBorder(borderSide: BorderSide(color: MyTheme.tintColor()));
//    var itemDecoration = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: MyTheme.tintColor(),);
    var itemTextStyle = TextStyle(color: MyTheme.primaryDark());
    var itemPrefixStyle = TextStyle(color: MyTheme.textColorInvert());
    var itemPrefixStyleErro = TextStyle(color: MyTheme.textColorError());
    //endregion

    //endregion

    return Container(
      height: 50,
      margin: EdgeInsets.only(top: containerMarginTop),
      padding: itemPadding,
//      decoration: itemDecoration,
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
//          enabledBorder: itemlBorder,
//          focusedBorder: itemlBorder,
          suffixIcon: suffixIcon,
          labelStyle: (valueIsEmpty??false) || (tipNameExiste??false) || (dataIdadeMinima??false) ? itemPrefixStyleErro : itemPrefixStyle,
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
          Text(prefixText + '\t'),
          DropdownButton(
            items: items,
            value: _currenValue,
            onChanged: onChanged,
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
        user.dados = dados;
//        getFirebase.setUser(user);
        await OfflineData.saveOfflineData();
//        currentPhoto = user.dados.foto;
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
    setState(() {
      _nomeIsEmpyt = false;
      _tipNameExixte = false;
      _tipNameIsEmpyt = false;
      _nascimentoIdadeMinima = false;
    });
  }

  UserDados _criarUser() {
    DataHora data = DataHora();
    data.setData(_nascimento.text);

    UserDados dados = UserDados();
    dados.id = Firebase.fUser.uid;
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

    dados.isTipster = user.dados.isTipster;
    dados.isBloqueado = user.dados.isBloqueado;
    return dados;
  }

  Future<bool> _verificarDados(UserDados dados) async {
    bool voltar = false;
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
    return await Firebase.databaseReference
        .child(FirebaseChild.IDENTIFICADOR)
        .child(tipName)
        .once()
        .then((value) => value.value != null)
        .catchError((e) => null);
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

     setState(() {
       if (result == null) {
         Log.d(TAG, '_openCropImage', 'result Null');
         return;
       } else if (result is File) {
         Log.d(TAG, '_openCropImage result OK', result.path);
         _fotoLocal = result;
       } else {
         Log.d(TAG, '_openCropImage', 'result Error');
       }
     });
  }

  void _solicitarAlterarCategoria() {
    bool b = user.solicitacaoEmAndamento();
    if (user.dados.isTipster && !b) {
      _solicitarSerFiliado();
    } else {
      _solicitarSerTipster(b);
    }
  }


  void _solicitarSerFiliado() async {
    var title = MyTexts.solicitacao_filiado;
    var content = Text(MyTexts.solicitacao_filiado_mensagem);

    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);

    if (result.isOk) {
      if (await user.habilitarTipster(false)) {
        getTipster.remove(user.dados.id);
        getPosts.removeAll(user.dados.id);
      }
      try {
        setState(() {
          souUm = MyStrings.FILIADO;
        });
      } catch(ignored) {}
    }
  }

  void _solicitarSerTipster(final bool solicitei) async {
    String title = MyTexts.solicitacao_tipster;
    String mensagem = MyTexts.solicitacao_tipster_mensagem;
    String whatsapp = MyResources.app_whatsapp;
    String email = MyResources.app_email;

    var content = SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Text(mensagem),
          GestureDetector(
            child: Text(email, style: TextStyle(color: MyTheme.primary())),
            onTap: () {Import.openEmail(email, context);},
          ),
          Text(MyStrings.whatsapp),
          GestureDetector(
            child: Text(whatsapp, style: TextStyle(color: MyTheme.primary())),
            onTap: () {Import.openWhatsApp(whatsapp, context);},
          )
        ],
      ),
    );

    var result = await DialogBox.dialogCancelOK(context, title: title, content: content);

    if (result.isOk)
      solicitacao(solicitei);
    else if (result.isCancel)
      solicitacaoCancelar(solicitei);
  }

  Future<void> solicitacao(bool solicitei) async{
    if (!solicitei)
       if (await user.solicitarSerTipster())
         try {
           setState(() {
             soliciteiSerTipster = true;
           });
         } catch(ignored) {}
  }

  Future<void> solicitacaoCancelar(bool solicitei) async {
    if (solicitei)
     if (await user.solicitarSerTipsterCancelar())
        setState(() {
          soliciteiSerTipster = false;
        });
  }

  void _setInProgress(bool b) {
    try {
      setState(() {
        inProgress = b;
      });
    } catch(ignored) {}
  }

  //endregion

}
