import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/res/strings.dart';
import 'package:protips/res/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

int _currentPosition = 0;
int _posicMax = 1;

class TutorialPage extends StatefulWidget {
//  static const String tag = 'TutorialPage';
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<TutorialPage> with SingleTickerProviderStateMixin {
  static const String TAG = 'TutorialPage';

  @override
  Widget build(BuildContext context) {
    var textColor = MyTheme.textColor();
    var textTitleStyle = TextStyle(color: textColor, fontSize: 18);
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MyTheme.primary(),
      body: Column(children: [
        Container(
            height: screenHeight / 4,
            child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('BEM VINDO PRO\'TIPSTER', style: textTitleStyle),
                  Container(width: 200, child: Divider(thickness: 3, color: MyTheme.tintColor())),
                ]))
        ),
        Container(height: screenHeight / 2, child: Page1()),
        Divider(height: 40, color: MyTheme.primary()),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if(_currentPosition > 0)
                Tooltip(message: 'Voltar',
                child: IconButton(
                    icon: Icon(Icons.arrow_back, color: MyTheme.tintColor()),
                    onPressed: () {
                      if (_currentPosition > 0)
                        setState(() {
                          _currentPosition--;
                        });
                    })),
              if (_currentPosition < _posicMax)
                Tooltip(message: 'Seguir',
                child: IconButton(
                    icon: Icon(Icons.arrow_forward, color: MyTheme.tintColor()),
                    onPressed: () {
                      if (_currentPosition < _posicMax)
                        setState(() {
                          _currentPosition++;
                        });
                    })),
              if (_currentPosition == _posicMax)
                Tooltip(message: 'Finalizar',
                child: IconButton(
                    icon: Icon(Icons.check_circle, color: MyTheme.tintColor()),
                    onPressed: () => _onBack(context))),
            ])
      ]),
          floatingActionButton: _currentPosition < _posicMax ? FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: MyTheme.primary(),
          label: Text('Pular', style: TextStyle(color: textColor)),
          onPressed: () => _onBack(context)
      ) : Container(),
    );
  }

  _onBack(BuildContext context) async {
    _currentPosition = 0;
    var pref = await SharedPreferences.getInstance();
    pref.setBool(SharedPreferencesKey.ULTIMO_TUTORIAL_OK, true);
    Navigator.pop(context);
  }
}

class Page1 extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => Page1State();
}
class Page1State extends State<Page1> {

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(color: MyTheme.textColor());

    var divider = Divider(height: 25, color: MyTheme.primaryLight());
    var textAlign = TextAlign.center;
    return Scaffold(
        backgroundColor: MyTheme.primaryLight(),
        body: Center(
            child: _currentPosition == 0 ?
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('AGORA VOCÊ É UM TIPSTER\nEM NOSSA PLATAFORMA',
                    style: textStyle, textAlign: textAlign),
                divider,
                Text('Siga um pequeno tutorial\ne fique por dentro'
                    .toUpperCase(), style: textStyle, textAlign: textAlign),
              ]) :
            _currentPosition == 1 ?
            Image.asset(MyAssets.img_tutorial) :
            Column()
        )
    );
  }

}