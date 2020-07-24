import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:protips/res/resources.dart';

class CropImagePage extends StatefulWidget {
  static const String tag = 'CropImagePage';
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<CropImagePage> {

  final picker = ImagePicker();
  final cropKey = GlobalKey<CropState>();
  File _file;
  File _sample;
  File _lastCropped;

  @override
  void initState() {
    super.initState();
    _openImage();
  }

  @override
  void dispose() {
    super.dispose();
    _file?.delete();
    _sample?.delete();
//    _lastCropped?.delete();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: _sample == null ? _buildOpeningImage() : _buildCroppingImage(),
        ),
      ),
    );
  }

  Widget _buildOpeningImage() {
    return Center(child: _buildOpenImage());
  }

  Widget _buildCroppingImage() {
    double aspectRatio = ModalRoute.of(context).settings.arguments;
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(_sample, key: cropKey, aspectRatio: aspectRatio),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Text(
                  MyStrings.CONCLUIR,
                  style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.textColor()),
                ),
                onPressed: _cropImage,
              ),
              _buildOpenImage(),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOpenImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlatButton(
          child: Text(
            MyStrings.ABRIR_IMAGEM,
            style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.textColor()),
          ),
          onPressed: _openImage,
        ),
        FlatButton(
          child: Text(
            MyStrings.CANCELAR,
            style: Theme.of(context).textTheme.button.copyWith(color: MyTheme.textColor()),
          ),
          onPressed: _cancelar,
        ),
      ],
    );
  }

  Future<void> _openImage() async {
    final fileAux = await picker.getImage(source: ImageSource.gallery);
    final File file = File(fileAux.path);
    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredSize: context.size.longestSide.ceil(),
    );

    _sample?.delete();
    _file?.delete();

    setState(() {
      _sample = sample;
      _file = file;
    });

  }

  Future<void> _cropImage() async {
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

//    sample.delete();

    _lastCropped?.delete();
    _lastCropped = file;

//    await _lastCropped.create();
    File toReturn = await _lastCropped.exists() ? _lastCropped: null;

    Navigator.pop(context, toReturn);
  }

  _cancelar() {
    Navigator.of(context).pop();
  }
}