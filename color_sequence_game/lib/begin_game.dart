import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BeginGame extends StatefulWidget {
  const BeginGame({Key? key}) : super(key: key);

  @override
  State<BeginGame> createState() => _BeginGameState();
}

class _BeginGameState extends State<BeginGame> {
  List<Color> colors = List.generate(16, (index) => Colors.white);
  List<int> rightOrder = [];
  List<int> userSequence = [];
  List<int> greySquares = [];
  int stmThreshold = 3;
  int pairsLightUp = 0;
  int mistakes = 0;
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


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    rightOrder = List.generate(stmThreshold, (_) => 0);

    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      if (pairsLightUp < stmThreshold) {
        setState(() {

          colors = List.generate(16, (index) => Colors.white);
          int randomSquare1 = Random().nextInt(16);
          int randomSquare2, randomSquare3;

          do {
            randomSquare2 = Random().nextInt(16);
          }while(randomSquare1 == randomSquare2);

          do {
            randomSquare3 = Random().nextInt(16);
          }while(randomSquare1 == randomSquare3 || randomSquare2 == randomSquare3);

          colors[randomSquare1] = Colors.blue;
          colors[randomSquare2] = Colors.red;
          colors[randomSquare3] = Colors.green;
          rightOrder[pairsLightUp] = randomSquare1;
        });
        pairsLightUp += 1;
        startTime = DateTime.now();
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

  void addReactionTime(double time) {
    setState(() {
      reactionTimes.add(time);
      totalReactionTime += time;
    });
  }

  void calculateAverageReactionTime() {
    averageReactionTime = totalReactionTime / stmThreshold;
    print("Average Reaction Time: $averageReactionTime seconds");
  }


  void checkSequence() {
    if (!sequenceCompleted) {
      setState(() {
        for (int i = 0; i < userSequence.length; i++) {
          if (userSequence[i] != rightOrder[i]) {
            mistakes++;
          }
        }
        sequenceCompleted = true;
        calculateAverageReactionTime();
      });
    }
  }

  void resetGame() {
    setState(() {
      pairsLightUp = 0;
      mistakes = 0;
      sequenceCompleted = false;
      firstGame = false;
      userSequence.clear();
      greySquares.clear();
      reactionTime = 0.0;
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Color Sequence Game"),
      ),
      body: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              bool isPressed = greySquares.contains(index);
              Color bgColor = isPressed ? Colors.grey[300]! : colors[index];
              return GestureDetector(
                child: (!sequenceCompleted && finishedShowingSequence) ? AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  color: bgColor,
                  margin: EdgeInsets.all(4),
                ) : Container(
                  color: bgColor,
                  margin: EdgeInsets.all(4),
                ),
                onTap: () {
                  delayTimeStart = DateTime.now();
                  if (!finishedShowingSequence) {
                    DateTime endTime = DateTime.now();
                    reactionTime = endTime
                        .difference(startTime)
                        .inMilliseconds /
                        1000;
                    addReactionTime(reactionTime);
                  }
                  if (!sequenceCompleted && finishedShowingSequence) {
                    setState(() {
                      userSequence.add(index);
                      greySquares.add(index);
                      if (userSequence.length == rightOrder.length) {
                        checkSequence();
                      }

                      // Change the color to grey temporarily
                      Future.delayed(Duration(milliseconds: 200), () {
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


          SizedBox(height: 20),
          if (sequenceCompleted)
            Column(
              children: [
                Text(
                  "Mistakes: $mistakes",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: resetGame,
                  child: Text("Restart"),
                ),
                Text("Your avarage rt: $averageReactionTime")
              ],
            ),
          if (!sequenceCompleted && firstGame)
            Column(
              children: [
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: resetGame,
                  child: Text('Start Game'),
                ),
              ]
            ),
          if (reactionTime > 0.0)
            Column(
              children: [
                SizedBox(height: 10),
                Text("Your rt: $reactionTime")
              ],
            ),
        ],
      ),
    );
  }
}

