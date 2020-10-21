// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class OpenContainerWrapper extends StatelessWidget {
  const OpenContainerWrapper({
    this.onClosed,
    this.tooltip = '',
    @required this.child,
    @required this.statefulWidget,
    this.background = Colors.transparent,
  });

  final ClosedCallback<bool> onClosed;
  final StatefulWidget statefulWidget;
  final Widget child;
  final String tooltip;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      closedElevation: 0,
      openElevation: 0,
      closedColor: background,
      openColor: background,
      closedShape: RoundedRectangleBorder(),
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: Duration(milliseconds: 500),
      openBuilder: (BuildContext context, VoidCallback _) => statefulWidget,
      onClosed: onClosed,
      tappable: false,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        if (tooltip.isEmpty)
          return widget(openContainer);
        return Tooltip(
          message: tooltip,
          child: widget(openContainer),
        );
      },
    );
  }

  Widget widget(VoidCallback openContainer) => InkWell(
    onTap: openContainer,
    child: child,
  );
}
