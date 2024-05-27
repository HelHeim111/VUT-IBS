import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:color_sequence_game/navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<LeaderboardEntry> _leaderboard = [];
  int _selectedIndex = 0;
  String _error = "";

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  // Function to handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation logic based on the tapped item index
    switch (index) {
      case 0:
      // Navigate to the home screen
        Navigator.pushNamed(context, '/');
        break;
      case 1:
      // Navigate to the search screen
        Navigator.pushNamed(context, '/begin_game');
        break;
      case 2:
      // Navigate to the profile screen
        Navigator.pushNamed(context, '/user_stats');
        break;
    }
  }

  // Fetch leaderboard data from Firestore, handle connectivity issues
  Future<void> _fetchLeaderboard() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      setState(() {
        _leaderboard = [];
        _error = "No internet connection available.";
      });
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        List<LeaderboardEntry> leaderboard = [];

        for (QueryDocumentSnapshot userDoc in querySnapshot.docs) {
          DocumentSnapshot progressDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userDoc.id)
              .collection('userProgress')
              .doc('progress')
              .get();

          if (progressDoc.exists) {
            int gamesPlayed = 0;
            String userName = progressDoc.get('name') as String;

            final progressData = progressDoc.data() as Map<String, dynamic>?;
            if (progressData != null &&
                progressData.containsKey('games_played')) {
              gamesPlayed = progressData['games_played'] as int;
            }

            leaderboard.add(LeaderboardEntry(
              userName: userName,
              gamesPlayed: gamesPlayed,
            ));
          }
        }
        // Sort leaderboard entries by games played
        leaderboard.sort((a, b) => b.gamesPlayed.compareTo(a.gamesPlayed));

        setState(() {
          _leaderboard = leaderboard;
          _error = "";
        });
      } else {
        setState(() {
          _leaderboard = [];
          _error = "No user documents found.";
        });
      }
    } catch (e) {
      // Handle errors other than no internet
      setState(() {
        _leaderboard = [];
        _error = "Failed to fetch data: ${e.toString()}";
      });
    }
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.blue[200],
        elevation: 0, // No shadow
        automaticallyImplyLeading: false,
        actions: _auth.currentUser != null
            ? [
          // Dropdown button for user options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.account_circle, color: Colors.black87),
              onSelected: (String value) {
                if (value == 'Sign Out') {
                  _auth.signOut().then((_) {
                    setState(() {}); // Refresh UI after signing out
                  });
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: _auth.currentUser!.email,
                  child: Text(_auth.currentUser!.email!),
                ),
                PopupMenuItem<String>(
                  value: 'Sign Out',
                  child: Text('Sign Out'),
                ),
              ],
            ),
          ),
        ]
            : [
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmailAuthWidget(),
                ),
              );
              setState(() {}); // Refresh the UI after signing in
            },
            child: Text(
              'Sign In',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SignUpWidget(),
                ),
              );
            },
            child: Text(
              'Sign Up',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding for content spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_error, style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
              Text(
                'Top Players (Games Played)',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              // Use Card widget for a calm design
              ..._leaderboard.map((entry) {
                return Card(
                  color: Colors.blueGrey[100], // Card background color
                  elevation: 2, // Add slight elevation for depth
                  child: ListTile(
                    title: Text(
                      entry.userName,
                      style: TextStyle(color: Colors.black87),
                    ),
                    trailing: Text(
                      '${entry.gamesPlayed} games',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class LeaderboardEntry {
  final String userName;
  final int gamesPlayed;

  LeaderboardEntry({
    required this.userName,
    required this.gamesPlayed,
  });
}
