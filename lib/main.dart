import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '猜數字遊戲',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GuessNumberGame(),
    );
  }
}

class GuessNumberGame extends StatefulWidget {
  @override
  _GuessNumberGameState createState() => _GuessNumberGameState();
}

class _GuessNumberGameState extends State<GuessNumberGame> {
  final Random _random = Random();
  late int _targetNumber;
  late int _userGuess;
  String _resultMessage = '';

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _targetNumber = _random.nextInt(100) + 1;
      _userGuess = 0;
      _resultMessage = '猜一個介於1和100之間的數字';
    });
  }

  void _handleGuess() {
    setState(() {
      if (_userGuess == null) {
        _resultMessage = '請輸入一個數字';
      } else if (_userGuess == _targetNumber) {
        _resultMessage = '恭喜你猜對了！';
      } else if (_userGuess < _targetNumber) {
        _resultMessage = '太小了，再試一次';
      } else {
        _resultMessage = '太大了，再試一次';
      }

      // 清除輸入的數字
      _userGuess = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('猜數字遊戲'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _resultMessage,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _userGuess = (value.isNotEmpty ? int.tryParse(value) : null)!;
                  });
                },
                decoration: InputDecoration(
                  labelText: '輸入你的猜測',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleGuess,
                child: Text('猜!'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _resetGame,
                child: Text('重新開始'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
