import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/aplication.dart';
import 'package:protips/auxiliar/config.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/notification_manager.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/auxiliar/preferences.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/pages/about_page.dart';
import 'package:protips/pages/config_page.dart';
import 'package:protips/pages/users_page.dart';
import 'package:protips/pages/gerencia_page.dart';
import 'package:protips/pages/login_page.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/pages/perfil_page_tipster.dart';
import 'package:protips/pages/tutorial_page.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/layouts.dart';
import 'package:protips/res/my_icons.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';
import 'package:protips/sub_pages/fragment_inicio.dart';
import 'package:protips/sub_pages/fragment_perfil.dart';
import 'package:protips/sub_pages/fragment_users_list.dart';
import 'package:random_string/random_string.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<MainPage> with SingleTickerProviderStateMixin {

  //region Variaveis
  static const String TAG = 'MainPage';
  static bool _showUserDados = false;
  UserDados _user;

  TabController _tabController;
  int _currentIndex = 0;

  String _currentTitle = Titles.main_page[0];
  FragmentInicio _fragmentInicio;
  FragmentPerfil _fragmentPerfil;
  FragmentUsersList _fragmentPesquisa;

  List<StatefulWidget> _widgetOptions;

  TabBarView _tabBarView;
  bool _isInicializado = false;
  bool _isTipster = false;

  // bool semInternet = false;
  //endregion

  //region overrides

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  void initState() {
    super.initState();
    Log.d(TAG, 'initState', 'ok');
    _fragmentInicio = FragmentInicio();
    _fragmentPerfil = FragmentPerfil();
    _fragmentPesquisa = FragmentUsersList(isFiliadosList: false, mostrarAppBar: true);

    _widgetOptions = [_fragmentInicio, _fragmentPesquisa, _fragmentPerfil];

    _tabController = TabController(length: _widgetOptions.length, initialIndex: _currentIndex, vsync: this);
    _tabController.addListener(() {
      _onPageChanged(_tabController.index);
    });
    _tabBarView = TabBarView(children: _widgetOptions, controller: _tabController);

    _init();
  }

  @override
  Widget build(BuildContext context) {
    //region Variaveis
    _user = FirebasePro.userPro.dados;
    _isTipster = _user.isTipster;

    var draewrHeaderTextColor = Colors.white;
    var draewrTextColor = MyTheme.textColorSpecial;
    var draewrIconColor = MyTheme.textColorSpecial;
    var draewrTextStyle = TextStyle(color: draewrTextColor);

    var navIconColor = Colors.white;
    var navHeight = 40.0;
    //endregion

    if (!_isInicializado)
      return Layouts.splashScreen(RunTime.semInternet);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(_currentTitle),
        actions: <Widget>[
          if (RunTime.semInternet)
            Layouts.icAlertInternet,
          if (_currentIndex == 1) IconButton(
            tooltip: 'Pesquisar',
            icon: Icon(Icons.person_search_sharp),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          ),
          Layouts.appBarActionsPadding,
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      if (MyTheme.darkModeOn)...[
                        Colors.grey[900],
                        Colors.grey[850]
                      ] else...[
                        MyTheme.primary,
                        MyTheme.primaryLight,
                      ]
                    ]
                ),
              ),
              child: Container(
                child: Column(
                  children: [
                    //Icone / Foto
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 70,
                        height: 70,
                        child: _showUserDados ? ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: Layouts.fotoUser(_user)
                        ) : Image.asset(MyIcons.ic_launcher),
                      ),
                    ),
                    Spacer(),
                    // Nome
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _showUserDados ? _user.nome : MyResources.APP_NAME,
                        style: TextStyle(
                          color: draewrHeaderTextColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    // Email
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _showUserDados ? _user.email : MyResources.app_email,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Atualização
            // ListTile(
            //   leading: Icon(Icons.update, color: draewrIconColor),
            //   title: Text(MyMenus.ATUALIZACAO, style: draewrTextStyle),
            //   onTap: () {
            //     _onAtualizarTap();
            //     _closeDrawer(context);
            //   },
            // ),
            //Meus Posts
            if (_isTipster)...[
              ListTile(
                leading: Icon(Icons.group, color: draewrIconColor),
                title: Text(MyMenus.MEUS_FILIADOS, style: draewrTextStyle),
                onTap: () {
                  _closeDrawer(context);
                  Navigate.to(context, UsersPage());
                },
              ),
              ListTile(
                leading: Icon(MyIcons.lightbulb, color: draewrIconColor),
                title: Text(MyMenus.MEUS_POSTS, style: draewrTextStyle),
                onTap: () {
                  _closeDrawer(context);
                  Navigate.to(context, PerfilTipsterPage(FirebasePro.userPro));
                },
              ),
            ]
            else ...[
              ListTile(
                leading: Icon(Icons.group, color: draewrIconColor),
                title: Text(MyMenus.MEUS_TIPSTERS, style: draewrTextStyle),
                onTap: () {
                  _closeDrawer(context);
                  Navigate.to(context, UsersPage());
                },
              )
            ],
            //Meu Perfil
            ListTile(
              leading: Icon(Icons.person_pin, color: draewrIconColor), //Image.asset(MyIcons.ic_home, /*color: draewrIconColor,*/ /*width: drawerIconSize*/),
              title: Text(MyMenus.MEU_PERFIL, style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                Navigate.to(context,PerfilPage());
              },
            ),
            if (FirebasePro.isAdmin)
              ListTile(
                leading: Icon(Icons.whatshot, color: draewrIconColor),
                title: Text(MyMenus.GERENCIA, style: draewrTextStyle),
                onTap: () {
                  _closeDrawer(context);
                  Navigate.to(context, GerenciaPage());
                },
              ),
            if (_isTipster)
              ListTile(
                leading: Icon(Icons.help, color: draewrIconColor),
                title: Text(MyMenus.TUTORIAL, style: draewrTextStyle),
                onTap: () {
                  _closeDrawer(context);
                  Navigate.to(context, TutorialPage());
                },
              ),
            //Sobre
            ListTile(
              leading: Icon(Icons.info, color: draewrIconColor),
              title: Text(MyMenus.SOBRE, style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                Navigate.to(context, AboutPage());
              },
            ),
            //Loguot
            ListTile(
              leading: Icon(Icons.remove_circle, color: draewrIconColor),
              title: Text(MyMenus.LOGOUT, style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                _onLogoutTap();
              },
            ),
            Divider(color: draewrIconColor),
            // Config
            ListTile(
              leading: Icon(Icons.settings, color: draewrIconColor),
              title: Text(MyMenus.CONFIG, style: draewrTextStyle),
              onTap: () {
                _closeDrawer(context);
                _onConfigTap();
              },
            ),
          ],
        ),
      ),
      body: _tabBarView,
      bottomNavigationBar: Material(
        color: MyTheme.darkModeOn ? Colors.grey[900] : MyTheme.primary,
        child: TabBar(
            controller: _tabController,
            indicatorColor: MyTheme.primary,
            tabs: [
              Tooltip(
                message: Titles.nav_titles_main[0],
                child: Container(
                  height: navHeight,
                  child: Tab(
                      iconMargin: EdgeInsets.all(0),
                      icon: Icon(Icons.home, color: navIconColor)//Image.asset(MyIcons.ic_home, /*color: navIconColor,*/ width: 30)
                  ),
                ),
              ),
              Tooltip(
                message: Titles.nav_titles_main[1],
                child: Container(
                    height: navHeight,
                    child: Tab(
                        iconMargin: EdgeInsets.all(0),
                        icon: Icon(Icons.share, color: navIconColor)
                    )
                ),
              ),
              Tooltip(
                message: Titles.nav_titles_main[2],
                child: Container(
                    height: navHeight,
                    child: Tab(
                        iconMargin: EdgeInsets.all(0),
                        icon: Icon(Icons.person_pin, color: navIconColor)//Image.asset(MyIcons.ic_perfil, /*color: navIconColor,*/ width: 30)//SvgPicture.asset(MyIcons.ic_perfil_svg, color: navIconColor, width: navIconSize)
                    )
                ),
              ),
            ]),
      ),
    );
  }

  //endregion

  //region Metodos

  Future<void> _init() async {
    _tempoDeInicializacao();
    try {
      //Obtem os dados do usuário logado
      if (!await FirebasePro.atualizarOfflineUser()) {
        var result2 = await Navigate.to(context, PerfilPage());
        if (result2 == null) throw Exception(FirebaseInitResult.userNull);
        else Navigate.to(context, PerfilPage());
      }

      _isTipster = FirebasePro.userPro.dados.isTipster;
      _verificarTutorial();
      _verificarArguments();

      NotificationManager.instance = NotificationManager(context);

      FirebasePro.observMyFirebaseData();

      await UserPro.baixarList();

      if(!mounted) return;
      setState(() {
        _isInicializado = true;
      });

      await OfflineData.saveOfflineData();
      await getPosts.saveFotosLocal();

      _onAtualizarTap(false);
      if(!mounted) return;
      setState(() {
        RunTime.semInternet = false;
      });

      _mostrarMsgDeAviso();
    } catch(e) {
      bool sendError = true;
      if (e.toString().contains(FirebaseInitResult.fUserNull.toString()))
        sendError = false;
      if (e.toString().contains(FirebaseInitResult.userNull.toString()))
        sendError = false;

      if (sendError)
        Log.e(TAG, 'init', e);
      else
        Log.e2(TAG, 'init', e);
      Navigate.toReplacement(context, LoginPage());
    }
  }

  /// REMOVE Usado somente pra testes
  sendPostTest() async {
    Post p = Post();
    p.id = randomString(10);
    p.titulo = 'test';
    p.isPublico = false;
    p.data = DataHora.now();
    p.descricao = 'desc';
    p.idTipster = FirebasePro.user.uid;
    p.campeonato = 'camp';
    p.linha = 'linha';
    p.esporte = 'esport';
    p.unidade = '2';
    p.oddAtual = '1';
    // p.postar();
    EventListener.onPostSend(p);
    // getFirebase.notificationManager.sendPost(p, await getUsers.get('bXSEl3yiwFRor74nPga0P56OeHo2'));
  }

  void _onLogoutTap() {
    FirebasePro.finalize();
    Navigate.toReplacement(context, LoginPage());
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentTitle = Titles.main_page[index];
      _currentIndex = index;
    });
  }

  void _onAtualizarTap([bool showMsg = true]) async {
    if (showMsg)
      Log.snackbar('Verificando Atualização');
//     if(await _openFile()) {
//       return;
//     }
    var resultData = await Aplication.buscarAtualizacao();

    if(resultData != null) {
      bool result = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(MyTexts.VERIF_ATUALIZACAO),
              content: Text(MyTexts.BAIXAR_ATUALIZACAO),
              actions: <Widget>[
                FlatButton(
                  child: Text(MyStrings.CANCELAR),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text(MyStrings.BAIXAR),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          }
      );
      /*if (result) {
         double progressBarValue = 0;
         final ProgressDialog pr = ProgressDialog(context, type: ProgressDialogType.Download, isDismissible: false);
         pr.style(
             message: MyStrings.BAIXANDO,
             borderRadius: 10.0,
             backgroundColor: Colors.white,
             progressWidget: CircularProgressIndicator(),
             elevation: 10.0,
             insetAnimCurve: Curves.easeInOut,
             progress: 0.0,
             maxProgress: 100.0,
             progressTextStyle: TextStyle(color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
             messageTextStyle: TextStyle(color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)
         );

         CancelToken cancelToken = CancelToken();
         OfflineData.downloadFile(resultData, OfflineData.appTempPath, OfflineData.appTempName,
             override: true, cancelToken: cancelToken, onProgress: (rec, total) {
               progressBarValue = ((rec / total) * 100).floorToDouble();
               pr.update(progress: progressBarValue, maxProgress: 100.0);
//               Log.d(TAG, 'onAtualizarTap', progressBarValue);
               if (progressBarValue >= 100) {
                 if (pr.isShowing())
                   pr.hide();
                 openFile();
                 Log.d(TAG, 'Atualizar', 'Comprete');
               }
             });

         await pr.show();

       showDialog(
             context: context,
             barrierDismissible: false,
             builder: (BuildContext context) {
               return AlertDialog(
                 title: Text(MyStrings.BAIXANDO),
                 content: CircularProgressIndicator(),
                 actions: <Widget>[
                   FlatButton(
                     child: Text(MyStrings.CANCELAR),
                     onPressed: () {
                       cancelToken.cancel();
                       Navigator.of(context).pop();
                     },
                   ),
                   FlatButton(
                     child: Text(MyTexts.SEGUNDO_PLANO),
                     onPressed: () {
                       Navigator.of(context).pop();
                     },
                   ),
                 ],
               );
             }
         );
       }*/
      if (result)
        Import.openUrl(MyResources.playStoryLink, context);
    } else
    if (showMsg)
      Log.snackbar('Sem Atualização');
  }

  void _onConfigTap() async {
    await Navigate.to(context, ConfigPage());
    setState(() {

    });
  }

  void _verificarTutorial() async {
    if(_isTipster && !Preferences.getBool(PreferencesKey.ULTIMO_TUTORIAL_OK))
      Navigate.to(context, TutorialPage());
  }

  void _verificarArguments() async {
    // bool abrirConfigPage = Preferences.getBool(PreferencesKey.ABRIR_CONFIG_PAGE);
    // if (abrirConfigPage) {
    //   await Preferences.setBool(PreferencesKey.ABRIR_CONFIG_PAGE, false);
    //   Navigate.to(context, ConfigPage());
    // }
  }

  // void _verificarDiaPagamento() async {
  //   DateTime hoje = DateTime.now();
  //   int dia = _user.diaPagamento;
  //   if (dia == hoje.day) {
  //     Preferences.setBool(PreferencesKey.DIA_PAGAMENTO, false);
  //   }
  // }

  void _closeDrawer(BuildContext context) {
    Navigator.pop(context);
    _showUserDados = !_showUserDados;
  }

  // Aviso que o app ta em fase de Testes
  void _mostrarMsgDeAviso() async {
    bool mostrei = Preferences.getBool(PreferencesKey.MSG_DE_TESTES) ?? false;
    if (!mostrei) {
      String title = 'AVISO';
      String auxBtnText = 'Não mostrar novamente';
      var content = Text('Estamos em fase se testes e estamos trabalhando para trazer essa plataforma até você de forma rápida e com segurança.\nPor favor, aguarde mais um pouco.\nFicaremos muito felizes se você permanecer conosco.');
      var result = await DialogBox.dialogOK(context, title: title, content: [content], auxBtnText: auxBtnText);
      if (result.isAux)
        Preferences.setBool(PreferencesKey.MSG_DE_TESTES, true);
    }
  }

  // Future readOfflineData() async {
  //   {
  //     if(!mounted) return;
  //     setState(() {
  //       _isInicializado = true;
  //     });
  //   }
  // }

  void _tempoDeInicializacao() async {
    int seconds = Aplication.isRelease ? 15 : 2;
    await Future.delayed(Duration(seconds: seconds));
    if(!mounted) return;
    if (!_isInicializado)
      setState(() {
        RunTime.semInternet = true;
      });
    bool isLogado = Preferences.getBool(PreferencesKey.USER_LOGADO) ?? false;
    if (isLogado) {
      await Future.delayed(Duration(seconds: 5));
      // await readOfflineData();
    } else
      Navigate.toReplacement(context, LoginPage());
  }

  /*Future<bool> _openFile() async {
    final filePath = OfflineData.appTempPath + '/' + OfflineData.appTempName;
    final result = await OpenFile.open(filePath);

    setState(() {
      var _openResult = "type=${result.type}  message=${result.message}";
      Log.d(TAG, 'openFile', _openResult);
    });
    return result.type == ResultType.done;
  }*/

  //endregion

}

class DataSearch extends SearchDelegate<String> {

  final sugestoes = getTipster.data;
  final List<UserPro> listResults = [];

  @override
  String get searchFieldLabel => MyStrings.PESQUISAR;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: MyTheme.primary,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context)
    => [IconButton(icon: Icon(Icons.clear), onPressed: () {query = '';})];

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow,
      progress: transitionAnimation,
    ), onPressed: () {
      close(context, null);
    });
  }

  @override
  Widget buildResults(BuildContext context) {
    if (listResults.length == 0) {
      Navigator.pop(context);
      return Layouts.splashScreen();
    }
    return PerfilTipsterPage(listResults[0]);
  }


  @override
  Widget buildSuggestions(BuildContext context) {
    listResults.clear();
    listResults.addAll(query.isEmpty ? [] : sugestoes.where((x) => x.dados.nome.toLowerCase().startsWith(query.toLowerCase())).toList());

    return ListView.builder(itemBuilder: (context, index) {
      UserPro item = listResults[index];

      return ListTile(
        leading: Layouts.clipRRectFormatUser(
            radius: 50,
            child: Layouts.fotoUser(item.dados)
        ),
        title: RichText(
          text: TextSpan(
              text: item.dados.nome.substring(0, query.length),
              style: TextStyle(color: MyTheme.transparentColor(1), fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: item.dados.nome.substring(query.length),
                    style: TextStyle(color: MyTheme.transparentColor(0.5))
                )
              ]
          ),
        ),
        subtitle: Text(item.dados.tipname),
        onTap: () {
          Navigate.to(context, PerfilTipsterPage(item));
        },
      );
    },
      itemCount: listResults.length,
    );
  }

}

/* //BottomAppBar com detalhe no botão flutuante

  extendBody: true
  floatingActionButton: FloatingActionButton(),
  floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
  BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: MyTheme.primary(),
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: [
              Spacer(),
              IconButton(icon: Icon(Icons.home), onPressed: () {}),
              Spacer(),
              IconButton(icon: Icon(Icons.share), onPressed: () {}),
              Spacer(),
              IconButton(icon: Icon(Icons.person_pin), onPressed: () {}),
              Spacer(),
            ],
          ),
        ),
*/
