//import 'package:flutter/material.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';
//
//import 'package:flutter/material.dart';
//import 'package:qr_flutter/qr_flutter.dart';
//
//class Home extends StatefulWidget {
//  @override
//  _HomeState createState() => _HomeState();
//}
//
//class _HomeState extends State<Home> {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("Attendance"),
//      ),
//      body: Center(
//        child: QrImage(
//          data: "attendance",
//          version: QrVersions.auto,
//          size: 300.0,
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.camera),
//        onPressed: () {
//          Navigator.pushNamed(context, 'scanQR');
//        },
//      ),
//    );
//  }
//}
//
//
//
//
//
//
//class ScanQR extends StatefulWidget {
//  @override
//  _ScanQRState createState() => _ScanQRState();
//}
//
//class _ScanQRState extends State<ScanQR> {
//  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//  var qrText = "";
//  QRViewController controller;
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Column(
//        children: <Widget>[
//          Expanded(
//            flex: 5,
//            child: QRView(
//              key: qrKey,
//              onQRViewCreated: _onQRViewCreated,
//            ),
//          ),
//          Expanded(
//            flex: 1,
//            child: Center(
//              child: Text('Scan result: $qrText'),
//            ),
//          )
//        ],
//      ),
//    );
//  }
//
//  void _onQRViewCreated(QRViewController controller) {
//    this.controller = controller;
//    controller.scannedDataStream.listen((scanData) {
//      setState(() {
//        qrText = scanData;
//      });
//    });
//  }
//
//  @override
//  void dispose() {
//    controller?.dispose();
//    super.dispose();
//  }
//}
