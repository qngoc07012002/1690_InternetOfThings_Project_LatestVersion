import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwich_attendance_application/view/StudentList.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../model/Student.dart';
import 'EditProfile.dart';

class AddNewStudent extends StatelessWidget {
  String? rfid;
  AddNewStudent({required this.rfid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(46, 29, 91, 1),
        primarySwatch: Colors.indigo,
      ),
      home: _AddNewStudent(rfid: rfid),
    );
  }
}

class _AddNewStudent extends StatefulWidget {
  String? rfid;
   _AddNewStudent({required this.rfid});

  @override
  State<_AddNewStudent> createState() => _AddNewStudentState();
}

class _AddNewStudentState extends State<_AddNewStudent> {
  String? textStatus = "PUT YOUR FINGER ON THE SCANNER";
  String status = "Checking...";
  late Timer timer;

  void fetchStatus() async {
    final response = await http.get(Uri.parse('http://www.nqngoc.id.vn/get_CheckStatusNewStudent.php')); // Replace with your API URL

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final newStatus = data['status'];

      if (mounted) {
        setState(() {
          status = newStatus;
        });
      }

      if (newStatus == "Waiting") {
        textStatus = "PUT YOUR FINGER ON THE SCANNER";
      } else if (newStatus == "Again"){
        textStatus = "PUT YOUR FINGER AGAIN";
      } else if (newStatus == "Success") {
        timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditProfile(student: Student(rfid: widget.rfid))),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          status = "Error fetching status";
        });
      }
    }
  }


  @override
  void initState() {
    super.initState();
    // Fetch status every 1 second
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchStatus());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String rfid = widget.rfid!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const StudentList();
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            }
        ),
        centerTitle: true,
        title: const Text("Add Student"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
                height: 500,
                width: 200,
                child: Lottie.network('https://lottie.host/fbe79da3-fa1b-4dd9-b260-00403dfeb1bb/jOvSl0qbqq.json'),
            ),
            Text(textStatus!, style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color.fromRGBO(46, 29, 91, 1),
            ),),
          ],
        )

      ),
    );
  }
}
