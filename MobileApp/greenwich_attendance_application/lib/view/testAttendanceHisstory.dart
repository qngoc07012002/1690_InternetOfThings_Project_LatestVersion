import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceHistoryScreen extends StatefulWidget {
  final String rfid;

  AttendanceHistoryScreen({required this.rfid});

  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late Map<String, dynamic> studentData;
  late List<dynamic> attendanceHistory;

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance History'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            title: Text('Name: ${studentData['Name']}'),
            subtitle: Text('RFID: ${studentData['RFID']}'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: attendanceHistory.length,
              itemBuilder: (context, index) {
                final history = attendanceHistory[index];
                return ListTile(
                  title: Text('Date: ${history['Date']}'),
                  subtitle: Text('Slot: ${history['SlotName']}, Status: ${history['Status']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AttendanceHistoryScreen(rfid: '337C95FC'),
  ));
}