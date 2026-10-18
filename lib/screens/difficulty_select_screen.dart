import 'package:flutter/material.dart';
import '../games/chess_game.dart';
import '../games/tictactoe_game.dart';
import '../games/memory_game.dart';
import '../games/trivia_game.dart';
import '../games/snake_game.dart';
import '../games/catch_game.dart';

class DifficultySelectScreen extends StatelessWidget {
  final String gameType;
  const DifficultySelectScreen({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('בחירת רמת קושי הוגנת'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'בחר רמת קושי מול המחשב:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
              ),
              const SizedBox(height: 30),
              _buildOption(context, '🟢 קל - מתחילים', Colors.green, 1),
              const SizedBox(height: 16),
              _buildOption(context, '🟡 בינוני - מאוזן', Colors.orange, 2),
              const SizedBox(height: 16),
              _buildOption(context, '🔴 קשה - AI חכם עם טעויות אנוש', Colors.red, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, Color color, int level) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        onPressed: () {
          Widget game;
          if (gameType == 'chess') {
            game = ChessGameScreen(difficulty: level);
          } else if (gameType == 'tictactoe') {
            game = TicTacToeScreen(difficulty: level);
          } else if (gameType == 'memory') {
            game = MemoryGameScreen(difficulty: level);
          } else if (gameType == 'trivia') {
            game = TriviaGameScreen(difficulty: level);
          } else if (gameType == 'catch') {
            game = CatchGameScreen(difficulty: level);
          } else {
            game = SnakeGameScreen(difficulty: level);
          }

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => game));
        },
        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
