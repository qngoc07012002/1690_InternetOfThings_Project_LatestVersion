
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenwich_attendance_application/view/AddStudent.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/Student.dart';
import 'StudentList.dart';
import 'package:path/path.dart' as path;
class EditProfile extends StatelessWidget {
  Student student;

  EditProfile({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(46, 29, 91, 1),
        primarySwatch: Colors.indigo,
      ),
      home: _EditProfile(student: student),
    );
  }
}

class _EditProfile extends StatefulWidget {
  Student student;
  _EditProfile({super.key, required this.student});

  @override
  // ignore: no_logic_in_create_state
  State<_EditProfile> createState() => _EditProfileState(student: student);
}

class _EditProfileState extends State<_EditProfile> {
  Student student;

  _EditProfileState({required this.student});

  File? _image;
  String? _imageFile;
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
       _imageFile = path.basename(pickedImage.path);
      print('Image Name: $_imageFile');
      setState(() {
        _image = File(pickedImage.path);
      });
    }


  }
  String pathImage = "http://nqngoc.id.vn/images/default.png";

  final _editProfileForm = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _studentCode = TextEditingController();
  final _email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (student.name != null) _name.text = student.name!;
    if (student.studentCode != null) _studentCode.text = student.studentCode!;
    if (student.email != null) _email.text = student.email!;
    if (student.avatar != null) {
      pathImage = "http://nqngoc.id.vn/images/${student.avatar}";
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Edit Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
          color: Colors.white,
          ),
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
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 15,top: 20,right: 15),
        child: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              const SizedBox(height: 30),
              Center(
                child: Stack(
                  children: [
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
                        image: _image != null
                            ? DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(_image!), // Use FileImage for local file
                        )
                            :  DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(pathImage),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: Colors.white,
                            ),
                            color: Colors.blue,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white,),
                            onPressed: _pickImage,
                          ),
                        )),

                  ],
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _editProfileForm,
                child: Column(
                  children: [
                    Text('${student.rfid}', style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15,
                    ),),
                    const SizedBox(height: 10,),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Name',
                        prefixIcon: Icon(Icons.drive_file_rename_outline),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
                      validator: (value){
                        if (value == null || value.isEmpty){
                          return 'Please enter Name';
                        } else if (value == 'New Student') {
                          return 'Please enter Name';
                        }
                        return null;
                      },
                      controller: _name,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Student Code',
                        prefixIcon: Icon(Icons.code),
                      ),
                      validator: (value){
                        if (value == null || value.isEmpty){
                          return 'Please enter Student Code';
                        }
                        return null;
                      },
                      controller: _studentCode,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty){
                          return 'Please enter email';
                        }
                        return null;
                      },
                      controller: _email,
                    ),
                    const SizedBox(height: 20,),
                    ElevatedButton(
                      onPressed: () {
                        if (_image == null && student.avatar == null){
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please Choose Image!')));
                        } else {
                          if (_editProfileForm.currentState!.validate()){
                            if (_image != null){
                              _uploadImage();
                            }
                            Student editStudent = Student(
                              rfid: student.rfid,
                              name: _name.text,
                              studentCode: _studentCode.text,
                              email: _email.text,
                              avatar: _image == null ? student.avatar : _imageFile,
                            );
                            _updateProfile(editStudent);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Save Successful!')));
                          }
                        }
                        // if (_image != null) {
                        //   _uploadImage();
                        // } else {
                        //   print('No image selected');
                        // }
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),

              ),

            ],
          ),
        ),
      ),
    );
  }


  Future<void> _uploadImage() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://www.nqngoc.id.vn/post_Image.php'), // Điều chỉnh URL tại đây
    );
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Image upload failed');
    }
  }

  Future<void> _updateProfile(Student editStudent) async {
    const url = 'http://www.nqngoc.id.vn/post_EditProfile.php';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'rfid': editStudent.rfid,
        'name': editStudent.name,
        'student_code': editStudent.studentCode,
        'email': editStudent.email,
        'avatar': editStudent.avatar,
      },
    );

    if (response.statusCode == 200) {
      print('Update Profile Successful');
    } else {
      print('Error: ${response.body}');
    }
  }
}

