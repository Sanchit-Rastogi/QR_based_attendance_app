import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class WorkerDetails extends StatefulWidget {
  final String workerDocumentID;
  WorkerDetails({this.workerDocumentID});

  @override
  _WorkerDetailsState createState() => _WorkerDetailsState();
}

class _WorkerDetailsState extends State<WorkerDetails> {
  final Firestore _firestore = Firestore.instance;
  String email;
  double long;
  double lat;
  List<Timestamp> attendance = [];
  bool _isSaving = false;

  Future<void> getDetails() async {
    setState(() {
      _isSaving = true;
    });
    await _firestore
        .collection('user')
        .document(widget.workerDocumentID)
        .get()
        .then((DocumentSnapshot ds) {
      email = ds.data['email'];
      long = ds.data['long'];
      lat = ds.data['lat'];
      attendance = List.from(ds.data['attendance']);
    });
    setState(() {
      _isSaving = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Worker Details"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isSaving,
        child: Container(
          child: Column(
            children: <Widget>[
              Text(email),
              Text(long.toString()),
              Text(lat.toString()),
              Container(
                height: 300,
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(attendance[index].toDate().toString()),
                    );
                  },
                  itemCount: attendance.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
