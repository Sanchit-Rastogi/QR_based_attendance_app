import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:attendanceapp/views/workerDetails.dart';

class Staff extends StatefulWidget {
  @override
  _StaffState createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  List<WorkerModel> workers = [];
  String workerDataId;
  bool _isSaving = false;

  Future<void> fetchData() async {
    setState(() {
      _isSaving = true;
    });
    var data = await _firestore.collection('user').getDocuments();
    for (var d in data.documents) {
      if (d.data['type'] == 'worker') {
        workers.add(WorkerModel(
          id: d.documentID,
          email: d.data['email'],
        ));
      }
    }
    setState(() {
      _isSaving = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Staff"),
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
      body: ModalProgressHUD(
        inAsyncCall: _isSaving,
        child: Container(
          padding: EdgeInsets.all(5),
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: FutureBuilder(builder: (context, snap) {
            if (snap.connectionState == ConnectionState.none &&
                snap.hasData == null) {
              return Container();
            }
            return ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(workers[index].email),
                  trailing: FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkerDetails(
                            workerDocumentID: workers[index].id,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.navigate_next),
                    label: Text("Details"),
                  ),
                );
              },
              itemCount: workers.length,
            );
          }),
        ),
      ),
    );
  }
}

class WorkerModel {
  String email;
  String id;

  WorkerModel({this.email, this.id});
}
