import 'package:flutter/material.dart';
import 'package:protips/res/theme.dart';

// ignore: must_be_immutable
class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar({@required this.tabs, @required this.color, this.height = 45});

  final Color color;
  final List<Widget> tabs;
  final double height;

  TabBar _tabBar;

  @override
  Size get preferredSize => _tabBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    // final double decorationSize = 3;
    var tabTextStyle = TextStyle(fontSize: 20);

    return Container(
      height: height,
      color: color,
      child: Stack(children: [
        // Divider(height: decorationSize, thickness: decorationSize, color: MyTheme.cardSpecial),
        TabBar(
            tabs: tabs,
//            indicatorWeight: 0.1,
            labelStyle: tabTextStyle,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.white
        ),
//        Align(
//          alignment: Alignment.bottomCenter,
//          child: Divider(height: decorationSize, thickness: decorationSize, color: Colors.white),
//        ),
      ]),
    );
  }
}