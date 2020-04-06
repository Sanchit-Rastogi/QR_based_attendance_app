import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSaving = false;

  Future<void> loginUser() async {
    setState(() {
      _isSaving = true;
    });
    String userType;
    AuthResult result = await _auth.signInWithEmailAndPassword(
      email: _emailController.value.text,
      password: _passwordController.value.text,
    );
    final users = await _firestore.collection('user').getDocuments();
    for (var user in users.documents) {
      if (user.data['email'] == _emailController.value.text) {
        userType = user.data['type'];
      }
    }
    setState(() {
      _isSaving = false;
    });
    Navigator.pushNamed(context, '$userType');
  }

  Future<void> currentUser() async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      String userID = user.email;
      String userType;
      final users = await _firestore.collection('user').getDocuments();
      for (var user in users.documents) {
        if (user.data['email'] == userID) {
          userType = user.data['type'];
        }
      }
      print(userType);
      setState(() {
        _isSaving = false;
      });
      Navigator.pushNamed(context, '$userType');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EVT'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isSaving,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: 'Email'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(hintText: 'Password'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 40,
                    ),
                    color: Colors.lightBlueAccent,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        FocusScope.of(context).unfocus();
                        loginUser();
                      }
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                FlatButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, 'register');
                  },
                  icon: Icon(Icons.person_add),
                  label: Text("Create an account"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
