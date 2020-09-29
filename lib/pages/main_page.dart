import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/data_hora.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/pages/about_page.dart';
import 'package:protips/pages/users_page.dart';
import 'package:protips/pages/gerencia_page.dart';
import 'package:protips/pages/login_page.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/pages/perfil_tipster_page.dart';
import 'package:protips/pages/tutorial_page.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/sub_pages/fragment_inicio.dart';
import 'package:protips/sub_pages/fragment_perfil.dart';
import 'package:protips/sub_pages/fragment_users_list.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
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
  //endregion

  //region overrides

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
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
      setState(() {
        _onPageChanged(_tabController.index);
      });
    });
    _tabBarView = TabBarView(children: _widgetOptions, controller: _tabController);

    _init();
  }

  @override
  Widget build(BuildContext context) {
    Log.setToast = context;

    //region Variaveis
    _user = getFirebase.user.dados;
    _isTipster = _user.isTipster;

    var navIconColor = MyTheme.tintColor();
    var draewrIconColor = MyTheme.primaryDark();
    var draewrTextStyle = TextStyle(color: draewrIconColor);
    var navHeight = 40.0;
    //endregion

    if (!_isInicializado)
      return MyLayouts.splashScreen();

    // sendPostTest();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(_currentTitle),
        actions: <Widget>[
          if (_currentIndex == 1) IconButton(
            icon: Icon(Icons.person_search_sharp),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          ),
          Padding(padding: EdgeInsets.only(right: 10))
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
                      MyTheme.primary(),
                      MyTheme.primaryLight(),
                    ]
                ),
              ),
              child: Container(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 70,
                        height: 70,
                        child: _showUserDados ? ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: MyLayouts.fotoUser(_user)
                        ) : Image.asset(MyAssets.ic_launcher),
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _showUserDados ? _user.nome : MyStrings.APP_NAME,
                        style: TextStyle(
                          color: MyTheme.textColor(),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _showUserDados ? _user.email : MyStrings.app_email,
                        style: TextStyle(
                          color: MyTheme.textSubtitleColor(),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //Atualização
            ListTile(
              leading: Icon(Icons.update, color: draewrIconColor),
              title: Text(MyMenus.ATUALIZACAO, style: draewrTextStyle),
              onTap: () {
                _onAtualizarTap();
                _closeDrawer(context);
              },
            ),
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
                leading: Icon(Icons.lightbulb_outline, color: draewrIconColor), //Image.asset(MyIcons.ic_lamp_p, ,/* width: drawerIconSize - 5*/),
                title: Text(MyMenus.MEUS_POSTS, style: draewrTextStyle),
                onTap: () {
                  _closeDrawer(context);
                  Navigate.to(context, PerfilTipsterPage(getFirebase.user));
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
            if (getFirebase.isAdmin)
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
          ],
        ),
      ),
      body: _tabBarView,
      bottomNavigationBar: Material(
        color: MyTheme.primary(),
        child: TabBar(
            controller: _tabController,
            indicatorColor: MyTheme.primary(),
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
    var result = await getFirebase.init();
    try {
      if (result == FirebaseInitResult.fUserNull)
        throw Exception(FirebaseInitResult.fUserNull);

      Aplication.init(context);

      if (await OfflineData.readOfflineData()) {
        User item = await getUsers.get(getFirebase.fUser.uid);
        if (item != null)
          getFirebase.setUser(item);
        setState(() {
          _isInicializado = true;
        });
      }

      //Obtem os dados do usuário logado
      if (!await getFirebase.atualizarOfflineUser()) {
        var result2 = await Navigate.to(context, PerfilPage());
        if (result2 == null) throw Exception(FirebaseInitResult.userNull);
         else Navigate.to(context, PerfilPage());
      }

      _isTipster = getFirebase.user.dados.isTipster;
      _verificarTutorial();

      getFirebase.observMyFirebaseData();

      await getUsers.baixar();
      await _initPlatformState();
      setState(() {
        _isInicializado = true;
      });

      await OfflineData.saveOfflineData();
//      await getUsers.saveFotosPerfilLocal();
      await getPosts.saveFotosLocal();
      _verificarDiaPagamento();

//      OfflineData.deletefile(OfflineData.appTempPath, OfflineData.appTempName);
      _onAtualizarTap(false);

    } catch(e) {
      bool sendError = true;
      if (e.toString().contains(FirebaseInitResult.fUserNull.toString()))
        sendError = false;
      if (e.toString().contains(FirebaseInitResult.userNull.toString()))
        sendError = false;
      Log.e(TAG, 'init', e, sendError);
      Navigate.toReplacement(context, LoginPage());
    }
  }

  /// TODO Usado somente pra testes
  sendPostTest() async {
    Post p = Post();
    p.id = randomString(10);
    p.titulo = 'test';
    p.isPublico = false;
    p.data = DataHora.now();
    p.descricao = 'desc';
    p.idTipster = getFirebase.fUser.uid;
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
    FirebaseAuth.instance.signOut();
    getFirebase.user.logout();
    getFirebase.finalize();
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
      Log.toast('Verificando Atualização');
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
        Import.openUrl(resultData, context);
    } else
    if (showMsg)
      Log.toast('Sem Atualização');
  }

  void _verificarTutorial() async {
    var pref = await SharedPreferences.getInstance();
    if(_isTipster && pref.getBool(SharedPreferencesKey.ULTIMO_TUTORIAL_OK) == null)
      Navigate.to(context, TutorialPage());
  }

  void _verificarDiaPagamento() async {
    DateTime hoje = DateTime.now();
    int dia = _user.diaPagamento;
    if (dia == hoje.day) {
      Aplication.sharedPref.setBool(SharedPreferencesKey.DIA_PAGAMENTO, false);
    }
  }

  void _closeDrawer(BuildContext context) {
    Navigator.pop(context);
    _showUserDados = !_showUserDados;
  }

  Future<void> _initPlatformState() async {
//    await Purchases.setDebugLogsEnabled(true);
//    await Purchases.setup(MyResources.revenueCatApi);
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

  @override
  String get searchFieldLabel => MyStrings.PESQUISAR;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () {query = '';})];
  }

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
    return PerfilTipsterPage(getFirebase.user);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final list = query.isEmpty ? [] : sugestoes.where((x) => x.dados.nome.toLowerCase().startsWith(query.toLowerCase())).toList();

    return ListView.builder(itemBuilder: (context, index) {
      User item = list[index];

      return ListTile(
        leading: MyLayouts.iconFormatUser(
            radius: 50,
            child: MyLayouts.fotoUser(item.dados)
        ),
        title: RichText(
          text: TextSpan(
              text: item.dados.nome.substring(0, query.length),
              style: TextStyle(color: MyTheme.textColorInvert(), fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                    text: item.dados.nome.substring(query.length),
                    style: TextStyle(color: MyTheme.textColorInvert(0.5))
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
      itemCount: list.length,
    );
  }

}
