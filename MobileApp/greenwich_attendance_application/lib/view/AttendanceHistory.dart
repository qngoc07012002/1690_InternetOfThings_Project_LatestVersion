import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/Student.dart';
import 'EditProfile.dart';
class AttendanceHistory extends StatefulWidget {
  final String? rfid;

  AttendanceHistory({required this.rfid});


  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  Map<String, dynamic>? studentData;
  List<dynamic> attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://www.nqngoc.id.vn/get_AttendanceHistory.php?rfid=${widget.rfid}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        studentData = data['Student'];
        attendanceHistory = data['AttendanceHistory'];
      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.indigo,
            height: 0.30 * height,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 30, top: 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(width: 4, color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage('http://nqngoc.id.vn/images/${studentData?['Avatar'] ?? 'default.png'}'),
                          ),
                        ),
                      ),
                      SizedBox(width: 0.05 * width,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("${studentData?['Name'] ?? 'Loading...'}", style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),),
                          SizedBox(height: 0.018 * height,),
                          Text("${studentData?['Student_Code'] ?? 'Loading...'}", style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),),
                          SizedBox(height: 0.018 * height,),
                          Text("${studentData?['Email'] ?? 'Loading...'}", style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),),
                          SizedBox(height: 0.018 * height,),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    child: const Text("EDIT PROFILE", style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),),
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) {
                                            return EditProfile(student: Student(
                                              rfid: widget.rfid,
                                              name: studentData?['Name'],
                                              studentCode: studentData?['Student_Code'],
                                              email: studentData?['Email'],
                                              avatar: studentData?['Avatar'],
                                            ),
                                            );
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
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.20 * height),
            child: Container(
              width: width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(18.0),
                    topLeft: Radius.circular(18.0),
                  )
              ),
              child: ListView.builder(
                itemCount: attendanceHistory.length,
                itemBuilder: (context, index) {
                  final history = attendanceHistory[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Slot ${history['SlotName']}',style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),),
                      ),
                      subtitle: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('${history['Date']}'),
                      ),
                      trailing: Text(
                        '${history['Status']}',
                        style: TextStyle(
                          color: _getStatusColor(history['Status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Not Yet':
        return Colors.yellow;
      case 'Absent':
        return Colors.red;
      case 'Attended':
        return Colors.green;
      default:
        return Colors.black; // Màu mặc định hoặc xử lý thêm các trạng thái khác
    }
  }
}

