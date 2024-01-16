import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNutritionItemForm extends StatefulWidget {
  @override
  _AddNutritionItemFormState createState() => _AddNutritionItemFormState();
}

class _AddNutritionItemFormState extends State<AddNutritionItemForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _foodController = TextEditingController();
  TextEditingController _caloriesController = TextEditingController();

  String? _foodTime;
  String? _category;
  String? _day;

  List<String> _foodTimeList = ['Breakfast', 'Lunch', 'Dinner'];
  List<String> _categoryList = [
    'Normal',
    'Obesity',
    'Overweight',
    'Underweight'
  ];
  List<String> _dayList = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String food = _foodController.text.trim();
      int calories = int.parse(_caloriesController.text.trim());

      // Save data to Firestore
      FirebaseFirestore.instance.collection('nutrition_chart').add({
        'foodTime': _foodTime,
        'food': food,
        'category': _category,
        'day': _day,
        'calories': calories,
      });

      // Clear input fields
      _foodController.clear();
      _caloriesController.clear();
      _foodTime = null;
      _category = null;
      _day = null;

      // Show a success message or navigate to a different screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nutrition item added successfully.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _foodController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _foodTime,
                    decoration: InputDecoration(
                        labelText: 'Food Time',
                      labelStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 25,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.white70),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _foodTime = value;
                      });
                    },
                    items: _foodTimeList.map((time) {
                      return DropdownMenuItem<String>(
                        value: time,
                        child: Text(time),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a food time';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _foodController,
                    decoration: InputDecoration(labelText: 'Food',
                      labelStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.white70),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a food';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _day,
                    decoration: InputDecoration(labelText: 'Day',
                      labelStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.white70),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _day = value;
                      });
                    },
                    items: _dayList.map((day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a day';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: InputDecoration(labelText: 'Category',
                      labelStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.white70),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _category = value;
                      });
                    },
                    items: _categoryList.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _caloriesController,
                    decoration: InputDecoration(labelText: 'Calories',
                      labelStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 2, color: Colors.white70),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter calories';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff9b1616),
                    ),
                    onPressed: _submitForm,
                    child: Text('Add Nutrition Item'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
