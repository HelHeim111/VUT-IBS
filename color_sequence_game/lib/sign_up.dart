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
      body: Padding(
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
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                String name = _nameController.text.trim();
                int age = int.parse(_ageController.text.trim());

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
                    print('Sign-in failed: $error');
                  });
                }).catchError((error) {
                  print('Sign-up failed: $error');
                });
              },
              child: Text('Sign Up'),
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
    Map<String, dynamic> dummy_doc_holder = {
      'dummy' : "dummy",
    };

    firestore
        .collection('users')
        .doc(user.uid)
        .set(dummy_doc_holder)
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
