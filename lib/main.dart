import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'איקס עיגול',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TicTacToeScreen(),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  // לוח המשחק - 9 משבצות
  List<String> board = List.filled(9, '');
  
  // תור שחקן: true עבור 'X', false עבור 'O'
  bool isXTurn = true;
  
  // הודעת סטטוס
  String statusMessage = "תור השחקן: X";
  
  // האם המשחק הסתיים
  bool isGameOver = false;

  // לוגיקה בלחיצה על משבצת
  void _handleTap(int index) {
    if (board[index] != '' || isGameOver) return;

    setState(() {
      board[index] = isXTurn ? 'X' : 'O';
      
      if (_checkWinner()) {
        statusMessage = "המנצח הוא: ${board[index]}! 🎉";
        isGameOver = true;
      } else if (!board.contains('')) {
        statusMessage = "תיקו! 🤝";
        isGameOver = true;
      } else {
        isXTurn = !isXTurn;
        statusMessage = "תור השחקן: ${isXTurn ? 'X' : 'O'}";
      }
    });
  }

  // בדיקת תנאי ניצחון
  bool _checkWinner() {
    const winningCombo = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // שורות
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // עמודות
      [0, 4, 8], [2, 4, 6]             // אלכסונים
    ];

    for (var combo in winningCombo) {
      if (board[combo[0]] != '' &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        return true;
      }
    }
    return false;
  }

  // איפוס המשחק
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
      appBar: AppBar(
        title: const Text('איקס עיגול'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // הודעת הסטטוס
          Text(
            statusMessage,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 30),

          // לוח המשחק
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _handleTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          board[index],
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: board[index] == 'X'
                                ? Colors.deepPurple
                                : Colors.orangeAccent,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // כפתור איפוס
          ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text('משחק חדש', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
