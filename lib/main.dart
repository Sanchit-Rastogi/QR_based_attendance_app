import 'package:flutter/material.dart';
import 'package:attendanceapp/views/register.dart';
import 'package:attendanceapp/views/worker.dart';
import 'package:attendanceapp/views/login.dart';
import 'package:attendanceapp/views/staff.dart';
import 'package:attendanceapp/views/supervisor.dart';
import 'package:attendanceapp/views/director.dart';
import 'package:attendanceapp/views/workerDetails.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
      debugShowCheckedModeBanner: false,
      routes: {
        'register': (context) => Register(),
        'login': (context) => Login(),
        'worker': (context) => Worker(),
        'staff': (context) => Staff(),
        'supervisor': (context) => Supervisor(),
        'director': (context) => Director(),
        'workerDetails': (context) => WorkerDetails(),
      },
    );
  }
}
