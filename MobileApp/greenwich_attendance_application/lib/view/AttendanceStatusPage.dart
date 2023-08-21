import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceStatusPage extends StatefulWidget {
  final int slotID;

  AttendanceStatusPage({required this.slotID});

  @override
  _AttendanceStatusPageState createState() => _AttendanceStatusPageState();
}

class _AttendanceStatusPageState extends State<AttendanceStatusPage> {
  List<dynamic> studentStatusList = [];
  late Timer timer;

  Future<void> fetchAttendanceStatus() async {
    final response = await http.get(Uri.parse('http://www.nqngoc.id.vn/get_SlotDetail.php?slotID=${widget.slotID}'));

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          studentStatusList = json.decode(response.body);
        });
      }
    } else {
      throw Exception('Failed to load attendance status');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAttendanceStatus();
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      if (mounted) {
        fetchAttendanceStatus();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Status'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: studentStatusList.length,
        itemBuilder: (context, index) {
          var studentStatus = studentStatusList[index];
          var status = studentStatus['Status'];
          var studentName = studentStatus['Name'] ?? 'Unknown Name';
          var studentCode = studentStatus['Student_Code'] ?? 'Unknown Code';
          var studentAvatar = studentStatus['Avatar'] ?? 'default.png';
          var statusColor = Colors.green;

          if (status == 'Not Yet') {
            statusColor = Colors.yellow;
          } else if (status == 'Absent') {
            statusColor = Colors.red;
          }

          return Card(
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              leading: SizedBox(
                width: 60,
                height: 60,
                child: Image.network(
                  'http://nqngoc.id.vn/images/${studentAvatar}',
                  fit: BoxFit.fitWidth,
                ),
              ),
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(studentName),
              ),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: Text(studentCode),
              ),
              trailing: Text(status, style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),),

            ),
          );
        },

      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AttendanceStatusPage(slotID: 12),
  ));
}
