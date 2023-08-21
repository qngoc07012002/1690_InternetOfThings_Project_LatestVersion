class Student{
  final String? rfid;
  final String? name;
  final String? studentCode;
  final String? email;
  final String? avatar;

  Student({this.rfid, this.name, this.studentCode, this.email, this.avatar});

  factory Student.fromJson(Map<String, dynamic> json){
    return Student(
      rfid: json['RFID'],
      name: json['Name'],
      studentCode: json['Student_Code'],
      email: json['Email'],
      avatar: json['Avatar'], );
  }
}
