import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/res/resources.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<AboutPage> {

  @override
  Widget build(BuildContext context) {
    var divider = Divider(height: 30, color: Colors.white);
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
            Text(MyStrings.APP_NAME, style: TextStyle(fontSize: 22)),
            divider,
            Text(MyStrings.VERSAO + ': ' + Aplication.packageInfo.version),
            divider,
            Text(MyStrings.CONTATOS),
            GestureDetector(
              child: Text(MyStrings.app_whatsapp, style: TextStyle(color: MyTheme.primary())),
              onTap: () {Import.openWhatsApp(MyStrings.app_whatsapp, context);},
            ),
            GestureDetector(
              child: Text(MyStrings.app_email, style: TextStyle(color: MyTheme.primary())),
              onTap: () {Import.openEmail(MyStrings.app_email, context);},
            ),
            Divider(height: 30),
            Text(MyStrings.POR),
            Text(MyStrings.company_name),
          ]),
        ),
      ),
    );
  }
}