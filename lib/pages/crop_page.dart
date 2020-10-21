import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protips/auxiliar/log.dart';
import 'package:protips/res/resources.dart';
import 'package:protips/res/strings.dart';

class CropImagePage extends StatefulWidget {
  final double aspect;
  CropImagePage([this.aspect]);
  @override
  _MyAppState createState() => new _MyAppState(aspect);
}
class _MyAppState extends State<CropImagePage> {

  _MyAppState(this.aspect);

  //region variaveis
  static const String TAG = 'CropImagePage';

  final double aspect;
  final picker = ImagePicker();
  final cropKey = GlobalKey<CropState>();

  File _file;
  File _lastCropped;
  bool _inProgress = false;
  //endregion

  @override
  void dispose() {
    super.dispose();
    _file?.delete();
  }

  @override
  void initState() {
    super.initState();
    _onOpenImage();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _file == null ? MyLayouts.splashScreen() : _buildCroppingImage(),
        floatingActionButton: _inProgress ? CircularProgressIndicator() : null,
      ),
    );
  }

  Widget _buildCroppingImage() {
    double aspectRatio = aspect;
    var iconColor = Colors.white;
    var textStyle = TextStyle(color: iconColor);

    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(_file, key: cropKey, aspectRatio: aspectRatio),
        ),
        BottomNavigationBar(
          onTap: _onBottomNavItemTap,
          items: [
            BottomNavigationBarItem(
                title: Text(MyStrings.CANCELAR, style: textStyle),
                icon: Icon(Icons.close, color: Colors.red)
            ),
            BottomNavigationBarItem(
                title: Text(MyTexts.ABRIR_IMAGEM, style: textStyle),
                icon: Icon(Icons.insert_photo, color: iconColor)
            ),
            BottomNavigationBarItem(
                title: Text(MyStrings.CONCLUIR, style: textStyle),
                icon: Icon(Icons.check_circle, color: iconColor)
            ),
          ],
        ),
        /*Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Text(
                  MyStrings.CANCELAR,
                  style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.textColor),
                ),
                onPressed: _cancelar,
              ),
              IconButton(
                tooltip: MyTexts.ABRIR_IMAGEM,
                // color: MyTheme.tintColor,
                icon: Icon(Icons.insert_photo),
                onPressed: _openImage,
              ),
//              FlatButton(
//                child: Text(
//                  MyTexts.ABRIR_IMAGEM,
//                  style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.textColor()),
//                ),
//                onPressed: _openImage,
//              ),
              IconButton(
                tooltip: MyStrings.CONCLUIR,
                // color: MyTheme.tintColor,
                icon: Icon(Icons.check_circle),
                onPressed: _cropImage,
              ),
            ],
          ),
        )*/
      ],
    );
  }

  _onBottomNavItemTap(position) {
    switch(position) {
      case 0:
        _onCancelar();
        break;
      case 1:
        _onOpenImage();
        break;
      case 2:
        _onCropImage();
        break;
    }
  }

  Future<void> _onOpenImage() async {
    final fileAux = await picker.getImage(
        source: ImageSource.gallery,
      imageQuality: 100
    );
    if (fileAux == null && _file == null)
      _onCancelar();
    final File file = File(fileAux.path);

    _file?.delete();

    setState(() {
      _file = file;
    });

  }

  Future<void> _onCropImage() async {
    File toReturn;
    _setInProgress(true);
    try {
      final scale = cropKey.currentState.scale;
      final area = cropKey.currentState.area;
      if (area == null)
        return;

      // escala para usar o número máximo possível de pixels
      // isso mostra uma imagem em resolução mais alta para aumentar a imagem cortada
    final sample = await ImageCrop.sampleImage(
      file: _file,
      preferredSize: (2000 / scale).round(),
    );

      final file = await ImageCrop.cropImage(
        file: sample,
        area: area,
      );

      await _lastCropped?.delete();
      _lastCropped = file;

      toReturn = await _lastCropped.exists() ? _lastCropped: null;
    } catch (e) {
      Log.e(TAG, 'cropImage', e);
    }
    _setInProgress(false);
    Navigator.pop(context, toReturn);
  }

  void _onCancelar() {
    Navigator.of(context).pop();
  }

  void _setInProgress(bool b) {
    setState(() {
      _inProgress = b;
    });
  }
}