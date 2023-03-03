import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../utils/toast_utils.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (kIsWeb) {
    } else if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebPage();
    }
    return _buildPlatformPage();
  }

  Widget _buildPlatformPage() {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FutureBuilder(
              future: Permission.camera.request(),
              builder: (BuildContext context,
                  AsyncSnapshot<PermissionStatus> snapshot) {
                if (snapshot.data == null ||
                    snapshot.data != PermissionStatus.granted) {
                  return Container(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        Permission.camera.request();
                      },
                      child: const Text('没有授权，请授权'),
                    ),
                  );
                }
                return Positioned.fill(
                  child: QRView(
                    overlay: QrScannerOverlayShape(),
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                );
              }),
          Positioned(
            left: 0,
            top: 20,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫一扫'),
      ),
      body: const Center(
        child: Text('web不支持扫一扫'),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      ToastUtils.toast(
          'Barcode Type: ${describeEnum(scanData!.format)}   Data: ${scanData!.code}');
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
