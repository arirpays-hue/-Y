import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TicTacToeScreen extends StatefulWidget {
  final int difficulty;
  const TicTacToeScreen({super.key, required this.difficulty});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<String> board = List.filled(9, '');
  bool isGameOver = false;
  String statusMessage = "תורך לשחק (X)";

  void _handleTap(int index) {
    if (board[index] != '' || isGameOver) return;

    setState(() {
      board[index] = 'X';
      if (_checkWinner('X')) {
        statusMessage = "ניצחת את ה-AI! 🎉";
        isGameOver = true;
      } else if (!board.contains('')) {
        statusMessage = "תיקו! 🤝";
        isGameOver = true;
      } else {
        statusMessage = "תור ה-AI... 🤖";
        Timer(const Duration(milliseconds: 400), _aiMove);
      }
    });
  }

  void _aiMove() {
    if (isGameOver) return;
    int bestMove = -1;

    if (widget.difficulty == 3 && Random().nextDouble() > 0.25) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == '') {
          board[i] = 'O';
          int score = _minimax(board, 0, false);
          board[i] = '';
          if (score > bestScore) {
            bestScore = score;
            bestMove = i;
          }
        }
      }
    } else {
      List<int> empty = [];
      for (int i = 0; i < 9; i++) if (board[i] == '') empty.add(i);
      bestMove = empty[Random().nextInt(empty.length)];
    }

    setState(() {
      board[bestMove] = 'O';
      if (_checkWinner('O')) {
        statusMessage = "המחשב ניצח! 🤖";
        isGameOver = true;
      } else if (!board.contains('')) {
        statusMessage = "תיקו! 🤝";
        isGameOver = true;
      } else {
        statusMessage = "תורך לשחק (X)";
      }
    });
  }

  int _minimax(List<String> bd, int depth, bool isMax) {
    if (_checkWinner('O')) return 10 - depth;
    if (_checkWinner('X')) return depth - 10;
    if (!bd.contains('')) return 0;

    if (isMax) {
      int best = -1000;
      for (int i = 0; i < 9; i++) {
        if (bd[i] == '') {
          bd[i] = 'O';
          best = max(best, _minimax(bd, depth + 1, false));
          bd[i] = '';
        }
      }
      return best;
    } else {
      int best = 1000;
      for (int i = 0; i < 9; i++) {
        if (bd[i] == '') {
          bd[i] = 'X';
          best = min(best, _minimax(bd, depth + 1, true));
          bd[i] = '';
        }
      }
      return best;
    }
  }

  bool _checkWinner(String p) {
    const wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (var w in wins) {
      if (board[w[0]] == p && board[w[1]] == p && board[w[2]] == p) return true;
    }
    return false;
  }

  void _reset() {
    setState(() {
      board = List.filled(9, '');
      isGameOver = false;
      statusMessage = "תורך לשחק (X)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(title: Text('איקס עיגול (AI הוגן רמה ${widget.difficulty})')),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _handleTap(index),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Center(
                        child: Text(
                          board[index],
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: board[index] == 'X' ? const Color(0xFF6C5CE7) : const Color(0xFFFF7675)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          ElevatedButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh), label: const Text('משחק חדש')),
        ],
      ),
    );
  }
}
