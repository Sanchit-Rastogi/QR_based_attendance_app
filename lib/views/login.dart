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
  final _textKey = GlobalKey<FormFieldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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

  Future<void> resetPassword() async {
    await _auth.sendPasswordResetEmail(email: _emailController.value.text);
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Password reset email sent.'),
      duration: Duration(seconds: 2),
    ));
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
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('EVT'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isSaving,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      key: _textKey,
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
                          if (_textKey.currentState.validate()) {
                            FocusScope.of(context).unfocus();
                            resetPassword();
                          }
                        },
                        icon: Icon(Icons.query_builder),
                        label: Text(
                          "Forgot Password ?",
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        )),
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
            Expanded(
              child: Image(
                image: AssetImage("assets/bg.jpeg"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
