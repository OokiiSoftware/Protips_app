import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:protips/auxiliar/aplication.dart';
import 'package:protips/auxiliar/config.dart';
import 'package:protips/auxiliar/firebase.dart';
import 'package:protips/auxiliar/import.dart';
import 'package:protips/auxiliar/notification_manager.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/auxiliar/preferences.dart';
import 'package:protips/model/post.dart';
import 'package:protips/pages/pagamento_test_page.dart';
import 'package:protips/res/dialog_box.dart';
import 'package:protips/res/layouts.dart';
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

  List<DropdownMenuItem<String>> _dropDownThema;
  String _currentThema;

  //endregion

  //region overrides

  @override
  void initState() {
    super.initState();
    _dropDownThema = Import.getDropDownMenuItems(Arrays.thema);
    _currentThema = Preferences.getString(PreferencesKey.THEME, padrao: Arrays.thema[0]);
  }

  @override
  Widget build(BuildContext context) {
    var divider = Divider(color: MyTheme.primary);

    return Scaffold(
      appBar: isAdmin ? null : AppBar(
          title: Text(Titles.CONFIGURACOES),
        actions: [
          if (RunTime.semInternet)
            Layouts.icAlertInternet,
          Layouts.appBarActionsPadding,
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme
            Row(
              children: [
                Text('Tema'),
                Padding(padding: EdgeInsets.only(right: 10)),
                DropdownButton(
                  value: _currentThema,
                  items: _dropDownThema,
                  onChanged: _onThemeChanged,
                ),
              ],
            ),
            divider,
            if (isAdmin)...[
              Text('Admin Área'),
              divider,
              ElevatedButton(
                child: Text('App Versão: ${Aplication.appVersionInDatabase}'),
                onPressed: !inProgress ? _setAppVersao : null,
              ),
              ElevatedButton(
                child: Text('Abrir tela de teste de Pagamento'),
                onPressed: () => Navigate.to(context, PagamentoTestPage()),
              ),
              ElevatedButton(
                child: Text('Enviar Tip de teste'),
                onPressed: () async {
                  if (!FirebasePro.userPro.dados.isTipster) {
                    Log.snackbar('Esta não é uma conta Tipster');
                    return;
                  }
                  _setInProgress(true);
                  await Post.criarTeste(isPublico: false).postar(isTeste: true, salvar: false);
                  _setInProgress(false);
                },
              ),
              ElevatedButton(
                child: Text('Atualizar Tópicos'),
                onPressed: () async {
                  _setInProgress(true);
                  await NotificationManager.instance.atualizarTopics();
                  Log.snackbar('Tópicos atualizados.');
                  _setInProgress(false);
                },
              ),
              ElevatedButton(
                child: Text('Enviar Notificação de teste'),
                onPressed: () async {
                  _setInProgress(true);
                  await NotificationManager.instance.sendDepuracaoTopic();
                  Log.snackbar('Notificação enviada.');
                  _setInProgress(false);
                },
              ),
              ElevatedButton(
                child: Text('Abrir Play Story'),
                onPressed: () {
                  Import.openUrl(MyResources.playStoryLink, context);
                },
              ),

              ElevatedButton(
                child: Text('SnackBar'),
                onPressed: () {
                  Log.snackbar('Teste de snackbar');
                },
              ),
              ElevatedButton(
                child: Text('SnackBar Erro'),
                onPressed: () {
                  Log.snackbar('Teste de snackbar erro', isError: true);
                },
              ),
            ]
          ],
        ),
      ),
      floatingActionButton: inProgress ? CircularProgressIndicator() : null
      /*FloatingActionButton.extended(label: Text(MyStrings.SALVAR), onPressed: _onSalvar)*/,
    );
  }

  //endregion

  //region Metodos

  void onSalvar() async {
    Log.snackbar(MyTexts.DADOS_SALVOS);
  }

  void _onThemeChanged(String value) async {
    setState(() {
      _currentThema = value;
    });
    await Preferences.setString(PreferencesKey.THEME, value);
    Brightness brightness = MyTheme.getBrilho(value);
    await DynamicTheme.of(context).setBrightness(brightness);
    // _setThemeLog(value);
  }

  void _setAppVersao() async {
    var controler = TextEditingController();
    int currentVersion = Aplication.appVersionInDatabase;

    controler.text = currentVersion.toString();
    var title = 'Número da versão do app';
    var content = TextField(
      controller: controler,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          labelText: 'Número inteiro'
      ),
    );
    var result = await DialogBox.dialogCancelOK(context, title: title, content: [content]);
    if (!result.isPositive) return;
    int newVersion = int.parse(controler.text);

    if (newVersion != currentVersion) {
      Aplication.appVersionInDatabase = newVersion;

      _setInProgress(true);
      await FirebasePro.database
          .child(FirebaseChild.VERSAO)
          .set(newVersion)
          .then((value) => Log.snackbar(MyTexts.DADOS_SALVOS))
          .catchError((e) => Log.snackbar(MyErros.ERRO_GENERICO));
      _setInProgress(false);
    }
  }

  void _setInProgress(bool b) {
    if(!mounted) return;
    setState(() {
      inProgress = b;
    });
  }

  //endregion
}