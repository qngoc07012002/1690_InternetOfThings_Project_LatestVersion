import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwich_attendance_application/view/AttendanceHistory.dart';
import 'package:greenwich_attendance_application/view/LoginForm.dart';
import 'package:http/http.dart' as http;

import 'package:greenwich_attendance_application/model/Student.dart';

import 'AddStudent.dart';
import 'EditProfile.dart';

// class MyHttpOverrides extends HttpOverrides{
//   @override
//   HttpClient createHttpClient(SecurityContext? context){
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
//   }
// }

void main() {
//  HttpOverrides.global = MyHttpOverrides();
  runApp(const StudentList());
}

class StudentList extends StatelessWidget {
  const StudentList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(46, 29, 91, 1),
        primarySwatch: Colors.indigo,
      ),
      home: const _StudentList(),
    );
  }
}

class _StudentList extends StatefulWidget {
  const _StudentList({Key? key}) : super(key: key);

  @override
  State<_StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<_StudentList> {
  late Future<List<Student>> futureStudents;

  @override
  void initState() {
    super.initState();
    futureStudents = fetchStudents();
  }

  Future<void> _refreshStudents() async {
    setState(() {
      futureStudents = fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Student List"),

      ),
      body: RefreshIndicator(
        onRefresh: _refreshStudents,
        child: Center(
          child: FutureBuilder(
            future: futureStudents,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Retrieve Failed');
              } else if (snapshot.hasData) {
                final students = snapshot.data;
                return ListView.builder(
                  itemCount: students?.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 16),
                        leading: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.network(
                            'http://nqngoc.id.vn/images/${students?[index].avatar ??
                                'default.png'}',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        title: Text(students?[index].name ?? 'Not Found'),
                        subtitle: Text(students?[index].studentCode ?? 'Not Found'),
                        onTap: (){
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return AttendanceHistory(rfid: students![index].rfid);

                              },
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );

                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return const AddStudent();
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        backgroundColor: const Color.fromRGBO(46, 29, 91, 1),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Student> parseStudents(String response){
    final parsed = jsonDecode(response).cast<Map<String, dynamic>>();
    return parsed.map<Student>((json) => Student.fromJson(json)).toList();
  }

  Future<List<Student>> fetchStudents() async {
    const url = "http://www.nqngoc.id.vn/get_StudentInfomation.php";
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return parseStudents(response.body);
    } else {
      throw Exception('Failed to load Todo');
    }
  }
}

