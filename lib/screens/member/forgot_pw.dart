import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../reusable_widgets/reusable_widgets.dart';
import '../../utils/colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String? _emailError;
  TextEditingController _emailTextController = TextEditingController();
  List<TextInputFormatter> emailInputFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
  ];

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailTextController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Password reset link sent! check your email'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: Colors.black),
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).size.height * 0.2, 20, 0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      reusableTextField("Enter Email", Icons.person_outline,
                          false, _emailTextController, emailInputFormatter),
                      MaterialButton(
                        onPressed: passwordReset,
                        child: Text(
                          'Rest Password',
                          style: TextStyle(color: Colors.white70),
                        ),
                        color: Color(0xff9b1616),
                      )
                    ],
                  )))),
    );
  }
}
