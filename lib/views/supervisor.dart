import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Supervisor extends StatefulWidget {
  @override
  _SupervisorState createState() => _SupervisorState();
}

class _SupervisorState extends State<Supervisor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void initState() {
    // TODO: implement initState
    super.initState();
    print("worker-attendance" + DateTime.now().day.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
