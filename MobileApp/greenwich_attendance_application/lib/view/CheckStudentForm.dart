import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenwich_attendance_application/view/AttendanceHistory.dart';
import 'package:greenwich_attendance_application/view/LoginForm.dart';
import 'package:http/http.dart' as http;
import 'CheckStudent.dart';
import 'MainScreen.dart';
import 'StudentList.dart';


class CheckStudentForm extends StatelessWidget {
  const CheckStudentForm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(46, 29, 91, 1),
        primarySwatch: Colors.indigo,
      ),
      home: _CheckStudentForm(),
    );
  }
}

class _CheckStudentForm extends StatefulWidget {
  const _CheckStudentForm({super.key});

  @override
  State<_CheckStudentForm> createState() => _CheckStudentFormState();
}

class _CheckStudentFormState extends State<_CheckStudentForm> {
  final _loginForm = GlobalKey<FormState>();
  final _studentCode = TextEditingController();
  Map<String, dynamic>? studentData;
  List<dynamic> attendanceHistory = [];
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      Container(
                        width: size.width * 0.55,
                        height: size.height * 0.35,
                        child: Image.asset('images/img.png'),
                      ),
                      const Text('GREENWICH ATTENDANCE', style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color.fromRGBO(46, 29, 91, 1),
                      ),),
                    ],
                  )

                ],
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              Form(
                key: _loginForm,
                child: Column(
                  children: [
                    SizedBox(
                      width: size.width * 0.8,
                      child: TextFormField(
                        decoration:  const InputDecoration(
                          labelText: 'Student Code',
                          prefixIcon: Icon(Icons.email, color: Color.fromRGBO(46, 29, 91, 1),),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value){
                          if (value == null || value.isEmpty){
                            return "Please enter Student Code";
                          }
                          return null;
                        },
                        controller: _studentCode,
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),
                    SizedBox(
                      width: size.width * 0.8,
                      height: size.height * 0.06,
                      child:ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(46, 29, 91, 1)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(size.width * 0.02),
                              side: BorderSide(
                                width: size.width * 0.8,
                                color: const Color.fromRGBO(46, 29, 91, 1),
                              ),
                            ),
                          ),
                        ),
                        onPressed:() async {
                          if (_loginForm.currentState!.validate()){
                            fetchStudentInfo();
                          }
                        },
                        child: const Text(
                          "CHECK",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginForm(),
            ),
          );
        },
        backgroundColor: const Color.fromRGBO(46, 29, 91, 1),
        child: const Icon(Icons.home),
      ),
    );
  }

  Future<void> fetchStudentInfo() async {
    final url = 'http://www.nqngoc.id.vn/get_AttendanceHistory_Student.php';

    final response = await http.post(
      Uri.parse(url),
      body: {'studentCode': _studentCode.text},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'])),
        );
      } else {
          studentData = data['Student'];
          attendanceHistory = data['AttendanceHistory'];
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return CheckAttendanceHistory(studentData: studentData, attendanceHistory: attendanceHistory,);
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data')),
      );
    }
  }
}



