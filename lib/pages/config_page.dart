import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/model/post.dart';
import 'package:protips/pages/pagamento_test_page.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';

class ConfigPage extends StatefulWidget{
  final bool isAdmin;
  ConfigPage({this.isAdmin = false});
  @override
  State<StatefulWidget> createState() => MyWidgetState(isAdmin);
}
class MyWidgetState extends State<ConfigPage> {

  MyWidgetState([this.isAdmin = false]);

  //region Variaveis
  bool isAdmin;
  bool inProgress = false;
  //endregion

  //region overrides

  @override
  Widget build(BuildContext context) {
    var divider = Divider(color: MyTheme.primary());

    return Scaffold(
      appBar: isAdmin ? null : AppBar(title: Text(Titles.CONFIGURACOES)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin)...[
              Text('Admin Área'),
              divider,
              ElevatedButton(
                child: Text('App Versão: ${Aplication.appVersionInDatabase}'),
                onPressed: !inProgress ? _setAppVersao : null,
              ),
              ElevatedButton(
                child: Text('Abrir tela de teste de Pagamento'),
                onPressed: () => Navigate.to(context, PagamentoTestPage(10.0)),
              ),
              ElevatedButton(
                child: Text('Enviar Tip de teste'),
                onPressed: () {
                  if (!Firebase.user.dados.isTipster) {
                    Log.snackbar('Esta não é uma conta Tipster');
                    return;
                  }
                  Post.criarTeste(isPublico: false).postar(isTeste: true);
                },
              ),
            ]
            else...[

            ]
          ],
        ),
      ),
      floatingActionButton: inProgress ? CircularProgressIndicator() :
      FloatingActionButton.extended(label: Text(MyStrings.SALVAR), onPressed: _onSalvar),
    );
  }

  //endregion

  //region Metodos

  void _onSalvar() async {
    Log.snackbar(MyTexts.DADOS_SALVOS);
  }

  void _setAppVersao() async {
    var controler = TextEditingController();
    int currentVersion = Aplication.appVersionInDatabase;

    controler.text = currentVersion.toString();
    int newVersion = await showDialog(
        context: context,
      builder: (context) => AlertDialog(
        title: Text('Número da versão do app'),
        content: TextField(
          controller: controler,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Número inteiro'
          ),
        ),
        actions: [
          FlatButton(
            child: Text(MyStrings.CANCELAR),
            onPressed: () => Navigator.pop(context, currentVersion),
          ),
          FlatButton(
            child: Text(MyStrings.OK),
            onPressed: () => Navigator.pop(context, int.parse(controler.text)),
          ),
        ],
      )
    );

    if (newVersion != currentVersion) {
      Aplication.appVersionInDatabase = newVersion;

      _setInProgress(true);
      await Firebase.databaseReference
          .child(FirebaseChild.VERSAO)
          .set(newVersion)
          .then((value) => Log.snackbar(MyTexts.DADOS_SALVOS))
          .catchError((e) => Log.snackbar(MyErros.ERRO_GENERICO));
      _setInProgress(false);
    }
  }

  void _setInProgress(bool b) {
    setState(() {
      inProgress = b;
    });
  }

  //endregion
}