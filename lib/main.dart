import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MiniGamesApp());
}

class MiniGamesApp extends StatelessWidget {
  const MiniGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ערכת מיני משחקים',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

// ==========================================
// 🏠 מסך תפריט ראשי
// ==========================================
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text('אוסף מיני משחקים 🎮'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGameButton(
                context,
                title: 'איקס עיגול (שחקן נגד שחקן) ❌⭕',
                color: Colors.deepPurple,
                screen: const TicTacToeScreen(isAI: false),
              ),
              const SizedBox(height: 15),
              _buildGameButton(
                context,
                title: 'איקס עיגול (נגד המחשב 🤖)',
                color: Colors.deepOrange,
                screen: const TicTacToeScreen(isAI: true),
              ),
              const SizedBox(height: 15),
              _buildGameButton(
                context,
                title: 'משחק זיכרון 🧠',
                color: Colors.indigo,
                screen: const MemoryGameScreen(),
              ),
              const SizedBox(height: 15),
              _buildGameButton(
                context,
                title: 'משחק סנייק 🐍',
                color: Colors.teal,
                screen: const SnakeGameScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton(BuildContext context,
      {required String title, required Color color, required Widget screen}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Text(title, textAlign: TextAlign.center),
      ),
    );
  }
}

// ==========================================
// 1️⃣ משחק איקס עיגול (כולל מצב AI)
// ==========================================
class TicTacToeScreen extends StatefulWidget {
  final bool isAI;
  const TicTacToeScreen({super.key, required this.isAI});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, '');
  bool isXTurn = true; // X שחקן אנושי, O מחשב או שחקן 2
  String statusMessage = "תור השחקן: X";
  bool isGameOver = false;

  void _handleTap(int index) {
    if (board[index] != '' || isGameOver) return;

    setState(() {
      board[index] = 'X';
      if (_checkWinner('X')) {
        statusMessage = "המנצח הוא: X! 🎉";
        isGameOver = true;
      } else if (!board.contains('')) {
        statusMessage = "תיקו! 🤝";
        isGameOver = true;
      } else {
        if (widget.isAI) {
          isXTurn = false;
          statusMessage = "תור המחשב לחשוב... 🤖";
          Timer(const Duration(milliseconds: 500), _aiMove);
        } else {
          isXTurn = !isXTurn;
          statusMessage = "תור השחקן: ${isXTurn ? 'X' : 'O'}";
        }
      }
    });
  }

  void _aiMove() {
    if (isGameOver) return;
    
    // מציאת משבצת ריקה אקראית עבור המחשב (או חכמה בסיסית)
    List<int> emptyIndexes = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') emptyIndexes.add(i);
    }

    if (emptyIndexes.isNotEmpty) {
      // בחירה אקראית חכמה למחשב
      int aiChoice = emptyIndexes[Random().nextInt(emptyIndexes.length)];
      
      setState(() {
        board[aiChoice] = 'O';
        if (_checkWinner('O')) {
          statusMessage = "המחשב ניצח! 🤖";
          isGameOver = true;
        } else if (!board.contains('')) {
          statusMessage = "תיקו! 🤝";
          isGameOver = true;
        } else {
          isXTurn = true;
          statusMessage = "תור השחקן: X";
        }
      });
    }
  }

  bool _checkWinner(String player) {
    const winningCombo = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];
    for (var combo in winningCombo) {
      if (board[combo[0]] == player &&
          board[combo[1]] == player &&
          board[combo[2]] == player) {
        return true;
      }
    }
    return false;
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      isXTurn = true;
      isGameOver = false;
      statusMessage = "תור השחקן: X";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(title: Text(widget.isAI ? 'איקס עיגול - נגד המחשב' : 'איקס עיגול - שחקנים')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(statusMessage, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _handleTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          board[index],
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: board[index] == 'X' ? Colors.deepPurple : Colors.deepOrange,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text('משחק חדש'),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2️⃣ משחק זיכרון
// ==========================================
class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> _items = ['🐶', '🐱', '🐭', '🐹', '🦊', '🐻'];
  late List<String> _cards;
  late List<bool> _cardFlips;
  int? _previousIndex;
  bool _busy = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _cards = [..._items, ..._items]..shuffle();
      _cardFlips = List.filled(_cards.length, false);
      _previousIndex = null;
      _score = 0;
      _busy = false;
    });
  }

  void _onCardTap(int index) {
    if (_busy || _cardFlips[index]) return;

    setState(() {
      _cardFlips[index] = true;
    });

    if (_previousIndex == null) {
      _previousIndex = index;
    } else {
      if (_cards[_previousIndex!] == _cards[index]) {
        _score++;
        _previousIndex = null;
      } else {
        _busy = true;
        Timer(const Duration(milliseconds: 800), () {
          setState(() {
            _cardFlips[_previousIndex!] = false;
            _cardFlips[index] = false;
            _previousIndex = null;
            _busy = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(title: const Text('משחק זיכרון')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text('זוגות שנמצאו: $_score / ${_items.length}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onCardTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardFlips[index] ? Colors.white : Colors.indigo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _cardFlips[index] ? _cards[index] : '❓',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _startNewGame,
            icon: const Icon(Icons.refresh),
            label: const Text('משחק חדש'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ==========================================
// 3️⃣ משחק סנייק (מתוקן עם תפוחים בולטים)
// ==========================================
class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => SnakeGameScreenState();
}

enum Direction { up, down, left, right }

class SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int rows = 20;
  static const int columns = 15;
  List<int> snake = [45, 44, 43];
  int food = 100;
  Direction direction = Direction.right;
  Timer? timer;
  bool isPlaying = false;
  int score = 0;

  void _startGame() {
    setState(() {
      snake = [45, 44, 43];
      direction = Direction.right;
      score = 0;
      isPlaying = true;
      _generateFood();
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      _updateSnake();
    });
  }

  void _generateFood() {
    final random = Random();
    do {
      food = random.nextInt(rows * columns);
    } while (snake.contains(food));
  }

  void _updateSnake() {
    setState(() {
      int newHead;
      switch (direction) {
        case Direction.up:
          newHead = snake.first - columns;
          if (newHead < 0) newHead += rows * columns;
          break;
        case Direction.down:
          newHead = snake.first + columns;
          if (newHead >= rows * columns) newHead -= rows * columns;
          break;
        case Direction.left:
          newHead = (snake.first % columns == 0) ? snake.first + columns - 1 : snake.first - 1;
          break;
        case Direction.right:
          newHead = ((snake.first + 1) % columns == 0) ? snake.first - columns + 1 : snake.first + 1;
          break;
      }

      if (snake.contains(newHead)) {
        timer?.cancel();
        isPlaying = false;
        _showGameOverDialog();
        return;
      }

      snake.insert(0, newHead);
      if (newHead == food) {
        score += 10;
        _generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('המשחק נגמר! 🐍'),
        content: Text('הניקוד שלך: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('שחק שוב'),
          )
        ],
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
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(title: Text('סנייק - ניקוד: $score')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 2),
                  color: Colors.teal.shade100,
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rows * columns,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                  ),
                  itemBuilder: (context, index) {
                    if (snake.contains(index)) {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: snake.first == index ? Colors.green.shade900 : Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }
                    if (index == food) {
                      return const Center(
                        child: Text('🍎', style: TextStyle(fontSize: 18)),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.all(1),
                      color: Colors.teal.shade50,
                    );
                  },
                ),
              ),
            ),
          ),
          if (!isPlaying)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                child: const Text('התחל משחק', style: TextStyle(fontSize: 20)),
              ),
            ),
          // מקשי שליטה נוחים
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 36, color: Colors.teal),
                  onPressed: () { if (direction != Direction.down) direction = Direction.up; },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 36, color: Colors.teal),
                      onPressed: () { if (direction != Direction.right) direction = Direction.left; },
                    ),
                    const SizedBox(width: 50),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 36, color: Colors.teal),
                      onPressed: () { if (direction != Direction.left) direction = Direction.right; },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 36, color: Colors.teal),
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
