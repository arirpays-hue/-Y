import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGameScreen extends StatefulWidget {
  final int difficulty;
  const SnakeGameScreen({super.key, required this.difficulty});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

enum Direction { up, down, left, right }

class _SnakeGameScreenState extends State<SnakeGameScreen> with SingleTickerProviderStateMixin {
  static const int rows = 20;
  static const int columns = 15;
  
  List<int> snake = [45, 44, 43];
  List<int> aiSnake = [200, 201, 202]; // נחש AI אדום
  int food = 100;
  List<int> bombs = []; // פצצות בשלבים מתקדמים
  
  Direction direction = Direction.right;
  Direction aiDirection = Direction.left;
  Timer? timer;
  bool isPlaying = false;
  bool isAiMode = true; // האם לשחק עם AI או לבד
  int score = 0;

  // אנימציית פיצוץ לפצצות
  late AnimationController _explosionController;
  bool showExplosion = false;

  @override
  void initState() {
    super.initState();
    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _explosionController.dispose();
    super.dispose();
  }

  void _startGame(bool withAi) {
    setState(() {
      isAiMode = withAi;
      snake = [45, 44, 43];
      aiSnake = [200, 201, 202];
      direction = Direction.right;
      score = 0;
      isPlaying = true;
      showExplosion = false;
      bombs.clear();
      _generateFood();
      if (widget.difficulty >= 2) {
        _generateBombs();
      }
    });

    timer?.cancel();
    // מהירות משחק משתנה לפי רמת הקושי
    int speed = widget.difficulty == 3 ? 160 : (widget.difficulty == 2 ? 200 : 250);
    
    timer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      _updateGame();
    });
  }

  void _generateFood() {
    final random = Random();
    do {
      food = random.nextInt(rows * columns);
    } while (snake.contains(food) || aiSnake.contains(food) || bombs.contains(food));
  }

  void _generateBombs() {
    final random = Random();
    bombs.clear();
    // כמות פצצות בהתאם לרמת הקושי
    int bombCount = widget.difficulty == 3 ? 5 : 3;
    while (bombs.length < bombCount) {
      int b = random.nextInt(rows * columns);
      if (!snake.contains(b) && b != food && !bombs.contains(b)) {
        bombs.add(b);
      }
    }
  }

  void _updateGame() {
    setState(() {
      int newHead = _calcNext(snake.first, direction);

      // בדיקת פגיעה בקירות, בעצמו, או בפצצה
      if (snake.contains(newHead) || (isAiMode && aiSnake.contains(newHead)) || bombs.contains(newHead)) {
        if (bombs.contains(newHead)) {
          showExplosion = true;
          _explosionController.forward(from: 0);
        }
        _endGame(bombs.contains(newHead) ? 'התפוצצת על פצצה! 💥' : 'הפסדת! הנחש התנגש 🐍');
        return;
      }

      snake.insert(0, newHead);

      // אכילת תפוח
      if (newHead == food) {
        score += 10;
        _generateFood();
        if (widget.difficulty >= 2 && Random().nextDouble() < 0.4) {
          _generateBombs(); // הזזת פצצות מדי פעם
        }
      } else {
        snake.removeLast();
      }

      // תנועת נחש ה-AI (אם מופעל)
      if (isAiMode) {
        int aiHead = _calcNext(aiSnake.first, aiDirection);
        if (Random().nextDouble() < 0.25) {
          aiDirection = Direction.values[Random().nextInt(4)];
        }
        if (aiSnake.contains(aiHead) || snake.contains(aiHead) || bombs.contains(aiHead)) {
          aiHead = aiSnake.first + 1;
        }
        aiSnake.insert(0, aiHead);
        if (aiHead != food) aiSnake.removeLast();
      }
    });
  }

  int _calcNext(int current, Direction dir) {
    switch (dir) {
      case Direction.up:
        int h = current - columns;
        return h < 0 ? h + (rows * columns) : h;
      case Direction.down:
        int h = current + columns;
        return h >= rows * columns ? h - (rows * columns) : h;
      case Direction.left:
        return (current % columns == 0) ? current + columns - 1 : current - 1;
      case Direction.right:
        return ((current + 1) % columns == 0) ? current - columns + 1 : current + 1;
    }
  }

  void _endGame(String msg) {
    timer?.cancel();
    isPlaying = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('המשחק נגמר! 🎮'),
        content: Text('$msg\nהניקוד הסופי שלך: $score', style: const TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('תפריט ראשי'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3436),
      appBar: AppBar(
        title: Text('סנייק (רמה ${widget.difficulty}) - ניקוד: $score'),
        backgroundColor: const Color(0xFF00B894),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00B894), width: 3),
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF1E272E),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    children: [
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rows * columns,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns),
                        itemBuilder: (context, index) {
                          if (snake.contains(index)) {
                            return Container(margin: const EdgeInsets.all(1), decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(4)));
                          }
                          if (isAiMode && aiSnake.contains(index)) {
                            return Container(margin: const EdgeInsets.all(1), decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(4)));
                          }
                          if (index == food) {
                            return const Center(child: Text('🍎', style: TextStyle(fontSize: 20)));
                          }
                          if (bombs.contains(index)) {
                            return const Center(child: Text('💣', style: TextStyle(fontSize: 20)));
                          }
                          return Container(margin: const EdgeInsets.all(1), color: Colors.white.withOpacity(0.02));
                        },
                      ),
                      // אנימציית פיצוץ אדומה
                      if (showExplosion)
                        AnimatedBuilder(
                          animation: _explosionController,
                          builder: (context, child) {
                            return Container(
                              color: Colors.red.withOpacity(1.0 - _explosionController.value),
                              child: const Center(
                                child: Text('💥', style: TextStyle(fontSize: 80)),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // כפתורי בחירת מצב משחק לפני התחלה
          if (!isPlaying)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white).wrap(
                      ElevatedButton(
                        onPressed: () => _startGame(false),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: const Text('שחק לבד 👤', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _startGame(true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('נגד נחש AI 🤖', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          // פקדי תנועה (חצים)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 36, color: Colors.white),
                  onPressed: () { if (direction != Direction.down) direction = Direction.up; },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 36, color: Colors.white),
                      onPressed: () { if (direction != Direction.right) direction = Direction.left; },
                    ),
                    const SizedBox(width: 60),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 36, color: Colors.white),
                      onPressed: () { if (direction != Direction.left) direction = Direction.right; },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 36, color: Colors.white),
                  onPressed: () { if (direction != Direction.up) direction = Direction.down; },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on ButtonStyle {
  Widget wrap(Widget child) => child;
}
