import 'package:flutter/material.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/sub_pages/fragment_g_denuncias.dart';
import 'package:protips/sub_pages/fragment_g_erros.dart';
import 'package:protips/sub_pages/fragment_g_solicitacoes.dart';

class GerenciaPage extends StatefulWidget {
  static const String tag = 'GerenciaPage';
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<GerenciaPage> with SingleTickerProviderStateMixin {
  static const String TAG = 'GerenciaPage';

  TabController _tabController;
  TabBarView _tabBarView;
  List<StatefulWidget> _widgetOptions;

  int currentIndex = 0;

  String _currentTitle = Titles.gerencia_page[0];

  //region overrides

  @override
  void initState() {
    super.initState();
    _widgetOptions = [FragmentSolicitacoes(), FragmentErros(), FragmentDenunciasG()];

    _tabController = TabController(length: _widgetOptions.length, initialIndex: currentIndex, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _onPageChanged(_tabController.index);
      });
    });
    _tabBarView = TabBarView(children: _widgetOptions, controller: _tabController);
  }

  @override
  Widget build(BuildContext context) {
    var navHeight = 50.0;
    return Scaffold(
      appBar: AppBar(title: Text(_currentTitle)),
      body: _tabBarView,
      bottomNavigationBar: Material(
        color: MyTheme.primary(),
        child: TabBar(
            controller: _tabController,
            indicatorColor: MyTheme.primary(),
            tabs: [
              Container(
                height: navHeight,
                child: Tab(
                    iconMargin: EdgeInsets.all(0),
                    text: Titles.nav_titles_gerencia[0],
                ),
              ),
              Container(
                  height: navHeight,
                  child: Tab(
                      iconMargin: EdgeInsets.all(0),
                      text: Titles.nav_titles_gerencia[1],
                  )
              ),
              Container(
                  height: navHeight,
                  child: Tab(
                      iconMargin: EdgeInsets.all(0),
                      text: Titles.nav_titles_gerencia[2],
                  )
              )
            ]),
      ),
    );
  }

  //endregion

  //region Metodos

  void _onPageChanged(int index) {
    setState(() {
      _currentTitle = Titles.gerencia_page[index];
      currentIndex = index;
    });
  }

  //endregion

}