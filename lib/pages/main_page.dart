import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/user.dart';
import 'package:protips/pages/about_page.dart';
import 'package:protips/pages/login_page.dart';
import 'package:protips/pages/meu_perfil_page.dart';
import 'package:protips/pages/perfil_page.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/sub_pages/fragment_inicio.dart';
import 'package:protips/sub_pages/fragment_perfil.dart';
import 'package:protips/sub_pages/fragment_pesquisa.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainPage extends StatefulWidget {
  static const String tag = 'MainPage';
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<MainPage> with SingleTickerProviderStateMixin {

  //region Variaveis
  static const String TAG = 'MainPage';
  TabController _tabController;
  int currentIndex = 0;

  String _currentTitle = Titles.main_page[0];
  FragmentInicio _fragmentInicio;
  FragmentPerfil _fragmentPerfil;
  FragmentPesquisa _fragmentPesquisa;

  List<StatefulWidget> _widgetOptions;

  TabBarView _tabBarView;
  bool inicializado = false;
  //endregion

  //region overrides

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
//    getFirebase.notificationManager.dispose();
    Log.d(TAG, 'dispose', 'ok');
  }

  @override
  void initState() {
    super.initState();
    Log.d(TAG, 'initState', 'ok');
    _fragmentInicio = FragmentInicio();
    _fragmentPerfil = FragmentPerfil();
    _fragmentPesquisa = FragmentPesquisa();

    _widgetOptions = [_fragmentInicio, _fragmentPesquisa, _fragmentPerfil];

    _tabController = TabController(length: _widgetOptions.length, initialIndex: currentIndex, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _onPageChanged(_tabController.index);
      });
    });
    _tabBarView = TabBarView(children: _widgetOptions, controller: _tabController);

    init();
  }

  @override
  Widget build(BuildContext context) {
    bool userIsTipster = getFirebase.user().dados.isTipster;

    double screenHeight = MediaQuery.of(context).size.height/3;
    double iconSize = 200;

    var navIconColor = MyTheme.tintColor();
    var navIconSize = 15.0;
    var drawerIconSize = 23.0;
    var navHeight = 50.0;

    return inicializado ? Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(_currentTitle),
        actions: <Widget>[
          if (currentIndex == 1) IconButton(
            icon: SvgPicture.asset(MyIcons.ic_pesquisa_svg, color: navIconColor, width: navIconSize + 5),
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
                      child: Image.asset(
                        MyIcons.ic_launcher,
                        width: 70,
                        height: 70,
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        MyStrings.APP_NAME,
                        style: TextStyle(
                          color: MyTheme.textColor(),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        MyStrings.app_email,
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
            //Meu Perfil
            ListTile(
              leading: Image.asset(MyIcons.ic_perfil, color: Colors.black38, width: drawerIconSize),
              title: Text(MyMenus.MEU_PERFIL),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(MeuPerfilPage.tag);
              },
            ),
            //Meus Posts
            if (userIsTipster)
              ListTile(
                leading: Icon(Icons.lightbulb_outline),
                title: Text(MyMenus.MEUS_POSTS),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(PerfilPage.tag, arguments: getFirebase.user());
                },
              ),
            //Atualização
            ListTile(
              leading: Icon(Icons.update),
              title: Text(MyMenus.ATUALIZACAO),
              onTap: () {
                onAtualizarTap();
                Navigator.pop(context);
              },
            ),
            //Loguot
            ListTile(
              leading: Icon(Icons.highlight_off),
              title: Text(MyMenus.LOGOUT),
              onTap: () {
                Navigator.pop(context);
                onLogoutTap();
              },
            ),
            //Sobre
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(MyMenus.SOBRE),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AboutPage.tag);
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
//            indicatorWeight: 0.1,
            tabs: [
              Container(
                height: navHeight,
                child: Tab(
                    iconMargin: EdgeInsets.all(0),
                    text: Titles.nav_titles_main[0],
                    icon: SvgPicture.asset(MyIcons.ic_home_svg, color: navIconColor, width: navIconSize)),
              ),
              Container(
                  height: navHeight,
                  child: Tab(
                      iconMargin: EdgeInsets.all(0),
                      text: Titles.nav_titles_main[1],
                      icon: SvgPicture.asset(MyIcons.ic_pesquisa_svg, color: navIconColor, width: navIconSize)
                  )
              ),
              Container(
                  height: navHeight,
                  child: Tab(
                      iconMargin: EdgeInsets.all(0),
                      text: Titles.nav_titles_main[2],
                      icon: SvgPicture.asset(MyIcons.ic_perfil_svg, color: navIconColor, width: navIconSize))),
            ]),
      ),
    ) :
        /*BottomNavigationBar(
        currentIndex: currentIndex,
        showUnselectedLabels: false,
        selectedItemColor: MyTheme.textColor(),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(MyIcons.ic_home_svg, color: navIconColor, width: navIconSize),
            title: Text(Titles.nav_titles_main[0]),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(MyIcons.ic_pesquisa_svg, color: navIconColor, width: navIconSize),
            title: Text(Titles.nav_titles_main[1]),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(MyIcons.ic_perfil_svg, color: navIconColor, width: navIconSize),
            title: Text(Titles.nav_titles_main[2]),
          ),
        ],
        onTap: _onItemTapped,
      )*/
        //SplashScreen
    Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(0, screenHeight, 0, 100),
        alignment: Alignment.center,
        child: Column(
          children: [
            Image.asset(MyIcons.ic_launcher, width: iconSize, height: iconSize),
            Padding(padding: EdgeInsets.only(top: 20)),
            Text(MyStrings.APP_NAME, style: TextStyle(fontSize: 25)),
            LinearProgressIndicator()
          ],
        ),
      )
    );
  }

  //endregion

  //region Metodos

  Future<void> init() async {
    var result = await getFirebase.init();
    try {
      if (result == FirebaseInitResult.fUserNull)
        throw Exception(FirebaseInitResult.fUserNull);

      await OfflineData.readDirectorys();
      if (await OfflineData.readOfflineData()) {
        User item = await getUsers.get(getFirebase.fUser().uid);
        if (item != null)
          getFirebase.setUser(item);
        setState(() {
          inicializado = true;
        });
      }

      //Obtem os dados do usuário logado
      if (!await getFirebase.atualizarOfflineUser()) {
        var result2 = await Navigator.of(context).pushNamed(MeuPerfilPage.tag);
        if (result2 == null) throw Exception(FirebaseInitResult.userNull);
         else Navigator.of(context).pushNamed(MeuPerfilPage.tag);
      }

      getFirebase.initNotificationManager(context);

      getFirebase.observMyFirebaseData();

      await getUsers.baixar();
      setState(() {
        inicializado = true;
      });

      await OfflineData.saveOfflineData();
      await getUsers.saveFotosPerfilLocal();
      await getPosts.saveFotosLocal();

      OfflineData.deletefile(OfflineData.appTempPath, OfflineData.appTempName);

    } catch(e) {
      Log.e(TAG, 'init', e);
      Navigator.of(context).pushReplacementNamed(LoginPage.tag);
    }
  }

  void onLogoutTap() {
    FirebaseAuth.instance.signOut();
    getFirebase.user().logout();
    getFirebase.finalize();
    Navigator.pushReplacementNamed(context, LoginPage.tag);
  }

   void onAtualizarTap() async {
     Log.toast(context, 'Verificando Atualização');
     if(await openFile()) {
       return;
     }
     var resultData = await Import.buscarAtualizacao();

     if(resultData != null) {
       var result = await showDialog(
           context: context,
           barrierDismissible: false,
           builder: (BuildContext context) {
             return AlertDialog(
               title: Text(MyStrings.VERIF_ATUALIZACAO),
               content: Text(MyStrings.BAIXAR_ATUALIZACAO),
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
       if (result) {
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

         /*showDialog(
             context: context,
             barrierDismissible: false,
             builder: (BuildContext context) {
               return AlertDialog(
                 title: Text(MyStrings.BAIXANDO),
                 content: progressBar,
                 actions: <Widget>[
                   FlatButton(
                     child: Text(MyStrings.CANCELAR),
                     onPressed: () {
                       cancelToken.cancel();
                       Navigator.of(context).pop();
                     },
                   ),
                   FlatButton(
                     child: Text(MyStrings.SEGUNDO_PLANO),
                     onPressed: () {
                       Navigator.of(context).pop();
                     },
                   ),
                 ],
               );
             }
         );*/
       }
//       Import.openUrl(resultData, context);
     } else
       Log.toast(context, 'Sem Atualização');
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentTitle = Titles.main_page[index];
      currentIndex = index;
    });
  }


  Future<bool> openFile() async {
    final filePath = OfflineData.appTempPath + '/' + OfflineData.appTempName;
    final result = await OpenFile.open(filePath);

    setState(() {
      var _openResult = "type=${result.type}  message=${result.message}";
      Log.d(TAG, 'openFile', _openResult);
    });
    return result.type == ResultType.done;
  }

  //endregion

}

class DataSearch extends SearchDelegate<String> {

  final sugestoes = getUsers.users.values.toList();

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
    return PerfilPage(user: getFirebase.user());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final list = query.isEmpty ? [] : sugestoes.where((element) =>
        element.dados.nome.toLowerCase().startsWith(query.toLowerCase())).toList();

    return ListView.builder(itemBuilder: (context, index) {
      User item = list[index];
      bool fotoLocalExist = item.dados.fotoLocalExist;
      return ListTile(
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: fotoLocalExist ?
                Image.file(File(item.dados.fotoLocal)) :
            Image.network(
                item.dados.foto,
                errorBuilder: (c, u, e) => Image.asset(MyIcons.ic_person)
            )
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
          Navigator.of(context).pushNamed(PerfilPage.tag, arguments: item);
        },
      );
    },
      itemCount: list.length,
    );
  }

}
