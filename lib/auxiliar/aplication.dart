import 'dart:ui';
import 'package:package_info/package_info.dart';
import 'package:protips/auxiliar/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device.dart';
import 'firebase.dart';
import 'import.dart';
import 'log.dart';

class Aplication {
  static const String TAG = 'Aplication';

  static int appVersionInDatabase = 0;
  static PackageInfo packageInfo;

  static Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
    Device.deviceData = await DeviceInfo.getDeviceInfo();
    Preferences.instance = await SharedPreferences.getInstance();

    await OfflineData.createPerfilDirectory();
    await OfflineData.createPostDirectory();
    await OfflineData.readDirectorys();
  }

  static Future<String> buscarAtualizacao() async {
    Log.d(TAG, 'buscarAtualizacao', 'Iniciando');
    int _value = await FirebasePro.database
        .child(FirebaseChild.VERSAO)
        .once()
        .then((value) => value.value)
        .catchError((e) {
      Log.e(TAG, 'buscarAtualizacao', e);
      return -1;
    });
    String url;

    Log.d(TAG, 'buscarAtualizacao', 'Web Version', _value, 'Local Version', packageInfo.buildNumber);
    appVersionInDatabase = _value;
    int appVersion = int.parse(packageInfo.buildNumber);

    if (_value > appVersion) {
      url = 'https://play.google.com/store/apps/details?id=com.ookiisoftware.protips';
//      String folder = Platform.isAndroid ? FirebaseChild.APK : FirebaseChild.IOS;
//      String ext = Platform.isAndroid ? '.apk' : '';
//      String fileName = MyStrings.APP_NAME + '_' + _value.toString() + ext;
//      Log.d(TAG, 'buscarAtualizacao', 'fileName', fileName);
//      try {
//        url = await getFirebase.storage()
//            .child(FirebaseChild.APP)
//            .child(folder)
//            .child(fileName)
//            .getDownloadURL();
//      } catch(e) {
//        Log.e(TAG, 'buscarAtualizacao', e);
//      }
    }

    return url;
  }

  static bool get isRelease => bool.fromEnvironment('dart.vm.product');

  static Locale get locale => Locale('pt', 'BR');
}