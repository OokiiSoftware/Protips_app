import 'dart:io';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user_pro.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/pages/perfil_page_tipster.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

import 'my_icons.dart';

class Layouts {

  static Widget splashScreen([bool semInternet = false]) {
    double iconSize = 200;
    var backColor = MyTheme.dark;
    var textColor = Colors.white;

    return Scaffold(
        backgroundColor: backColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(MyIcons.ic_launcher_adaptive, width: iconSize, height: iconSize),
            Padding(padding: EdgeInsets.only(top: 20)),
            Text(MyResources.APP_NAME, style: TextStyle(fontSize: 25, color: textColor)),
            if (semInternet)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Sem conexão com a internet ou conexão fraca', style: TextStyle(color: textColor)),
              ),
            LinearProgressIndicator(backgroundColor: backColor)
          ],
        )
    );
  }

  //Foto e Dados
  static Widget fotoEDados(UserPro user) {
    bool isTipster = user.dados.isTipster;
    Color itemColor = MyTheme.darkModeOn ? Colors.grey : MyTheme.primaryLight2;
    var headItemPadding = Padding(padding: EdgeInsets.only(left: 8));
    var itemTextStyle = TextStyle(fontSize: 15);

    return Row(children: [
      //Foto
      Container(
          height: 90,
          width: 90,
          child: clipRRectFormatUser(
              radius: 100,
              child: fotoUser(user.dados)
          )
      ),
      Padding(padding: EdgeInsets.only(right: 10)),
      //Dados
      Flexible(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Nome
          Row(
            children: [
              Icon(Icons.person, color: itemColor),
              headItemPadding,
              Flexible(child: Text(user.dados.nome, style: itemTextStyle))
            ],
          ),
          //TipName
          Row(
            children: [
              Icon(Icons.language, color: itemColor),
              headItemPadding,
              Flexible(child: Text(user.dados.tipname, style: itemTextStyle))
            ],
          ),
          //Filiados
          Row(
            children: [
              Icon(Icons.group, color: itemColor),
              headItemPadding,
              Flexible(child: Text(
                  (isTipster ? MyStrings.FILIADOS : MyStrings.TIPSTERS) + ': ' +
                      (isTipster ? user.filiados : user.seguindo).values.length.toString(),
                  style: itemTextStyle
              ))
            ],
          ),
        ],
      )),
    ]);
  }

  static Widget customAppBar(BuildContext context, {@required String title, args, Widget icon}) {
    return Row(children: [
      Tooltip(
        message: 'Voltar',
        child: GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.arrow_back),
          ),
          onTap: () => Navigator.pop(context, args),
        ),
      ),
      Expanded(child: Text(title)),
      if (icon != null) icon,
    ]);
  }

  static FlatButton btnPagamento({String valor = '', @required UserPro tipster}) {
    var text = 'Realizar Pagamento';
    if (valor.isNotEmpty)
      text += ' $valor';

    return FlatButton(
      child: Text(text),
      color: Colors.green[800],
      textColor: Colors.white,
      onPressed: () {

      },
    );
  }

  static ListTile userTile(UserPro item, {onTap()}) {
    bool descricaoIsEmpty = item.dados.descricao.isEmpty;
    return ListTile(
        leading: Layouts.clipRRectFormatUser(
            radius: 50,
            child: Layouts.fotoUser(item.dados)
        ),
        title: Text(item.dados.nome),
        subtitle: Text(descricaoIsEmpty ? item.dados.tipname : item.dados.descricao),
        onTap: onTap
    );
  }

  static Padding get appBarActionsPadding => Padding(padding: EdgeInsets.only(right: 10));

  static Widget get icAlertInternet {
    return Tooltip(
      message: 'Sem Internet',
      child: Icon(Icons.warning, color: Colors.orange),
    );
  }

  static Widget post(BuildContext context, Post item, bool isMainPage, void onMenuItemPostCliked(String value, Post itemClicked), {void onGreenTap(), void onRedtap()}) {
    //region Variaveis
    UserPro user = getTipster.get(item.idTipster);
    String meuId = FirebasePro.user.uid;
    bool isMyPost = item.idTipster == meuId;

    var divider = Divider(height: 1, thickness: 1);

    double fotoUserSize = 40;

    bool moreGreens = item.bom.length > item.ruim.length;
    bool moreReds = item.ruim.length > item.bom.length;

    //endregion

    return Container(
        alignment: Alignment.center,
        child: Column(children: [
          //header
          divider,
          GestureDetector(
            child: Container(
              color: moreGreens ? Colors.green[200] : (moreReds ? Colors.red[200] : MyTheme.primaryLight),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Foto
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: item == null ?
                      Image.asset(MyIcons.ic_person,
                        // color: MyTheme.tintColor,
                        width: fotoUserSize,
                      ) :
                      ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Layouts.fotoUser(user.dados, iconSize: fotoUserSize)
                      )
                  ),
                  //Dados
                  Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.dados.nome ?? '', style: TextStyle(fontSize: 17, color: Colors.black)),
                      Text(item.data, style: TextStyle(color: Colors.black38))
                    ],
                  )),
                  //Menu
                  PopupMenuButton<String>(
                      onSelected: (String result) {
                        onMenuItemPostCliked(result, item);
                      },
                      itemBuilder: (BuildContext context) {
                        var list = List<String>();
                        list.addAll(MyMenus.post);
                        if (isMyPost)
                          list.remove(MyMenus.DENUNCIAR);
                        else
                          list.remove(MyMenus.EXCLUIR);
                        if (item.link.isEmpty)
                          list.remove(MyMenus.ABRIR_LINK);

                        return list.map((item) =>
                            PopupMenuItem<String>(value: item,
                                child: Text(item))).toList();
                      }
                  ),
                ],
              ),
            ),
            onTap: () {
              if (isMainPage)
                Navigate.to(context, PerfilTipsterPage(user));
            },
          ),
          Divider(
            color: MyTheme.accent,
            height: 3,
            thickness: 3,
          ),
          //Titulo
          if (item.titulo.isNotEmpty)
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.all(7),
              child: Text(item.titulo, style: TextStyle(fontSize: 17)),
            ),
          //Foto
          Container(child: Layouts.fotoPost(item)),
          divider,
          //descricao
          if (item.descricao.isNotEmpty)
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
              child: Text(item.descricao),
            ),
          //Dados
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                // Esporte / Linha
                Row(
                  children: [
                    if(item.esporte.isNotEmpty)
                      Expanded(child: Text(MyStrings.ESPORTE.toUpperCase() + ': ' + item.esporte)),
                    if(item.linha.isNotEmpty)
                      Expanded(child: Text(MyStrings.LINHA.toUpperCase() + ': ' + item.linha)),
                  ],
                ),
                // OddAtual / Unidades
                Row(
                  children: [
                    if(item.oddAtual.isNotEmpty)
                      Expanded(child: Text(MyStrings.ODD_ATUAL.toUpperCase() + ': ' + item.oddAtual)),
                    if(item.unidade.isNotEmpty)
                      Expanded(child: Text(MyStrings.UNIDADES.toUpperCase() + ': ' + item.unidade)),
                  ],
                ),

                if (item.oddMinima.isNotEmpty || item.oddMaxima.isNotEmpty ||
                    item.horarioMinimo.isNotEmpty || item.horarioMaximo.isNotEmpty)...[
                  Divider(),
                  Row(
                    children: [
                      if(item.oddAtual.isNotEmpty)
                        Expanded(child: Text('')),
                      if(item.unidade.isNotEmpty)
                        Expanded(child: Text(MyStrings.MINIMO.toUpperCase())),
                      if(item.unidade.isNotEmpty)
                        Expanded(child: Text(MyStrings.MAXIMO.toUpperCase())),
                    ],
                  ),
                  if (item.oddMinima.isNotEmpty || item.oddMaxima.isNotEmpty)
                    Row(
                      children: [
                        if(item.oddAtual.isNotEmpty)
                          Expanded(child: Text(MyStrings.ODD.toUpperCase())),
                        if(item.unidade.isNotEmpty)
                          Expanded(child: Text(item.oddMinima + '0')),
                        if(item.unidade.isNotEmpty)
                          Expanded(child: Text(item.oddMaxima + '0')),
                      ],
                    ),
                  if (item.horarioMinimo.isNotEmpty || item.horarioMaximo.isNotEmpty)
                    Row(
                      children: [
                        if(item.oddAtual.isNotEmpty)
                          Expanded(child: Text(MyStrings.HORARIO.toUpperCase())),
                        if(item.unidade.isNotEmpty)
                          Expanded(child: Text(item.horarioMinimo + '00:00')),
                        if(item.unidade.isNotEmpty)
                          Expanded(child: Text(item.horarioMaximo + '00:00')),
                      ],
                    ),
                ]
              ],
            ),
          ),
          // DataTable(
          //     headingRowHeight: 20,
          //     dataRowHeight: 20,
          //     columns: [
          //       DataColumn(label: Text('')),
          //       DataColumn(label: Text(MyStrings.MINIMO.toUpperCase())),
          //       DataColumn(label: Text(MyStrings.MAXIMO.toUpperCase())),
          //     ], rows: [
          //   // if (item.oddMinima.isNotEmpty || item.oddMaxima.isNotEmpty)
          //     DataRow(cells: [
          //       DataCell(Text(MyStrings.ODD.toUpperCase())),
          //       DataCell(Text(item.oddMinima)),
          //       DataCell(Text(item.oddMaxima)),
          //     ]),
          //   // if (item.horarioMinimo.isNotEmpty ||
          //   //     item.horarioMaximo.isNotEmpty)
          //     DataRow(cells: [
          //       DataCell(Text(MyStrings.HORARIO.toUpperCase())),
          //       DataCell(Text(item.horarioMinimo)),
          //       DataCell(Text(item.horarioMaximo)),
          //     ]),
          // ]),
          //Green | Red Buttons
          if (isMyPost)
            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 10, right: 30),
              child: Row(
                  children: [
                    Expanded(child: Text('\tEste Tip teve:')),
                    // Green
                    Tooltip(
                        message: 'Green',
                        child: GestureDetector(
                          child: Icon(
                            MyIcons.like,
                            // width: 30,
                            color: item.bom.containsKey(meuId) ? Colors.green : MyTheme.transparentColor(0.3),
                          ),
                          onTap: onGreenTap,
                        )
                    ),
                    Padding(padding: EdgeInsets.only(right: 30)),
                    // Red
                    Tooltip(
                        message: 'Red',
                        child: GestureDetector(
                          child: Icon(
                              MyIcons.dislike,
                              // width: 30,
                              color: item.ruim.containsKey(meuId) ? Colors.red : MyTheme.transparentColor(0.3)
                          ),
                          onTap: onRedtap,
                        )
                    ),
                  ]
              ),
            ),
        ])
    );
  }

  static Widget clipRRect({Widget child, double radius = 0}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
  }

  //region Fotos layouts
  static Widget clipRRectFormatUser({Widget child, double radius = 0}) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius/3),
      ),
      child: child,
    );
  }

  static Widget fotoUser(UserDados item, {double iconSize, BoxFit fit}) {
    bool fotoLocal = item.fotoLocalExist;
    if (fotoLocal) {
      return fotoUserFile(item.fotoToFile, iconSize: iconSize, fit: fit);
    } else {
      if (item.foto.isEmpty)
        return icPersonOnError(iconSize);
      return fotoUserNetwork(item.foto, iconSize: iconSize, fit: fit);
    }
  }
  static Widget fotoPost(Post item, [double iconSize]) {
    bool fotoLocal = item.fotoLocalExist;
    if (fotoLocal) {
      return fotoPostFile(item.fotoToFile, iconSize);
    } else {
      return fotoPostNetwork(item.foto, iconSize: iconSize);
    }
  }

  static Widget fotoUserFile(File file, {double iconSize, BoxFit fit}) => Image.file(file, fit: fit, width: iconSize, height: iconSize);
  static Widget fotoUserNetwork(String url, {double iconSize, BoxFit fit}) =>
      Image.network(url, fit: fit, width: iconSize, height: iconSize, loadingBuilder: (context, widget, progress) {
        if (progress == null) return widget;
        return CircularProgressIndicator(value: (progress.expectedTotalBytes == null) ? null : progress.cumulativeBytesLoaded/progress.expectedTotalBytes);
      }, /*errorBuilder: (c, u, e) => icPersonOnError(iconSize)*/);

  static Widget fotoPostFile(File file, [double iconSize]) => Image.file(file, width: iconSize, height: iconSize, errorBuilder: (c, u, e) => icPostOnError());
  static Widget fotoPostNetwork(String url, {double iconSize, bool progressTypeLinear = false}) =>
      Image.network(url, width: iconSize, height: iconSize, errorBuilder: (c, u, e) => icPostOnError(),
          loadingBuilder: (context, widget, progress) {
            if (progress == null) return widget;
            if (progressTypeLinear)
              return LinearProgressIndicator(value: (progress.expectedTotalBytes == null) ? null : progress.cumulativeBytesLoaded/progress.expectedTotalBytes);
            return CircularProgressIndicator(value: (progress.expectedTotalBytes == null) ? null : progress.cumulativeBytesLoaded/progress.expectedTotalBytes);
          });

  static Widget icPersonOnError(double iconSize) => Image.asset(MyIcons.ic_person_light, width: iconSize, height: iconSize);
  static Widget icPostOnError([double iconSize]) => Center(child: Icon(Icons.image_not_supported, size: (iconSize??25 * 4.0)));

  //endregion
}