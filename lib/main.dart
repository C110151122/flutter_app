import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class GameResult {
  final int targetNumber;
  final int userGuess;
  final int attempts;
  final String resultMessage;
  final int timeElapsed;
  final String difficulty;

  GameResult({
    required this.targetNumber,
    required this.userGuess,
    required this.attempts,
    required this.resultMessage,
    required this.timeElapsed,
    required this.difficulty,
  });
}

class User {
  final String username;
  final String password;

  User({required this.username, required this.password});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '猜數字遊戲',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _loginUsernameController = TextEditingController();
  TextEditingController _loginPasswordController = TextEditingController();
  TextEditingController _registerUsernameController = TextEditingController();
  TextEditingController _registerPasswordController = TextEditingController();
  bool _isLoggedIn = false;
  List<User> _registeredUsers = [];

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return MyHomePage(logoutCallback: _logout);
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('登入'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _loginUsernameController,
                decoration: InputDecoration(labelText: '使用者名稱'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _loginPasswordController,
                decoration: InputDecoration(labelText: '密碼'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _login();
                },
                child: Text('登入'),
              ),
              SizedBox(height: 20),
              Text('還沒有帳號？'),
              TextField(
                controller: _registerUsernameController,
                decoration: InputDecoration(labelText: '新使用者名稱'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _registerPasswordController,
                decoration: InputDecoration(labelText: '新密碼'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _register();
                },
                child: Text('註冊'),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _login() {
    String loginUsername = _loginUsernameController.text;
    String loginPassword = _loginPasswordController.text;

    if (_isLoggedIn ||
        _registeredUsers.any((user) =>
        user.username == loginUsername && user.password == loginPassword)) {
      setState(() {
        _isLoggedIn = true;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('登入失敗'),
            content: Text('使用者名稱或密碼不正確'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('確定'),
              ),
            ],
          );
        },
      );
    }
  }

  void _register() {
    String registerUsername = _registerUsernameController.text;
    String registerPassword = _registerPasswordController.text;

    if (_registeredUsers.any((user) => user.username == registerUsername)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('註冊失敗'),
            content: Text('使用者名稱已被註冊'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('確定'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _registeredUsers.add(User(username: registerUsername, password: registerPassword));
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('註冊成功'),
            content: Text('請使用新帳號登入'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('確定'),
              ),
            ],
          );
        },
      );
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
    });
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback logoutCallback;

  MyHomePage({required this.logoutCallback});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
late int _targetNumber;
late int _userGuess;
late int _attempts;
late String _resultMessage;
late bool _gameEnded;
late Stopwatch _stopwatch;
String _difficulty = '簡單';
  List<GameResult> _gameHistory = [];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

void _startGame({int? timeLimit, int? guessLimit, String? difficulty}) {
  setState(() {
    _targetNumber = _generateRandomNumber();
    _attempts = 0;
    _resultMessage = '猜一個介於1和100之間的數字';
    _gameEnded = false;
    _stopwatch = Stopwatch()..start();

    if (difficulty == '中等') {
      if (timeLimit != null) {
        Future.delayed(Duration(seconds: timeLimit), () {
          if (!_gameEnded) {
            _endGame('時間到！遊戲結束，正確數字是 $_targetNumber。', difficulty!);
          }
        });
      }
    } else if (difficulty == '困難' && timeLimit != null && guessLimit != null) {
      Future.delayed(Duration(seconds: timeLimit), () {
        if (!_gameEnded && _attempts >= guessLimit) {
          _endGame('猜測次數已達上限，遊戲結束。正確數字是 $_targetNumber。', difficulty!);
        }
      });
    }
  });
}



int _generateRandomNumber() {
    return Random().nextInt(100) + 1;
  }

void _checkGuess() {
  setState(() {
    _attempts++;
    if (_userGuess == _targetNumber) {
      _endGame('恭喜你，猜中了！數字是 $_targetNumber，總共猜了 $_attempts 次。', _difficulty);
    } else if (_userGuess < _targetNumber) {
      _resultMessage = '太小了，再試試看！';
    } else {
      _resultMessage = '太大了，再試試看！';
    }

    if (_difficulty == '困難' && _attempts >= 5) {
      _endGame('猜測次數已達上限，遊戲結束。正確數字是 $_targetNumber。', '困難');
    } else if (_gameEnded) {
      // 如果遊戲已結束，清除計時器
      _stopwatch.stop();
    }
  });
}

  void _endGame(String message, String difficulty) {
    setState(() {
      _resultMessage = message;
      _gameEnded = true;
      _stopwatch.stop();

      GameResult result = GameResult(
        targetNumber: _targetNumber,
        userGuess: _userGuess,
        attempts: _attempts,
        resultMessage: _resultMessage,
        timeElapsed: _stopwatch.elapsed.inSeconds,
        difficulty: difficulty,
      );

      _gameHistory.add(result);
    });
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('歷史紀錄'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _gameHistory.length,
              itemBuilder: (context, index) {
                var result = _gameHistory[index];
                return ListTile(
                  title: Text('數字: ${result.targetNumber}，猜測: ${result.userGuess}，次數: ${result.attempts}，難度: ${result.difficulty}'),
                  subtitle: Text('結果: ${result.resultMessage}，花費時間: ${result.timeElapsed} 秒'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('關閉'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = _stopwatch.elapsed.inSeconds.toString();
    String formattedAttempts = _attempts.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('猜數字遊戲'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              widget.logoutCallback();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_resultMessage',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '計時時間: $formattedTime 秒',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '猜測次數: $formattedAttempts 次',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _userGuess = int.tryParse(value)!;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (!_gameEnded) {
                  _checkGuess();
                }
              },
              child: Text('提交猜測'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _startGame(difficulty: '簡單');
              },
              child: Text('簡單'),
            ),
            ElevatedButton(
              onPressed: () {
                _startGame(timeLimit: 20, difficulty: '中等');
              },
              child: Text('中等'),
            ),
            ElevatedButton(
              onPressed: () {
                _startGame(timeLimit: 20, guessLimit: 5, difficulty: '困難');
              },
              child: Text('困難'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showHistory(); // 顯示歷史紀錄
              },
              child: Text('查看歷史紀錄'),
            ),
          ],
        ),
      ),
    );
  }
}
