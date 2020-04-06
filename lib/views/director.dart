import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Director extends StatefulWidget {
  @override
  _DirectorState createState() => _DirectorState();
}

class _DirectorState extends State<Director> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Director"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text("logout"),
        onPressed: () async {
          await _auth.signOut();
          Navigator.pushNamed(context, 'login');
        },
      ),
    );
  }
}
