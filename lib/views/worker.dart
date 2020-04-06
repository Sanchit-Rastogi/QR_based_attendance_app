import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class Worker extends StatefulWidget {
  @override
  _WorkerState createState() => _WorkerState();
}

class _WorkerState extends State<Worker> {
  bool _pressed = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  String qrText = "";
  bool submit = false;
  String check = "worker-attendance" + DateTime.now().day.toString();
  QRViewController controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
      });
      if (qrText == check) {
        setState(() {
          saveAttendance();
          _pressed = false;
          return null;
        });
      } else {
        setState(() {
          _pressed = false;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Try Again !'),
          duration: Duration(seconds: 2),
        ));
      }
    });
  }

  Future<void> saveAttendance() async {
    FirebaseUser user = await _auth.currentUser();
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    String userEmail = user.email;
    List<DateTime> dataList = [];
    dataList.add(DateTime.now());
    var data = await _firestore.collection('user').getDocuments();
    for (var d in data.documents) {
      if (d.data['email'] == userEmail) {
        await _firestore.collection('user').document(d.documentID).updateData({
          'attendance': FieldValue.arrayUnion(dataList),
          'lat': position.latitude ?? "1",
          'long': position.longitude ?? "1",
        });
      }
    }
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Attendance Given.'),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Worker"),
      ),
      body: Center(
        child: _pressed
            ? Column(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                        child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          _pressed = false;
                        });
                      },
                      child: Text("Cancel"),
                    )),
                  )
                ],
              )
            : RaisedButton(
                child: Text('Give Attendance'),
                onPressed: () {
                  setState(() {
                    _pressed = true;
                  });
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text("Logout"),
        onPressed: () async {
          await _auth.signOut();
          Navigator.pushNamed(context, 'login');
        },
      ),
    );
  }
}
