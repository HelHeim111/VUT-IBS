import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key}) : super(key: key);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.blue[200], // Lighter background color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(), // Add border for text field
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(), // Add border for text field
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(), // Add border for text field
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(), // Add border for text field
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = '';
                });

                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                String name = _nameController.text.trim();
                String ageText = _ageController.text.trim();

                if (email.isEmpty || password.isEmpty || name.isEmpty || ageText.isEmpty) {
                  setState(() {
                    _errorMessage = 'Please fill in all fields.';
                  });
                  return;
                }

                int age;
                try {
                  age = int.parse(ageText);
                } catch (e) {
                  setState(() {
                    _errorMessage = 'Age must be a valid number.';
                  });
                  return;
                }

                FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                )
                    .then((userCredential) {
                  print('Sign-up successful: ${userCredential.user!.uid}');
                  saveUserData(userCredential.user!, name, age);
                  // Automatic Sign In
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  ).then((userCredential) {
                    // Navigate to the main page
                    Navigator.pushNamed(context, '/');
                  }).catchError((error) {
                    setState(() {
                      _errorMessage = 'Sign-in failed: ${error.message}';
                    });
                  });
                }).catchError((error) {
                  setState(() {
                    _errorMessage = 'Sign-up failed: ${error.message}';
                  });
                });
              },
              child: Text('Sign Up'),
            ),
            SizedBox(height: 16.0),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  void saveUserData(User user, String name, int age) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Map<String, dynamic> userData = {
      'email': user.email,
      'name': name,
      'age': age,
      'games_played': 0,
    };
    Map<String, dynamic> dummyDocHolder = {
      'dummy': "dummy",
    };

    firestore
        .collection('users')
        .doc(user.uid)
        .set(dummyDocHolder)
        .then((value) {
      print('Dummy placeholder added');
    }).catchError((error) {
      print('Failed to add dummy placeholder: $error');
    });

    firestore
        .collection('users')
        .doc(user.uid)
        .collection('userProgress')
        .doc('progress')
        .set(userData)
        .then((value) {
      print('User data saved to Firestore');
    }).catchError((error) {
      print('Failed to save user data: $error');
    });
  }
}
