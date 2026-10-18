import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGameScreen extends StatefulWidget {
  final int difficulty;
  const SnakeGameScreen({super.key, required this.difficulty});

  @override
  State<SnakeGameScreen> createState() => SnakeGameScreenState();
}

enum Direction { up, down, left, right }

class SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int rows = 20;
  static const int columns = 15;
  List<int> snake = [45, 44, 43];
  List<int> aiSnake = [200, 201, 202];
  int food = 100;
  Direction direction = Direction.right;
  Direction aiDirection = Direction.left;
  Timer? timer;
  bool isPlaying = false;
  int score = 0;

  void _startGame() {
    setState(() {
      snake = [45, 44, 43];
      aiSnake = [200, 201, 202];
      direction = Direction.right;
      score = 0;
      isPlaying = true;
      _generateFood();
    });
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 220), (timer) { _updateGame(); });
  }

  void _generateFood() {
    final random = Random();
    do { food = random.nextInt(rows * columns); } while (snake.contains(food) || aiSnake.contains(food));
  }

  void _updateGame() {
    setState(() {
      int newHead = _calcNext(snake.first, direction);
      if (snake.contains(newHead) || aiSnake.contains(newHead)) {
        _endGame('הפסדת לנחש של ה-AI! 🤖');
        return;
      }
      snake.insert(0, newHead);
      if (newHead == food) {
        score += 10;
        _generateFood();
      } else {
        snake.removeLast();
      }

      int aiHead = _calcNext(aiSnake.first, aiDirection);
      if (Random().nextDouble() < 0.4) aiDirection = Direction.values[Random().nextInt(4)];
      aiSnake.insert(0, aiHead);
      if (aiHead != food) aiSnake.removeLast();
    });
  }

  int _calcNext(int current, Direction dir) {
    switch (dir) {
      case Direction.up: int h = current - columns; return h < 0 ? h + (rows * columns) : h;
      case Direction.down: int h = current + columns; return h >= rows * columns ? h - (rows * columns) : h;
      case Direction.left: return (current % columns == 0) ? current + columns - 1 : current - 1;
      case Direction.right: return ((current + 1) % columns == 0) ? current - columns + 1 : current + 1;
    }
  }

  void _endGame(String msg) {
    timer?.cancel();
    isPlaying = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('המשחק נגמר! 🐍'),
        content: Text('$msg\nהניקוד שלך: $score'),
        actions: [TextButton(onPressed: () { Navigator.pop(context); _startGame(); }, child: const Text('שחק שוב'))],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('סנייק נגד AI - ניקוד: $score')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.teal, width: 2)),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rows * columns,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns),
                  itemBuilder: (context, index) {
                    if (snake.contains(index)) return Container(margin: const EdgeInsets.all(1), color: Colors.green);
                    if (aiSnake.contains(index)) return Container(margin: const EdgeInsets.all(1), color: Colors.red);
                    if (index == food) return const Center(child: Text('🍎', style: TextStyle(fontSize: 16)));
                    return Container(margin: const EdgeInsets.all(1), color: Colors.teal.shade50);
                  },
                ),
              ),
            ),
          ),
          if (!isPlaying) ElevatedButton(onPressed: _startGame, child: const Text('התחל משחק', style: TextStyle(fontSize: 20))),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                IconButton(icon: const Icon(Icons.arrow_upward, size: 32), onPressed: () { if (direction != Direction.down) direction = Direction.up; }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back, size: 32), onPressed: () { if (direction != Direction.right) direction = Direction.left; }),
                    const SizedBox(width: 40),
                    IconButton(icon: const Icon(Icons.arrow_forward, size: 32), onPressed: () { if (direction != Direction.left) direction = Direction.right; }),
                  ],
                ),
                IconButton(icon: const Icon(Icons.arrow_downward, size: 32), onPressed: () { if (direction != Direction.up) direction = Direction.down; }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
