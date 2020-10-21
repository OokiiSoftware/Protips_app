import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:protips/auxiliar/config.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/user.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/sub_pages/fragment_users_list.dart';

class UsersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<UsersPage> {

  List<UserPro> _data = List<UserPro>();

  bool _isTipster;

  @override
  void initState() {
    super.initState();
    String meuId = FirebasePro.user.uid;
    _isTipster = FirebasePro.userPro.dados.isTipster;
    if (_isTipster)
      _data.addAll(getUsers.data.values.where((e) => e.seguindo.containsKey(meuId)));
    else
      _data.addAll(getUsers.data.values.where((e) => e.seguidores.containsKey(meuId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isTipster ? Titles.MEUS_FILIADOS : Titles.MEUS_TIPSTRES),
        actions: [
          if (RunTime.semInternet)
            MyLayouts.icAlertInternet,
          MyLayouts.appBarActionsPadding,
        ],
      ),
      body: FragmentUsersList(
          data: _data..sort((a, b) => a.dados.nome.compareTo(b.dados.nome)),
          isFiliadosList: _isTipster,
          mostrarAppBar: false)
      ,
    );
  }
}