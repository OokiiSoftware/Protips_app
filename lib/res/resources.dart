import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/model/post.dart';
import 'package:protips/model/user.dart';
import 'package:protips/model/user_dados.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

class MyLayouts {

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
            Image.asset(MyAssets.ic_launcher_adaptive, width: iconSize, height: iconSize),
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
            child: iconFormatUser(
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
                        (isTipster ? user.seguidores : user.seguindo).values.length.toString(),
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
      leading: MyLayouts.iconFormatUser(
          radius: 50,
          child: MyLayouts.fotoUser(item.dados)
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

  //region Fotos layouts
  static Widget iconFormatUser({Widget child, double radius = 0}) {
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
      return fotoPostNetwork(item.foto, iconSize);
    }
  }

  static Widget fotoUserFile(File file, {double iconSize, BoxFit fit}) => Image.file(file, fit: fit, width: iconSize, height: iconSize);
  static Widget fotoUserNetwork(String url, {double iconSize, BoxFit fit}) =>
      Image.network(url, fit: fit, width: iconSize, height: iconSize, loadingBuilder: (context, widget, progress) {
        if (progress == null) return widget;
        return CircularProgressIndicator(value: (progress.expectedTotalBytes == null) ? null : progress.cumulativeBytesLoaded/progress.expectedTotalBytes);
      }, /*errorBuilder: (c, u, e) => icPersonOnError(iconSize)*/);

  static Widget fotoPostFile(File file, [double iconSize]) => Image.file(file, width: iconSize, height: iconSize, errorBuilder: (c, u, e) => icPostOnError());
  static Widget fotoPostNetwork(String url, [double iconSize]) =>
      Image.network(url, width: iconSize, height: iconSize, errorBuilder: (c, u, e) => icPostOnError(),
          loadingBuilder: (context, widget, progress) {
        if (progress == null) return widget;
        return CircularProgressIndicator(value: (progress.expectedTotalBytes == null) ? null : progress.cumulativeBytesLoaded/progress.expectedTotalBytes);
      });

  static Widget icPersonOnError(double iconSize) => Image.asset(MyAssets.ic_person_light, width: iconSize, height: iconSize);
  static Widget icPostOnError([double iconSize]) => Image.asset(MyAssets.ic_image_broken, width: iconSize, height: iconSize);

  //endregion
}

class MyAssets {

  static const String ic_launcher = 'assets/icons/ic_launcher.png';
  static const String ic_launcher_adaptive = 'assets/icons/ic_launcher_adaptive.png';
  static const String ic_google = 'assets/icons/ic_google.png';
  static const String ic_person = 'assets/icons/ic_person.png';
  static const String ic_person_light = 'assets/icons/ic_person_light.png';

  static const String ic_cash = 'assets/icons/ic_cash.png';
  static const String ic_add = 'assets/icons/ic_add.png';
//  static const String ic_download = 'assets/icons/ic_download.png';
//  static const String ic_enter = 'assets/icons/ic_enter.png';
  static const String ic_lamp = 'assets/icons/ic_lamp.png';
//  static const String ic_lamp_p = 'assets/icons/ic_lamp_p.png';
  static const String ic_planilha = 'assets/icons/ic_planilha.png';
  static const String ic_sms = 'assets/icons/ic_sms.png';
  static const String ic_sms_2 = 'assets/icons/ic_sms_2.png';
//  static const String ic_home_svg = 'assets/icons/ic_home.svg';
//  static const String ic_home = 'assets/icons/ic_home.png';
//  static const String ic_key = 'assets/icons/ic_key.png';
  static const String ic_negativo = 'assets/icons/ic_negativo.png';
//  static const String ic_perfil = 'assets/icons/ic_perfil.png';
//  static const String ic_perfil_svg = 'assets/icons/ic_perfil.svg';
//  static const String ic_pesquisa = 'assets/icons/ic_pesquisa.png';
//  static const String ic_pesquisa_svg = 'assets/icons/ic_pesquisa.svg';
  static const String ic_positivo = 'assets/icons/ic_positivo.png';
  static const String ic_image_broken = 'assets/icons/ic_image_broken.png';

  static const String img_tutorial = 'assets/icons/img_tutorial.png';
  static const String img_tutorial_2 = 'assets/icons/img_tutorial_2.png';

  static const String ic_oki_logo = 'assets/icons/ic_oki_logo.png';

  static const String googlePayButtonDark = 'assets/icons/googlePayButtonDark.png';
  static const String googlePayButtonLight = 'assets/icons/googlePayButtonLight.png';

}
