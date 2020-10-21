import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:protips/auxiliar/preferences.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/res/theme.dart';

int _currentPosition = 0;
int _posicaoMax = 2;

class TutorialPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyWidgetState();
}
class MyWidgetState extends State<TutorialPage> with SingleTickerProviderStateMixin {
  static const String TAG = 'TutorialPage';

  @override
  void initState() {
    super.initState();
    _currentPosition = Preferences.getInt(PreferencesKey.TUTORIAL_POSITION);
  }

  @override
  Widget build(BuildContext context) {
    var textColor = Colors.white;
    var iconColor = Colors.white;
    var textStyle = TextStyle(color: textColor);
    var textTitleStyle = TextStyle(color: textColor, fontSize: 18);
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MyTheme.primary,
      body: Column(children: [
        Container(
            height: screenHeight / 4,
            child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('BEM VINDO PRO\'TIPSTER', style: textTitleStyle),
                  Container(width: 200, child: Divider(thickness: 2, /*color: MyTheme.tintColor*/)),
                ]))
        ),
        Container(height: screenHeight / 2, child: Page()),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              title: Text('Voltar', style: textStyle),
              icon: Icon(Icons.arrow_back, color: iconColor)
          ),
          if(_currentPosition < _posicaoMax)
            BottomNavigationBarItem(
              title: Text('Seguir', style: textStyle),
              icon: Icon(Icons.arrow_forward, color: iconColor)
            )
          else
            BottomNavigationBarItem(
                title: Text('Concluir', style: textStyle),
                icon: Icon(Icons.check_circle, color: iconColor)
            ),
          if (_currentPosition < _posicaoMax)
            BottomNavigationBarItem(
                title: Text('Pular', style: textStyle),
                icon: Icon(Icons.close, color: iconColor)
            )
        ],
        onTap: _onBottomNavItemTap,
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //     elevation: 0,
      //     backgroundColor: MyTheme.primary(),
      //     label: Text('Pular', style: TextStyle(color: textColor)),
      //     onPressed: () => _onBack(context)
      // ),
    );
  }

  _onBottomNavItemTap(position) {
    switch(position) {
      case 0:
        if (_currentPosition > 0)
          setState(() {
            _currentPosition--;
          });
        break;
      case 1:
        if (_currentPosition < _posicaoMax)
          setState(() {
            _currentPosition++;
          });
        else
          _onBack(context);
        break;
      case 2:
        _onBack(context);
        break;
    }
  }

  _onBack(BuildContext context) {
    Preferences.setBool(PreferencesKey.ULTIMO_TUTORIAL_OK, true);
    Preferences.setInt(PreferencesKey.TUTORIAL_POSITION, _currentPosition);
    Navigator.pop(context);
  }
}

class Page extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(/*color: MyTheme.textColor,*/ fontSize: 18);

    var divider = Divider(height: 25, color: MyTheme.primaryLight);
    var textAlign = TextAlign.center;
    return Scaffold(
        backgroundColor: MyTheme.primaryLight,
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentPosition == 0)...[
                    Text(
                        'AGORA VOCÊ É UM TIPSTER\nEM NOSSA PLATAFORMA',
                        style: textStyle,
                        textAlign: textAlign
                    ),
                    divider,
                    Text(
                        'Siga um pequeno tutorial\ne fique por dentro'.toUpperCase(),
                        style: textStyle,
                        textAlign: textAlign
                    ),
                  ] else if (_currentPosition == 1)...[
                    Image.asset(MyAssets.img_tutorial)
                  ] else if (_currentPosition == 2)...[
                    Image.asset(MyAssets.img_tutorial_2),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        'Em \'Meus Filiados\' controle quem pode visualizar suas Tips durante o mês.',
                        style: textStyle,
                      ),
                    )
                  ]
                ]
            )
        )
    );
  }

}