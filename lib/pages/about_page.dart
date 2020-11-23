import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/aplication.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/res/my_icons.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<AboutPage> {

  @override
  Widget build(BuildContext context) {
    //region variaveis
    var textColorSpecial = MyTheme.textColorSpecial;
    var textStyleSpecial = TextStyle(color: textColorSpecial);

    var iconSize = 21.0;

    var dividerP = Padding(padding: EdgeInsets.only(top: 10, right: 5));
    var dividerG = Padding(padding: EdgeInsets.only(top: 30));
    //endregion

    return Scaffold(
      appBar: AppBar(title: Text(Titles.ABOUT)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(50),
        child: Center(
          child: Column(children: [
            //Icone
            Image.asset(MyIcons.ic_launcher,
              width: 130,
              height: 130,
            ),
            dividerG,
            //Texto
            Text(MyResources.APP_NAME, style: TextStyle(fontSize: 22)),
            dividerP,
            Text(MyStrings.VERSAO + ': ' + Aplication.packageInfo.version),
            dividerG,
            Text(MyStrings.CONTATOS),
            dividerP,
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MyIcons.instagram, size: iconSize, color: textColorSpecial),
                  dividerP,
                  Text(MyResources.app_instagram, style: textStyleSpecial)
                ],
              ),
              onTap: _onInstagramTap,
            ),
            dividerP,
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(MyIcons.whatsapp, size: iconSize, color: textColorSpecial),
                  dividerP,
                  Text(MyResources.app_whatsapp, style: textStyleSpecial)
                ],
              ),
              onTap: _onPhoneTap,
            ),
            dividerP,
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email_outlined, color: textColorSpecial),
                  dividerP,
                  Text(MyResources.app_email, style: textStyleSpecial)
                ],
              ),
              onTap: _onEmailTap,
            ),
            Divider(height: 30),
            Text(MyStrings.POR),
            dividerP,
            Tooltip(
              message: MyResources.company_name,
              child: Image.asset(MyIcons.ic_oki_logo,
                width: 80,
                height: 80,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  _onEmailTap() => Import.openEmail(MyResources.app_email, context);
  _onPhoneTap() => Import.openWhatsApp(MyResources.app_whatsapp, context);
  _onInstagramTap() => Import.openInstagram(MyResources.app_instagram, context);

}