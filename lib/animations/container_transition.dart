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
    @required this.statefulWidget
  });

  final ClosedCallback<bool> onClosed;
  final StatefulWidget statefulWidget;
  final Widget child;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: Duration(milliseconds: 500),
      openBuilder: (BuildContext context, VoidCallback _) => statefulWidget,
      onClosed: onClosed,
      tappable: false,
      closedBuilder: (BuildContext context, VoidCallback openContainer) {
        if (tooltip.isEmpty)
          return InkWell(
            onTap: openContainer,
            child: child,
          );
        return Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: openContainer,
            child: child,
          ),
        );
      },
    );
  }
}
