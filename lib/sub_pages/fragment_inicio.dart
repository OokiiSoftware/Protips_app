import 'package:flutter/material.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/pages/denuncia_page.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/my_icons.dart';
import 'package:protips/res/strings.dart';

class FragmentInicio extends StatefulWidget {
  final UserPro user;
  FragmentInicio({this.user});
  @override
  State<StatefulWidget> createState() => MyWidgetState(user: user);
}
class MyWidgetState extends State<FragmentInicio> with AutomaticKeepAliveClientMixin<FragmentInicio> {

  MyWidgetState({this.user});

  //region Variaveis
  static const String TAG = 'FragmentInicio';

  UserPro user;
  List<Post> data;

  bool _inProgress = false;
  bool _isMainPage = false;
  DateTime _dateTime;

  GlobalKey _scaffKey = GlobalKey();
  double _widgetCenter = 0;
  //endregion

  //region overrides

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    data = List<Post>();
    _isMainPage = user == null;
    _preencherLista();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_widgetCenter == 0)
      _setInfoCenter();

    return Scaffold(
      key: _scaffKey,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: data.length == 0 ?
        ListView(
          padding: EdgeInsets.only(top: _widgetCenter),
          children: [
            if (_widgetCenter != 0)
              _infoSemTips
          ]
        ) :
        ListView.builder(
            itemCount: data.length,
            padding: EdgeInsets.only(bottom: 70),
            itemBuilder: (BuildContext context, int index) {
              final item = data[index];
              return itemLayout(item);
            }
        ),
      ),
      floatingActionButton: _inProgress ? CircularProgressIndicator() :
      user == null ?
      FloatingActionButton.extended(
          label: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.calendar_today),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(_dateTime.day.toString()),
              )
            ],
          ),
          onPressed: _onFloatingAtionPressed
      ) : null,
      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  //endregion

  //region Metodos

  Widget get _infoSemTips {
    String mainPageText = 'Você não possui tips no dia selecionado. Siga ou filie-se a um tipster para obte-las.';
    String myTipsterText = 'Este Tipster não possui publicações no momento';
    String semTipsPublicasText = 'Esse tipster não possui tips públicas. Filie-se para ter acesso às suas tips privadas.';
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            MyIcons.ic_info,
            width: 140,
          ),
          Padding(padding: EdgeInsets.all(15)),
          Text(
            _isMainPage ? mainPageText :
            user.isMyTipster ? myTipsterText :
            semTipsPublicasText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }

  // Posiciona a msg "sem tips" no centro do widget
  _setInfoCenter() async {
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _widgetCenter = _scaffKey.currentContext.size.height / 4;
    });
  }

  Widget itemLayout(Post item) {
    String meuId = FirebasePro.user.uid;

    return Layouts.post(context, item, _isMainPage, _onMenuItemPostCliked,
      onGreenTap: () async {
        _setInProgress(true);
        if (item.bom.containsKey(meuId))
          await item.removeBom(meuId);
        else
          await item.addBom(meuId);
        _setInProgress(false);
        setState(() {});
      },
      onRedtap: () async {
        _setInProgress(true);
        if (item.ruim.containsKey(meuId))
          await item.removeRuim(meuId);
        else
          await item.addRuim(meuId);
        _setInProgress(false);
        setState(() {});
      }
    );
  }

  Future<void> _onRefresh() async {
    await UserPro.baixarList();
    if (!_isMainPage)
      user = await getUsers.get(user.dados.id);
    _preencherLista();
    setState(() {});
  }

  _onMenuItemPostCliked(String value, Post post) {
    switch(value) {
      case MyMenus.ABRIR_LINK:
        Import.openUrl(post.link, context);
        break;
      case MyMenus.EXCLUIR:
        _onDelete(post);
        break;
      case MyMenus.DENUNCIAR:
        Navigate.to(context, DenunciaPage.Post(post));
        break;
    }
  }

  _onFloatingAtionPressed() async {
    var lastDate = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        // locale: Aplication.locale,
        initialDate: _dateTime,
        firstDate: DateTime(1950),
        lastDate: DateTime(lastDate.year, lastDate.month, lastDate.day)
    );
    if (picked != null) {
      _dateTime = picked;
      _preencherLista();
      setState(() {});
    }
  }

  _onDelete(Post item) async {
    _setInProgress(false);
    String titulo = MyStrings.EXCLUIR;
    var content = Text(MyTexts.EXCLUIR_POST_PERMANENTE);
    var result = await DialogBox.dialogCancelOK(context, title: titulo, content: [content]);
    if (result.isPositive) {
      _setInProgress(true);
      if (await item.excluir()) {
        setState(() {
          data.removeWhere((e) => e.id == item.id);
        });
      } else {
        Log.snackbar(MyErros.ERRO_GENERICO, isError: true);
      }
      _setInProgress(false);
    }
  }

  _preencherLista() async {
    data.clear();
    List<Post> list = [];
    _setInProgress(true);
    if (_isMainPage) {
      if (_dateTime == null) _dateTime = DateTime.now();

      String data = _dateTime.toString();
      data = data.substring(0, data.indexOf(' '));
      list.addAll(await getPosts.data(data));
    } else {
      String meuId = FirebasePro.user.uid;
      if (user.filiados.containsKey(meuId)) {
        String dataPagamentoTemp = '';
        bool inserir = false;
        for (var item in user.postes.values) {
          String data = item.data.substring(0, item.data.indexOf(' ')-3);
          if (dataPagamentoTemp != data) {
            var pagamento = await getPosts.loadPagamento(user.dados.id, data);
            inserir = pagamento != null;
          }
          if (inserir)
            list.add(item);
        }
      }
      else if (FirebasePro.isAdmin || user.dados.id == meuId) {
        list.addAll(user.postes.values);
      }
      else
        list.addAll(user.postes.values.where((e) => e.isPublico).toList());
    }
    setState(() {
      data.addAll(list..sort((a, b) => b.data.compareTo(a.data)));
    });
    _setInProgress(false);
  }

  _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      _inProgress = b;
    });
  }

  //endregion
}