import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:color_sequence_game/navigation_bar.dart';

class BeginGame extends StatefulWidget {
  const BeginGame({Key? key}) : super(key: key);

  @override
  State<BeginGame> createState() => _BeginGameState();
}

class _BeginGameState extends State<BeginGame> {
  // Initializes variables for game logic
  List<Color> colors = List.generate(16, (index) => Colors.white);
  List<int> rightOrder = [];
  List<int> redOrder = [];
  List<int> greenOrder = [];
  List<int> userSequence = [];
  List<int> greySquares = [];
  int stmThreshold = 5;
  int pairsLightUp = 0;
  int mistakes = 0;
  int at_mistakes = 0;
  bool sequenceCompleted = false;
  bool firstGame = true;
  bool finishedShowingSequence = false;
  late Timer timer;
  late DateTime startTime;
  late DateTime delayTimeStart = DateTime.now();
  double delayTime = 0.0;
  List<double> reactionTimes = [];
  double totalReactionTime = 0.0;
  double reactionTime = 0.0;
  double averageReactionTime = 0.0;
  int _selectedIndex = 1;
  int games_played = 0;

  bool showGuide = false;
  bool showResults = false;
  dynamic user_name = "";
  int user_age = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
  // Handles bottom navigation bar taps
  void _onItemTapped(int index) {
    // Set the state to update the selectedIndex
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on the selected index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/');
        break;
      case 1:
        Navigator.pushNamed(context, '/begin_game');
        break;
      case 2:
        Navigator.pushNamed(context, '/user_stats');
        break;
    }
  }
  // Fetches user statistics data from Firestore
  Future<void> fetchStatisticData() async {
    // Get the currently authenticated user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot<dynamic> documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('userProgress')
          .doc('progress')
          .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('new_sequence_length')) {
          stmThreshold = data['new_sequence_length'];
        }
        if (data.containsKey('games_played')) {
          games_played = data['games_played'];
        }
        if (data.containsKey('name')) {
          user_name = data['name'];
        }
        if (data.containsKey('age')) {
          user_age = data['age'];
        }
      }
    }
  }
  // Starts the timer for the sequence display
  void startTimer() async {
    await fetchStatisticData();
    rightOrder = List.generate(stmThreshold, (_) => 0);
    redOrder = List.generate(stmThreshold, (_) => 0);
    greenOrder = List.generate(stmThreshold, (_) => 0);

    int randomInterval = Random().nextInt(1000) + 1500;

    timer = Timer.periodic(Duration(milliseconds: randomInterval), (Timer t) {
      if (pairsLightUp < stmThreshold) {
        setState(() {
          // Generates a new sequence of colors
          colors = List.generate(16, (index) => Colors.white);
          int randomSquare1 = Random().nextInt(16);
          int randomSquare2, randomSquare3;

          do {
            randomSquare2 = Random().nextInt(16);
          } while (randomSquare1 == randomSquare2);

          do {
            randomSquare3 = Random().nextInt(16);
          } while (randomSquare1 == randomSquare3 || randomSquare2 == randomSquare3);

          colors[randomSquare1] = Colors.blue;
          colors[randomSquare2] = Colors.red;
          colors[randomSquare3] = Colors.green;
          rightOrder[pairsLightUp] = randomSquare1;
          redOrder[pairsLightUp] = randomSquare2;
          greenOrder[pairsLightUp] = randomSquare3;
          startTime = DateTime.now();
        });
        pairsLightUp += 1;
      } else {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            colors = List.generate(16, (index) => Colors.white);
            finishedShowingSequence = true;
          });
        });
        t.cancel();
      }
    });
  }
  // Records a reaction time
  void addReactionTime(double time) {
    setState(() {
      reactionTimes.add(time);
      totalReactionTime += time;
    });
  }
  // Calculates the average reaction time based on the three quickest samples
  void calculateAverageReactionTime() {
    if (reactionTimes.length > 3) {
      List<double> sortedTimes = List.from(reactionTimes);
      sortedTimes.sort();
      double sumFastestThree = sortedTimes.take(3).reduce((a, b) => a + b);
      averageReactionTime = sumFastestThree / 3;
    } else {
      if(reactionTimes.length == 0) {
        averageReactionTime = 0.0;
        return;
      }
      averageReactionTime = reactionTimes.reduce((a, b) => a + b) / reactionTimes.length;
    }
  }
  // Saves user data to Firestore
  void saveUserData(double averageReactionTime, int mistakes) async {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Get the currently authenticated user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid; // User's unique identifier

      Map<String, dynamic> gameData = {
        'average_reaction_time': averageReactionTime,
        'mistakes': mistakes,
        'at_mistakes': at_mistakes,
        'timestamp': now,
        'sequence_length': stmThreshold,
      };
      int new_sequence_length;
      if (mistakes >= stmThreshold / 2 && stmThreshold > 4) {
        new_sequence_length = stmThreshold - 1;
      } else if (mistakes == 0 && stmThreshold < 9) {
        new_sequence_length = stmThreshold + 1;
      } else {
        new_sequence_length = stmThreshold;
      }
      Map<String, dynamic> userProgressData = {
        'new_sequence_length': new_sequence_length,
        'games_played': games_played + 1,
        'name': user_name,
        'age': user_age,
      };

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('games')
            .doc(now.toString()) // Use timestamp as document ID
            .set(gameData);
        print('Game data saved successfully!');
      } catch (e) {
        print('Error saving game data: $e');
      }
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('userProgress')
            .doc('progress')
            .set(userProgressData);
      } catch (e) {
        print('Error saving game data: $e');
      }
    } else {
      print('User is not logged in.');
    }
  }
  // Checks if the user sequence matches the generated sequence
  void checkSequence() {
    if (!sequenceCompleted) {
      setState(() {
        for (int i = 0; i < userSequence.length; i++) {
          if (userSequence[i] == redOrder[i] || userSequence[i] == greenOrder[i]) {
            at_mistakes++;
          }
          if (userSequence[i] != rightOrder[i]) {
            mistakes++;
          }
        }
        sequenceCompleted = true;
        calculateAverageReactionTime();
        saveUserData(averageReactionTime, mistakes);
        showResults = true;
      });
    }
  }
  // Resets the game state to start a new round
  void resetGame() {
    setState(() {
      showResults = false;
      pairsLightUp = 0;
      mistakes = 0;
      at_mistakes = 0;
      sequenceCompleted = false;
      finishedShowingSequence = false;
      firstGame = false;
      userSequence.clear();
      greySquares.clear();
      reactionTime = 0.0;
      averageReactionTime = 0.0;
      totalReactionTime = 0.0;
      reactionTimes.clear();
      rightOrder.clear();
      redOrder.clear();
      greenOrder.clear();
    });
    startTimer();
  }
  // Toggles the visibility of the game guide
  void toggleGuide() {
    setState(() {
      showGuide = !showGuide;
      if (!firstGame && sequenceCompleted) {
        showResults = !showResults;
      }

    });
  }
  // Builds the guide widget for game instructions
  Widget buildGuideWidget() {
    if (showGuide) {
      return Container(
        padding: EdgeInsets.all(16),
        color: Colors.grey[200],
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16, color: Colors.black),
            children: <TextSpan>[
              TextSpan(text: "How to Play:\n\n"),
              TextSpan(text: "1. Memorize the Sequence:", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: " Watch carefully as a series of "),
              TextSpan(text: "blue", style: TextStyle(color: Colors.blue)),
              TextSpan(text: " squares light up on the screen. These squares indicate the sequence you need to remember. Pay close attention to the order in which they appear.\n"),
              TextSpan(text: "2. Quick Response:", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: " Once a new set of three squares lights up, quickly tap"),
              TextSpan(text: " anywhere on the playing field.", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: " This step tests your reflexes and the speed of your response.\n"),
              TextSpan(text: "3. Recreate the Sequence:", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: " After the entire sequence of "),
              TextSpan(text: "blue", style: TextStyle(color: Colors.blue)),
              TextSpan(text: " squares has been shown, begin tapping the squares in the exact order they were illuminated. This part of the game assesses your memory and ability to recall the sequence correctly.\n"),
              TextSpan(text: "4. Minimize Errors:", style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: " Attempt to replicate the sequence as accurately as possible.\n"),
              TextSpan(text: "5. Have fun!", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    } else {
      return Container(); // Return an empty container if the guide is not to be shown
    }
  }

  // Main widget build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Color Sequence Game",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.blue[200], // Lighter background color
        elevation: 0, // No shadow
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.grey[200], // Light grey background color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    bool isPressed = greySquares.contains(index);
                    Color bgColor = isPressed ? Colors.grey[300]! : colors[index];
                    return GestureDetector(
                      child: (!sequenceCompleted && finishedShowingSequence)
                          ? AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        color: bgColor,
                        margin: EdgeInsets.all(4),
                      )
                          : Container(
                        color: bgColor,
                        margin: EdgeInsets.all(4),
                      ),
                      onTap: () {
                        delayTimeStart = DateTime.now();
                        if (!finishedShowingSequence) {
                          DateTime endTime = DateTime.now();
                          reactionTime = endTime.difference(startTime).inMilliseconds / 1000;
                          addReactionTime(reactionTime);
                        }
                        if (!sequenceCompleted && finishedShowingSequence) {
                          setState(() {
                            userSequence.add(index);
                            greySquares.add(index);
                            if (userSequence.length == rightOrder.length) {
                              checkSequence();
                            }

                            Future.delayed(Duration(milliseconds: 500), () {
                              setState(() {
                                greySquares.remove(index);
                              });
                            });
                          });
                        }
                      },
                    );
                  },
                ),
              ),
              buildGuideWidget(),
              if (showResults) // Conditional rendering based on the new `showResults` state
                Column(
                  children: [
                    Text("Mistakes: $mistakes", style: TextStyle(fontSize: 20)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: resetGame,
                      child: Text("Restart", style: TextStyle(fontSize: 18)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Your average reaction time: ${averageReactionTime.toStringAsFixed(1)}ms",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              if (!sequenceCompleted && firstGame)
                Column(
                  children: [
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          firstGame = false;
                        });
                        startTimer();
                      },
                      child: Text('Start Game', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleGuide, // Call toggleGuide function when the button is pressed
        child: Icon(Icons.help),
      ),
    );
  }
}
