import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'workerModify.dart';

class Director extends StatefulWidget {
  @override
  _DirectorState createState() => _DirectorState();
}

class _DirectorState extends State<Director> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<WorkerModel> workers = [];
  String workerDataId;
  bool _isSaving = false;

  Future<void> fetchData() async {
    setState(() {
      _isSaving = true;
    });
    var data = await _firestore.collection('user').getDocuments();
    for (var d in data.documents) {
      if (d.data['type'] == 'worker' || d.data['type'] == 'supervisor') {
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Director"),
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
                          builder: (context) => WorkerModify(
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
