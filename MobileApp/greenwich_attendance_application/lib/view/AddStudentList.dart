import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenwich_attendance_application/view/StudentList.dart';
import 'package:http/http.dart' as http;
import '../model/Student.dart';
import 'EditProfile.dart';

class AddStudent extends StatelessWidget {
  const AddStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(46, 29, 91, 1),
        primarySwatch: Colors.indigo,
      ),
      home: _AddStudent(),
    );
  }
}

class _AddStudent extends StatefulWidget {
  const _AddStudent({super.key});

  @override
  State<_AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<_AddStudent> {
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
                        title: Text(students?[index].rfid ?? 'Not Found'),
                        subtitle: Text(students?[index].studentCode ?? 'Not Found'),
                        onTap: (){
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return EditProfile(student: Student(
                                  rfid: students?[index].rfid,
                                ),);
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
    );
  }

  List<Student> parseStudents(String response){
    final parsed = jsonDecode(response).cast<Map<String, dynamic>>();
    return parsed.map<Student>((json) => Student.fromJson(json)).toList();
  }

  Future<List<Student>> fetchStudents() async {
    const url = "http://www.nqngoc.id.vn/get_NewStudent.php";
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return parseStudents(response.body);
    } else {
      throw Exception('Failed to load Todo');
    }
  }
}
