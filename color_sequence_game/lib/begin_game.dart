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

  void checkSequence() {
    if (!sequenceCompleted) {
      setState(() {
        for (int i = 0; i < userSequence.length; i++) {
          if (userSequence[i] != rightOrder[i]) {
            mistakes++;
          }
        }
        sequenceCompleted = true;
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
                onTap: () {
                  if (!sequenceCompleted && finishedShowingSequence) {
                    setState(() {
                      userSequence.add(index);
                      greySquares.add(index);
                      if (userSequence.length == rightOrder.length) {
                        checkSequence();
                      }
                    });
                    // Change the color to grey temporarily
                    Future.delayed(Duration(milliseconds: 200), () {
                      setState(() {
                        greySquares.remove(index);
                      });
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  color: bgColor,
                  margin: EdgeInsets.all(4),
                ),
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
            )
        ],
      ),
    );
  }
}

/*
* !!! CHANGE THE ANIMATION WHEN SHOWING THE CORRECT SEQUENCE
* ITS DISTRACTING TOO MUCH!!!
* */