import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:validators/validators.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:device_preview/device_preview.dart';
import 'package:thomsoncloud2/persistent%20_uil.dart';
import 'package:thomsoncloud2/web_view.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await PersistentUrl.initi();
//   runApp(
//     DevicePreview(
//       enabled: !kReleaseMode,
//       builder: (context) => Phoenix(child: MyApp()), // Wrap your app
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(

//       debugShowCheckedModeBanner :false,
//       useInheritedMediaQuery: true,
//       locale: DevicePreview.locale(context),
//       builder: DevicePreview.appBuilder,
//       theme: ThemeData.light(),
//       darkTheme: ThemeData.dark(),
//       home: const MyHome(),
//     );
//   }
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PersistentUrl.initi();
  await Future.delayed(Duration(seconds: 3));
  runApp(Phoenix(
      child: const GetMaterialApp(
          debugShowCheckedModeBanner: false, home: MyHome())));
}

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const QRViewPage();
  }
}

class QRViewPage extends StatefulWidget {
  const QRViewPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isUrlValid = false;
  String? localUrl;
  @override
  void initState() {
    super.initState();
    localUrl = PersistentUrl.GetLocalUrl() ?? null;
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return localUrl == null
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0XFF212938),
              title: Row(children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 76, 92, 122),
                      elevation: 15,
                      minimumSize: const Size(100, 42),
                    ),
                    onPressed: () async {
                      await controller?.toggleFlash();
                      setState(() {});
                    },
                    child: FutureBuilder(
                      future: controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        return const Text(
                          'Light',
                          style: TextStyle(fontSize: 20),
                        );
                      },
                    )),
                const SizedBox(
                  width: 40,
                ),
                const Text(
                  "QR Scanner",
                  style: TextStyle(fontStyle: FontStyle.normal),
                )
              ]),
            ),
            body: _buildQrView(context))
        : WebViewPage(result: localUrl);
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width * 0.6);

    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;

        isUrlValid = isURL('${result!.code}', requireTld: false);

        if (isUrlValid == true) {
          controller.pauseCamera();
          controller.stopCamera();
          //storing the uil in local
          PersistentUrl.SetLocalUrl(result!.code!);
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => WebViewPage(
                result: result!.code,
              ),
            ),
            (route) => false, //disable back feature
          );
        } else {
          Fluttertoast.showToast(
              msg: "Not a valid URL",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          //restart the app
          Phoenix.rebirth(context);
        }
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
