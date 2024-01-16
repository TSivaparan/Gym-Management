import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateChallenges extends StatefulWidget {
  const CreateChallenges({Key? key}) : super(key: key);

  @override
  State<CreateChallenges> createState() => _CreateChallengesState();
}

class _CreateChallengesState extends State<CreateChallenges> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _startingController = TextEditingController();
  TextEditingController _endingController = TextEditingController();
  TextEditingController _challengeDurationController = TextEditingController();

  String? _duration;
  String? _category;
  String? _day;

  List<String> _challengeDuration = ['30', '45', '60'];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Get text values from controllers
      String challengeName = _nameController.text;
      String duration = _duration!;
      String startingDate = _startingController.text;
      String endingDate = _endingController.text;

      FirebaseFirestore.instance.collection('challenges').add({
        'challengeName': challengeName,
        'duration': duration,
        'starting': startingDate,
        'ending': endingDate,
      }).then((_) {
        // Clear input fields
        _nameController.clear();
        _duration = null;
        _startingController.clear();
        _endingController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challenge added successfully.'),
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Challenge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Challenge Name',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white70),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a challenge name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _duration,
                items: _challengeDuration.map((time) {
                  return DropdownMenuItem<String>(
                    value: time,
                    child: Text('$time Days'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _duration = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Duration (Days)',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white70),
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a duration in days';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _startingController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Challenge Starting Date',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white70),
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2050),
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      _startingController.text = formattedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _endingController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Challenge End Date',
                  labelStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.white70),
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2050),
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      _endingController.text = formattedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff9b1616),
                ),
                onPressed: _submitForm,
                child: Text('Create Challenge'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
