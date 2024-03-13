import 'package:color_sequence_game/begin_game.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'email_auth_widget.dart'; // Import your email authentication widget
import 'firebase_options.dart';
import 'my_home_page.dart';
import 'sign_up_widget.dart'; // Import your sign-up widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Sequence Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set the initial route to MyHomePage
      initialRoute: '/',
      routes: {
        // Define the routes for navigation
        '/': (context) => MyHomePage(title: 'Home Page'),
        '/email_auth': (context) => EmailAuthWidget(),
        '/sign_up': (context) => SignUpWidget(),
        '/begin_game': (context) => BeginGame(),
      },
    );
  }
}
