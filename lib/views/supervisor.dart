import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Supervisor extends StatefulWidget {
  @override
  _SupervisorState createState() => _SupervisorState();
}

class _SupervisorState extends State<Supervisor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String qrText = "";
  final Firestore _firestore = Firestore.instance;
  QRViewController controller;
  String check = "worker-attendance" + DateTime.now().day.toString();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _pressed = false;

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
          'lat': position.latitude,
          'long': position.longitude,
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

  void initState() {
    // TODO: implement initState
    super.initState();
    print("worker-attendance" + DateTime.now().day.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Supervisor"),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushNamed(context, 'login');
              },
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ),
              label: Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ))
        ],
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Give Attendance'),
                    onPressed: () {
                      setState(() {
                        _pressed = true;
                      });
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Make sure your loaction is turned on.")
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.person_add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext bc) {
              return Center(
                child: QrImage(
                  data: "worker-attendance" + DateTime.now().day.toString(),
                  version: QrVersions.auto,
                  size: 300.0,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
