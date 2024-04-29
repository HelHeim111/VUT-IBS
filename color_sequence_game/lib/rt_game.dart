
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RtGame extends StatefulWidget {
  const RtGame({Key? key}) : super(key: key);

  @override
  State<RtGame> createState() => _RtGameState();
}

class _RtGameState extends State<RtGame> {
  Color _currentColor = Colors.red;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _gameStarted = false;

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _currentColor = Colors.red;
    });
    Future.delayed(Duration(seconds: Random().nextInt(5) + 1), () {
      setState(() {
        _currentColor = Colors.green;
        _startTime = DateTime.now();
      });
    });
  }

  void _endGame() {
    setState(() {
      _gameStarted = false;
      _endTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reaction Time Game"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (_gameStarted && _currentColor == Colors.green) {
                  _endGame();
                }
              },
              child: Container(
                width: 200,
                height: 200,
                color: _currentColor,
                child: Center(
                  child: Text(
                    _gameStarted ? "Tap!" : "Start",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_endTime != null && _startTime != null)
              Text(
                "Reaction Time: ${_endTime!.difference(_startTime!).inMilliseconds} milliseconds",
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startGame,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}