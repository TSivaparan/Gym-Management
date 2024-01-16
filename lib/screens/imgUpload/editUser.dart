import 'package:flutter/material.dart';

class EditUser extends StatelessWidget {
  final username, id;

  EditUser({super.key, required this.username, required this.id});

  TextEditingController _idTextController = TextEditingController();
  TextEditingController _nameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          SizedBox(height: 20),
          TextFormField(
            initialValue: username,
            controller: _nameTextController,
            decoration: InputDecoration(
              labelText: "Name",
              labelStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            initialValue: id,
            controller: _idTextController,
            decoration: InputDecoration(
              labelText: "id",
              labelStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
