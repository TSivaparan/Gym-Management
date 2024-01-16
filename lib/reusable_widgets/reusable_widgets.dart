import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white,
  );
}

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller, List<TextInputFormatter> formatter,
    {Widget? suffixIcon}) {
  return TextField(
    controller: controller,
    inputFormatters: formatter,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white12.withOpacity(0.1),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
      suffixIcon: suffixIcon,
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

TextField reusableMulitpleLineField(
    String text, IconData icon, TextEditingController controller,
    {Widget? suffixIcon}) {
  return TextField(
    controller: controller,
    cursorColor: Colors.white,
    keyboardType: TextInputType.multiline,
    maxLines: 10,
    minLines: 1,
    style: TextStyle(color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.white70,
      ),
      labelText: text,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white12.withOpacity(0.1),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
      suffixIcon: suffixIcon,
    ),
  );
}

Container signInSignUpButton(
    BuildContext context, String label, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        // isLogin ? 'LOG IN' : 'SIGN UP',
        label,
        style: const TextStyle(
            color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Color(0xff9b1616);
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
    ),
  );
}

class UserDataFetcher {
  static void fetchUserDataAndUpdateState(BuildContext context,
      Function(String? email, String? address) setStateCallback) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    String? uid = user?.uid;

    if (uid != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      userDocRef.get().then((DocumentSnapshot documentSnapshot) {
        Map<String, dynamic>? userData =
            documentSnapshot.data() as Map<String, dynamic>?;

        setStateCallback(userData?['email'], userData?['address']);
      });
    }
  }
}

class CustomTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  CustomTextInputFormatter({required this.mask, required this.separator});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String maskedText = '';
    int maskIndex = 0;
    int separatorIndex = 0;

    for (int i = 0; i < mask.length; i++) {
      if (mask[i] == 'x') {
        if (maskIndex < newValue.text.length) {
          maskedText += newValue.text[maskIndex];
          maskIndex++;
        }
      } else if (separator != null) {
        maskedText += separator[separatorIndex % separator.length];
        separatorIndex++;
      }
    }

    return TextEditingValue(
      text: maskedText,
      selection: TextSelection.collapsed(offset: maskedText.length),
    );
  }
}
