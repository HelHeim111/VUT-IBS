import 'package:color_sequence_game/begin_game.dart';
import 'package:color_sequence_game/rt_game.dart';
import 'package:color_sequence_game/user_statistics_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'sign_in.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'sign_up.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: 'Home Page'),
        '/email_auth': (context) => EmailAuthWidget(),
        '/sign_up': (context) => SignUpWidget(),
        '/begin_game': (context) => BeginGame(),
        '/rt_game': (context) => RtGame(),
        '/user_stats': (context) => UserStatisticsPage(),
      },

    );
  }
}
