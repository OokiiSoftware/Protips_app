import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<AboutPage> {

  @override
  Widget build(BuildContext context) {
    var textColorSpecial = MyTheme.textColorSpecial;

    var divider = Padding(padding: EdgeInsets.only(top: 30));

    return Scaffold(
      appBar: AppBar(title: Text(Titles.ABOUT)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(50),
        child: Center(
          child: Column(children: [
            //Icone
            Image.asset(MyAssets.ic_launcher,
              width: 130,
              height: 130,
            ),
            divider,
            //Texto
            Text(MyResources.APP_NAME, style: TextStyle(fontSize: 22)),
            divider,
            Text(MyStrings.VERSAO + ': ' + Aplication.packageInfo.version),
            divider,
            Text(MyStrings.CONTATOS),
            GestureDetector(
              child: Text(MyResources.app_whatsapp, style: TextStyle(color: textColorSpecial)),
              onTap: () {Import.openWhatsApp(MyResources.app_whatsapp, context);},
            ),
            GestureDetector(
              child: Text(MyResources.app_email, style: TextStyle(color: textColorSpecial)),
              onTap: () {Import.openEmail(MyResources.app_email, context);},
            ),
            Divider(height: 30),
            Text(MyStrings.POR),
            Padding(padding: EdgeInsets.only(top: 10)),
            Tooltip(
              message: MyResources.company_name,
              child: Image.asset(MyAssets.ic_oki_logo,
                width: 80,
                height: 80,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}