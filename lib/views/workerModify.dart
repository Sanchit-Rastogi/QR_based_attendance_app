import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';

class WorkerModify extends StatefulWidget {
  final String workerDocumentID;
  WorkerModify({this.workerDocumentID});

  @override
  _WorkerModifyState createState() => _WorkerModifyState();
}

class _WorkerModifyState extends State<WorkerModify> {
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
    try {
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
    } catch (exp) {
      Navigator.pop(context);
      _isSaving = false;
    }
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
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: <Widget>[
              Text(
                "Worker Email - " + email ?? "",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                width: 250,
                child: RaisedButton(
                  color: Colors.lightBlue,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        "Worker's Location   ",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.map,
                        color: Colors.white,
                      )
                    ],
                  ),
                  onPressed: () async {
                    if (await canLaunch(
                        MapsLauncher.createCoordinatesUrl(lat, long))) {
                      await launch(
                          MapsLauncher.createCoordinatesUrl(lat, long));
                    } else {
                      throw 'Could not launch $MapsLauncher.createCoordinatesUrl(lat, long)';
                    }
                  },
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Expanded(
                child: Container(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          title:
                              Text(attendance[index].toDate().toString() ?? ""),
                        ),
                      );
                    },
                    itemCount: attendance.length,
                  ),
                ),
              ),
              RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                color: Colors.redAccent,
                child: Text(
                  "Remove",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  _firestore
                      .collection('user')
                      .document(widget.workerDocumentID)
                      .delete();
                  Navigator.pushNamed(context, 'director');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
