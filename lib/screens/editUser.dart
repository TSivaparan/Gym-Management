import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sample_app/screens/member/profile_screen.dart';

class EditUser extends StatefulWidget {
  final String username;
  final String id;
  final String email;
  final String role;
  final String phone_no;
  final String dob;
  final String medical_issues;
  final String address;

  EditUser({
    required this.username,
    required this.id,
    required this.email,
    required this.role,
    required this.phone_no,
    required this.dob,
    required this.medical_issues,
    required this.address,
  });

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  late TextEditingController _phone_noController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _medical_issuesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.username);
    _idController = TextEditingController(text: widget.id);
    _emailController = TextEditingController(text: widget.email);
    _roleController = TextEditingController(text: widget.role);
    _phone_noController = TextEditingController(text: widget.phone_no);
    _dobController = TextEditingController(text: widget.dob);
    _addressController = TextEditingController(text: widget.address);
    _medical_issuesController =
        TextEditingController(text: widget.medical_issues);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    String newName = _nameController.text;
    String newPhone_no = _phone_noController.text;
    String newAddress = _addressController.text;

    bool confirmUpload = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirmation',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        content: const Text('Do you want to update your details',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Color(0xff9b1616),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text(
              'No',
              style: TextStyle(
                color: Color(0xff9b1616),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );

    // Update the user data in Firestore
    if (confirmUpload == true) {
      FirebaseFirestore.instance.collection('users').doc(widget.id).update({
        'username': newName,
        'phone_no': newPhone_no,
        'address': newAddress,
      }).then((value) {
        Navigator.pop(context, {
          'username': newName,
          'phone_no': newPhone_no,
          'address': newAddress,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User updated successfully')),
        );
      }).catchError((error) {
        // Update failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user')),
        );
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _phone_noController,
                decoration: InputDecoration(
                  labelText: 'Phone No',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                ),
              ),
              SizedBox(height: 16.0),
              if (widget.role == 'user')
                TextField(
                  controller: _medical_issuesController,
                  decoration: InputDecoration(
                    labelText: 'Medical issues',
                  ),
                ),
              SizedBox(height: 16.0),
              TextField(
                controller: _roleController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Role',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'DOB',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff9b1616),
                ),
                onPressed: _updateUser,
                child: Text('Update details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}