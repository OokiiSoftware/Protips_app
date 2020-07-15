import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data.dart';
import 'package:protips/model/user.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/pages/crop_page.dart';
import 'package:protips/res/resources.dart';

class MeuPerfilPage extends StatefulWidget {
  static const String tag = 'MeuPerfilPage';
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<MeuPerfilPage> {

  //region Variaveis
  static const String TAG = 'MeuPerfilPage';
  String currentPhoto = '';
  String _fotoWeb = '';
  StorageUploadTask uploadTask;
  double progressBarValue = 0;
  LinearProgressIndicator progressBar;

  final picker = ImagePicker();
  final cropKey = GlobalKey<CropState>();
  File _fotoLocal;

  bool soliciteiSerTipster;

  //region TextEditingController
  TextEditingController _nome = TextEditingController();
  TextEditingController _tipName = TextEditingController();
  TextEditingController _telefone = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _nascimento = TextEditingController();
  TextEditingController _descricao = TextEditingController();
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
  String _currentEstado;
  String _currentPrivacidade;
  //endregion

  DateTime selectedDate;
  bool isPrimeiroLogin = true;
  String dateNascimentoValue;
  String souUm = ' ';

  User user = getFirebase.user();
  FirebaseUser fUser = getFirebase.fUser();

  //endregion

  //region overrides

  @override
  void initState() {
    _dropDownEstados = Import.getDropDownMenuItems(Arrays.estados);
    _dropDownPrivacidade = Import.getDropDownMenuItems(Arrays.privacidade);
    _currentEstado = _dropDownEstados[8].value;//8 = Maranhão
    _currentPrivacidade = _dropDownPrivacidade[0].value;//0 = Publico
    souUm = !user.solicitacaoEmAndamento() ? user.dados.isTipster ? MyStrings.TIPSTER : MyStrings.FILIADO : MyStrings.EM_ANDAMENTO;

    dateNascimentoValue = user.dados.nascimento.toString();
    isPrimeiroLogin = user.dados.tipname.isEmpty;

    selectedDate = DateTime.tryParse(dateNascimentoValue) ?? DateTime.now();

    String nome = user.dados.nome;
    String foto = user.dados.foto;
    String email = user.dados.email;
    String phone = user.dados.telefone;
    String tipname = user.dados.tipname;
    String descricao = user.dados.descricao;
    if (nome.isEmpty) nome = fUser.displayName ?? '';
    if (foto.isEmpty) foto = fUser.photoUrl ?? '';
    if (email.isEmpty) email = fUser.email ?? '';
    if (phone.isEmpty) phone = fUser.phoneNumber ?? '';
    if (tipname.isEmpty) tipname = '';
    if (descricao.isEmpty) descricao = '';

    currentPhoto = foto;

    _nome.text = nome;
    _fotoWeb = foto;
    _email.text = email;
    _telefone.text = phone;
    _tipName.text = tipname;
    _descricao.text = descricao;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis
    double widthScreen = MediaQuery.of(context).size.width;
    double containerPadding = 30;
    double _containerPaddingTop = 0;
    double itemPaddingValue = 10;

    //region Container que contem os textField
    var silverPadding = EdgeInsets.only(top: 15, bottom: 15);
    var itemPadding = EdgeInsets.only(left: itemPaddingValue, right: itemPaddingValue);

    var itemMargin = EdgeInsets.only(left: containerPadding, right: containerPadding);
    var itemDecoration = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: MyTheme.tintColor(),
        boxShadow: [BoxShadow(color: Colors.white, blurRadius: 3)]
    );
    //endregion

    progressBar = LinearProgressIndicator(value: progressBarValue);

    _souUm.text = souUm;
    _nascimento.text = dateNascimentoValue;
    //endregion

    return Scaffold(
      body: Container(
        color: MyTheme.primaryLight(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: widthScreen,
              title: Text(Titles.MEU_PERFIL, style: TextStyle(color: MyTheme.textColor(), fontWeight: FontWeight.bold)),
              //Foto ◢◤
              flexibleSpace: FlexibleSpaceBar(
                  stretchModes: <StretchMode>[
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                    StretchMode.fadeTitle,
                  ],
                //Foto
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      child: _fotoLocal == null ?
                      _fotoWeb.isEmpty ?
                      Image.asset(MyIcons.ic_person) :
                      Image.network(
                          _fotoWeb,
                          fit: BoxFit.cover,
                          errorBuilder: (c, u, e) => Image.asset(MyIcons.ic_person)
                      ) :
                      Image.file(_fotoLocal, fit: BoxFit.cover),
                      onTap: _openCropImage,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.center,
                          colors: <Color>[
                            Color(0x30000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.center,
                          colors: <Color>[
                            Color(0x30000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                //Botão salvar
                title: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    child: FlatButton(
                      child: Text(MyStrings.SALVAR, style: TextStyle(fontWeight: FontWeight.bold)),
                      textColor: MyTheme.textColor(),
                      onPressed: () {
                        salvarUserManager(context);
                      },
                    ),
                  ),
                )
              ),
            ),
            //ProgressBar
            SliverPadding(
              padding: EdgeInsets.all(0),
              sliver: SliverGrid.count(
                crossAxisCount: 1,
                childAspectRatio: 90,
                children: [
                  progressBar
                ],
              ),
            ),
            SliverPadding(
              padding: silverPadding,
              sliver: SliverGrid.count(
                crossAxisCount: 1,
                childAspectRatio: 8,
                mainAxisSpacing: 8,
                children: [
                  CustomTextField(_nome, TextInputType.name, MyStrings.NOME, valueIsEmpty: _nomeIsEmpyt, onTap: () {
                    setState(() {
                      _nomeIsEmpyt = false;
                    });
                  }),
                  CustomTextField(_tipName, TextInputType.name, MyStrings.TIP_NAME, readOnly: !isPrimeiroLogin, valueIsEmpty: _tipNameIsEmpyt, tipNameExiste: _tipNameExixte, onTap: () {
                    setState(() {
                      _tipNameIsEmpyt = false;
                      _tipNameExixte = false;
                    });
                  }),
                  CustomTextField(_email, TextInputType.emailAddress, MyStrings.EMAIL, readOnly: true),
                  CustomTextField(_telefone, TextInputType.phone, MyStrings.TELEFONE),
                  CustomTextField(_nascimento, TextInputType.datetime, MyStrings.NASCIMENTO, dataIdadeMinima: _nascimentoIdadeMinima, onTap: () {
                    _nascimentoIdadeMinima = false;
                    _selectDate(context);
                  }),
                  //Nascimento
                  /*Container(
                    margin: itemMargin,
                    padding: itemPadding,
                    decoration: itemDecoration,
                    child: TextField(
                      controller: _nascimento,
                      keyboardType: TextInputType.datetime,
                      style: itemTextStyle,
                      readOnly: true,
                      decoration: InputDecoration(
                        enabledBorder: itemlBorder,
                        focusedBorder: itemlBorder,
                        prefixStyle: _nascimentoIsEmpyt ? itemPrefixStyleErro : itemPrefixStyle,
                        prefixText: MyStrings.NASCIMENTO + '\t',
                        labelText: _nascimentoIdadeMinima ? MyStrings.IDADE_MINIMA : null,
                      ),
                      onTap: () {
                        _nascimentoIdadeMinima = false;
                        _nascimentoIsEmpyt = false;
                        _selectDate(context);
                      },
                    ),
                  ),*/
                  //Estado
                  CustomDropdownButton(_dropDownEstados, _currentEstado, MyStrings.ESTADO),
                  //Privacidade
                  CustomDropdownButton(_dropDownPrivacidade, _currentPrivacidade, MyStrings.PRIVACIDADE),

                  //Outros dados
                  Container(
                    margin: itemMargin,
                    padding: itemPadding,
                    alignment: Alignment.bottomLeft,
                    child: Text('Outros dados'),
                  ),
                  //Descrição
                  CustomTextField(_descricao, TextInputType.multiline, MyStrings.DESCRICAO),
                  //Sou Um
                  CustomTextField(_souUm, TextInputType.name, MyStrings.SOU_UM),

                  //Button
                  Container(
                    margin: EdgeInsets.fromLTRB(containerPadding, 0, containerPadding, _containerPaddingTop),

                    decoration: itemDecoration,
                    child: ButtonTheme(
                      child: FlatButton(
                        child: Text(
                            !user.solicitacaoEmAndamento() ? user.dados.isTipster ?
                            MyStrings.QUERO_SER_FILIADO.toUpperCase() :
                            MyStrings.QUERO_SER_TIPSTER.toUpperCase() :
                            MyStrings.CANCELAR_SOLICITACAO.toUpperCase()
                        ),
                        onPressed: _solicitarAlterarCategoria,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //endregion

  //region Metodos

  Widget CustomTextField(TextEditingController _controller, TextInputType _inputType, String prefixText, {void onTap(), bool readOnly = false, bool valueIsEmpty,  bool dataIdadeMinima, bool tipNameExiste}) {
    //region Variaveis
    double containerPadding = 30;
    double _containerPaddingTop = 0;
    double itemPaddingValue = 10;

    //region Container que contem os textField
    var itemPadding = EdgeInsets.only(left: itemPaddingValue, right: itemPaddingValue, top: 10);

    var itemlBorder = OutlineInputBorder(borderSide: BorderSide(color: MyTheme.tintColor()));
    var itemDecoration = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: MyTheme.tintColor(),);
    var itemTextStyle = TextStyle(color: MyTheme.primaryDark());
    var itemPrefixStyle = TextStyle(color: MyTheme.textColorInvert());
    var itemPrefixStyleErro = TextStyle(color: MyTheme.textColorError());
    //endregion

    //endregion

    return Container(
      margin: EdgeInsets.fromLTRB(containerPadding, _containerPaddingTop, containerPadding, 0),
      padding: itemPadding,
      decoration: itemDecoration,
      child: TextField(
        controller: _controller,
        keyboardType: _inputType,
        style: itemTextStyle,
        readOnly: readOnly,
        decoration: InputDecoration(
          enabledBorder: itemlBorder,
          focusedBorder: itemlBorder,
          labelStyle: (valueIsEmpty??false) || (tipNameExiste??false) || (dataIdadeMinima??false) ? itemPrefixStyleErro : itemPrefixStyle,
          labelText: tipNameExiste == null ? (dataIdadeMinima ?? false ? prefixText + ' ' + MyStrings.IDADE_MINIMA : prefixText) : (tipNameExiste ? prefixText + ' ' + MyStrings.EXISTE : prefixText),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget CustomDropdownButton(List<DropdownMenuItem<String>> items, String _currenValue, String prefixText) {
    //region Variaveis
    double containerPadding = 30;
    double itemPaddingValue = 10;

    //region Container que contem os textField
    var itemPaddingDropDown = EdgeInsets.only(left: itemPaddingValue + 10, right: itemPaddingValue + 10);

    var itemMargin = EdgeInsets.only(left: containerPadding, right: containerPadding);
    var itemDecoration = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: MyTheme.tintColor(),
        boxShadow: [BoxShadow(color: Colors.white, blurRadius: 3)]
    );
    //endregion

    //endregion

    return Container(
      margin: itemMargin,
      padding: itemPaddingDropDown,
      decoration: itemDecoration,
      child: Row(
        children: [
          Text(prefixText + '\t'),
          DropdownButton(
            items: items,
            value: _currenValue,
            onChanged: (String value) {
              Log.d(TAG, 'DropDown', 'Selected item: $value');
              setState(() {
                _currenValue = value;
              });
            },
          )
        ],
      ),
    );
  }


  salvarUserManager(BuildContext context) async {
    _progressBarState(true);
    _resetErros();

    var dados = _criarUser();
    if (await _verificarDados(dados)) {
      bool resultOK = await dados.salvar(context);
      if (resultOK) {
        user.dados = dados;
        getFirebase.setUser(user, true);
        currentPhoto = user.dados.foto;
        if (isPrimeiroLogin) {
          await dados.addIdentificador();
          Navigator.pop(context, true);
        }
      }
      String text = resultOK ? MyStrings.MSG_USUARIO_SALVO : MyStrings.MSG_USUARIO_SALVO_ERRO;
      Log.d(TAG, 'Salvar', text);
    }

    _progressBarState(false);
  }

  _resetErros() {
    setState(() {
      _nomeIsEmpyt = false;
      _tipNameExixte = false;
      _tipNameIsEmpyt = false;
      _nascimentoIdadeMinima = false;
    });
  }

  UserDados _criarUser() {
    Data data = Data();
    data.setData(_nascimento.text);

    UserDados dados = UserDados();
    dados.id = getFirebase.fUser().uid;
    dados.nome = _nome.text;
    dados.email = _email.text;
    dados.tipname = _tipName.text;
    dados.nascimento = data;
    dados.foto = _fotoLocal == null ? _fotoWeb : _fotoLocal.path;
    dados.telefone = _telefone.text;
    dados.descricao = _descricao.text;
    dados.isPrivado = _currentPrivacidade == Arrays.privacidade[1];
    dados.endereco.estado = _currentEstado;

    dados.tags = user.dados.tags;
    dados.isTipster = user.dados.isTipster;
    dados.bloqueado = user.dados.bloqueado;
    return dados;
  }

  Future<bool> _verificarDados(UserDados dados) async {
    bool voltar = false;
    setState(() {
      if (dados.nome.trim().isEmpty) {
        voltar = _nomeIsEmpyt = true;
        return;
      }
      if (dados.tipname.trim().isEmpty) {
        voltar = _tipNameIsEmpyt = true;
        return;
      }

      if (dados.nascimento.idade() < 18) {
        voltar = _nascimentoIdadeMinima = true;
        return;
      }
    });
    if (voltar)
      return false;
    if (isPrimeiroLogin) {
      var resultOK = await _verificarTipname(dados.tipname);
      if (resultOK) {
        setState(() {
          _tipNameExixte = true;
        });
        return false;
      }
    }
      return true;
  }

  Future<bool> _verificarTipname(String tipName) async {
    return await getFirebase.databaseReference()
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

  _openCropImage() async {
     var result = await Navigator.of(context).pushNamed(CropImagePage.tag, arguments: 1/1);

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

    } else {
      _solicitarSerTipster(b);
    }
  }



  void _solicitarSerTipster(final bool solicitei) {
    String title = MyStrings.solicitacao_tipster;
    String mensagem = MyStrings.solicitacao_tipster_mensagem;

    String okButton = solicitei ? MyStrings.OK : MyStrings.SOLICITAR;
    String cancelButton = solicitei ? MyStrings.CANCELAR_SOLICITACAO : MyStrings.CANCELAR;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(mensagem),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(cancelButton),
                onPressed: () {
                  solicitacaoCancelar(solicitei);
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(okButton),
                onPressed: () {
                  solicitacao(solicitei);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  Future<void> solicitacao(bool solicitei) async{
    if (!solicitei)
       if (await user.solicitarSerTipster())
        setState(() {
          soliciteiSerTipster = true;
        });
  }

  Future<void> solicitacaoCancelar(bool solicitei) async {
    if (solicitei)
     if (await user.solicitarSerTipsterCancelar())
        setState(() {
          soliciteiSerTipster = false;
        });
  }

  _progressBarState(bool ativo) {
    setState(() {
      //Desativa o movimento da barra
      progressBarValue = ativo ? null : 0;
    });
  }

  //endregion

}