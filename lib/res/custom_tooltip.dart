import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';

class CustomTooltip {
  //region variaveis
  double _popupWidth = 30.0;
  double _popupHeight = 30.0;
  double arrowHeight = 10.0;
  OverlayEntry _entry;
  String _text;
  TextStyle _textStyle;
  Offset _offset;
  Rect _showRect;
  bool _isDownArrow = true;
  int _tempo;

  VoidCallback dismissCallback;

  Size _screenSize;

  BuildContext context;
  Color _backgroundColor;

  bool _isVisible = false;

  BorderRadius _borderRadius;
  //endregion

  CustomTooltip(this.context, {
    VoidCallback onDismiss,
    Color backgroundColor,
    @required String text,
    int tempo,
    BorderRadius borderRadius,
  }) {
    this.dismissCallback = onDismiss;
    this._text = text;
    this._popupHeight = 30;
    this._popupWidth = text.length * 9.0;
    this._textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      decoration: TextDecoration.none
    );
    this._backgroundColor = backgroundColor ?? Colors.black54;
    this._borderRadius = borderRadius ?? BorderRadius.circular(10.0);
    this._tempo = tempo ?? 2000;
  }

  /// Shows a popup near a widget with key [widgetKey] or [rect].
  void show({Rect rect, GlobalKey widgetKey}) {
    if (rect == null && widgetKey == null) {
      print("both 'rect' and 'key' can't be null");
      return;
    }

    this._text = _text ?? this._text;
    this._showRect = rect ?? _getWidgetGlobalRect(widgetKey);
    this._screenSize = window.physicalSize / window.devicePixelRatio;
    this.dismissCallback = dismissCallback;

    if (_popupWidth > _screenSize.width) {
      _popupWidth = _screenSize.width / 1.5;
      _popupHeight = _text.length * 1.0;
    }

    _calculatePosition(context);

    _entry = OverlayEntry(builder: (context) {
      return buildPopupLayout(_offset);
    });

    Overlay.of(context).insert(_entry);
    _isVisible = true;
    _timeToDismiss();
  }

  void _calculatePosition(BuildContext context) {
    _offset = _calculateOffset(context);
  }

  /// Returns globalRect of widget with key [key]
  Rect _getWidgetGlobalRect(GlobalKey key) {
    RenderBox renderBox = key.currentContext.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
        offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
  }

  /// Returns calculated widget offset using [context]
  Offset _calculateOffset(BuildContext context) {
    double dx = _showRect.left + _showRect.width / 2.0 - _popupWidth / 2.0;
    if (dx < 10.0) {
      dx = 10.0;
    }

    if (dx + _popupWidth > _screenSize.width && dx > 10.0) {
      double tempDx = _screenSize.width - _popupWidth - 10;
      if (tempDx > 10) dx = tempDx;
    }

    double dy = _showRect.top - _popupHeight;
    if (dy <= MediaQuery.of(context).padding.top + 10) {
      // not enough space above, show popup under the widget.
      dy = arrowHeight + _showRect.height + _showRect.top;
      _isDownArrow = false;
    } else {
      dy -= arrowHeight;
      _isDownArrow = true;
    }

    return Offset(dx, dy);
  }

  /// Builds Layout of popup for specific [offset]
  LayoutBuilder buildPopupLayout(Offset offset) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: <Widget>[
          // triangle arrow
          Positioned(
            left: _showRect.left + _showRect.width / 2.0 - 7.5,
            top: _isDownArrow
                ? offset.dy + _popupHeight
                : offset.dy - arrowHeight,
            child: CustomPaint(
              size: Size(15.0, arrowHeight),
              painter: TrianglePainter(
                  isDownArrow: _isDownArrow, color: _backgroundColor),
            ),
          ),
          // popup content
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: Container(
                padding: EdgeInsets.all(4.0),
                width: _popupWidth,
                height: _popupHeight,
                decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: _borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF808080),
                        blurRadius: 1.0,
                      ),
                    ]),
                child: Center(
                  child: Text(_text,
                    style: _textStyle,
                  ),
                )),
          )
        ],
      );
    });
  }

  _timeToDismiss() async {
    await Future.delayed(Duration(milliseconds: _tempo));
    dismiss();
  }

  /// Dismisses the popup
  void dismiss() {
    if (!_isVisible) {
      return;
    }
    _entry.remove();
    _isVisible = false;
    if (dismissCallback != null) {
      dismissCallback();
    }
  }
}

/// [TrianglePainter] is custom painter for drawing a triangle for popup
/// to point specific widget
class TrianglePainter extends CustomPainter {
  bool isDownArrow;
  Color color;

  TrianglePainter({this.isDownArrow = true, this.color});

  /// Draws the triangle of specific [size] on [canvas]
  @override
  void paint(Canvas canvas, Size size) {
    Path path = new Path();
    Paint paint = new Paint();
    paint.strokeWidth = 2.0;
    paint.color = color;
    paint.style = PaintingStyle.fill;

    if (isDownArrow) {
      path.moveTo(0.0, -1.0);
      path.lineTo(size.width, -1.0);
      path.lineTo(size.width / 2.0, size.height);
    } else {
      path.moveTo(size.width / 2.0, 0.0);
      path.lineTo(0.0, size.height + 1);
      path.lineTo(size.width, size.height + 1);
    }

    canvas.drawPath(path, paint);
  }

  /// Specifies to redraw for [customPainter]
  @override
  bool shouldRepaint(CustomPainter customPainter) {
    return true;
  }
}
