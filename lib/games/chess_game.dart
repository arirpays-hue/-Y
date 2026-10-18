import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ChessGameScreen extends StatefulWidget {
  final int difficulty;
  const ChessGameScreen({super.key, required this.difficulty});

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  late List<List<String>> board;
  int? selectedRow;
  int? selectedCol;
  List<Point<int>> validMoves = [];
  bool isWhiteTurn = true;
  String statusMessage = "תור השחקן (לבן) ♟️";

  @override
  void initState() {
    super.initState();
    _resetBoard();
  }

  void _resetBoard() {
    setState(() {
      board = [
        ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'],
        ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'],
        ['', '', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
        ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],
        ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'],
      ];
      selectedRow = null;
      selectedCol = null;
      validMoves.clear();
      isWhiteTurn = true;
      statusMessage = "תור השחקן (לבן) ♟️";
    });
  }

  String _getPieceSymbol(String piece) {
    switch (piece) {
      case 'K': return '♔';
      case 'Q': return '♕';
      case 'R': return '♖';
      case 'B': return '♗';
      case 'N': return '♘';
      case 'P': return '♙';
      case 'k': return '♚';
      case 'q': return '♛';
      case 'r': return '♜';
      case 'b': return '♝';
      case 'n': return '♞';
      case 'p': return '♟';
      default: return '';
    }
  }

  bool _isWhite(String piece) => piece.isNotEmpty && piece == piece.toUpperCase();
  bool _isBlack(String piece) => piece.isNotEmpty && piece == piece.toLowerCase();

  void _onSquareTap(int r, int c) {
    if (!isWhiteTurn) return;

    if (selectedRow == null) {
      if (_isWhite(board[r][c])) {
        setState(() {
          selectedRow = r;
          selectedCol = c;
          validMoves = _getValidMoves(r, c);
        });
      }
    } else {
      if (validMoves.contains(Point(r, c))) {
        _makeMove(selectedRow!, selectedCol!, r, c);
        setState(() {
          selectedRow = null;
          selectedCol = null;
          validMoves.clear();
          isWhiteTurn = false;
          statusMessage = "ה-AI חושב ומחפש מהלך... 🤖";
        });
        Timer(const Duration(milliseconds: 700), _aiMove);
      } else {
        setState(() {
          if (_isWhite(board[r][c])) {
            selectedRow = r;
            selectedCol = c;
            validMoves = _getValidMoves(r, c);
          } else {
            selectedRow = null;
            selectedCol = null;
            validMoves.clear();
          }
        });
      }
    }
  }

  void _makeMove(int fromR, int fromC, int toR, int toC) {
    setState(() {
      board[toR][toC] = board[fromR][fromC];
      board[fromR][fromC] = '';
    });
  }

  List<Point<int>> _getValidMoves(int r, int c) {
    List<Point<int>> moves = [];
    String piece = board[r][c];
    if (piece.isEmpty) return moves;
    bool isWhite = _isWhite(piece);
    String type = piece.toLowerCase();

    if (type == 'p') {
      int dir = isWhite ? -1 : 1;
      if (r + dir >= 0 && r + dir < 8 && board[r + dir][c].isEmpty) {
        moves.add(Point(r + dir, c));
        if ((isWhite && r == 6) || (!isWhite && r == 1)) {
          if (board[r + (dir * 2)][c].isEmpty) moves.add(Point(r + (dir * 2), c));
        }
      }
      for (int dc in [-1, 1]) {
        if (r + dir >= 0 && r + dir < 8 && c + dc >= 0 && c + dc < 8) {
          String target = board[r + dir][c + dc];
          if (target.isNotEmpty && (isWhite ? _isBlack(target) : _isWhite(target))) {
            moves.add(Point(r + dir, c + dc));
          }
        }
      }
    } else if (type == 'n') {
      List<Point<int>> knightSteps = [
        const Point(-2, -1), const Point(-2, 1), const Point(-1, -2), const Point(-1, 2),
        const Point(1, -2), const Point(1, 2), const Point(2, -1), const Point(2, 1)
      ];
      for (var p in knightSteps) {
        int nr = r + p.x, nc = c + p.y;
        if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
          String target = board[nr][nc];
          if (target.isEmpty || (isWhite ? _isBlack(target) : _isWhite(target))) moves.add(Point(nr, nc));
        }
      }
    } else {
      List<Point<int>> dirs = [];
      if (type == 'r' || type == 'q') dirs.addAll([const Point(1, 0), const Point(-1, 0), const Point(0, 1), const Point(0, -1)]);
      if (type == 'b' || type == 'q') dirs.addAll([const Point(1, 1), const Point(1, -1), const Point(-1, 1), const Point(-1, -1)]);
      if (type == 'k') dirs.addAll([const Point(1, 0), const Point(-1, 0), const Point(0, 1), const Point(0, -1), const Point(1, 1), const Point(1, -1), const Point(-1, 1), const Point(-1, -1)]);
      int maxDist = (type == 'k') ? 1 : 7;

      for (var d in dirs) {
        for (int i = 1; i <= maxDist; i++) {
          int nr = r + (d.x * i), nc = c + (d.y * i);
          if (nr < 0 || nr >= 8 || nc < 0 || nc >= 8) break;
          String target = board[nr][nc];
          if (target.isEmpty) {
            moves.add(Point(nr, nc));
          } else {
            if (isWhite ? _isBlack(target) : _isWhite(target)) moves.add(Point(nr, nc));
            break;
          }
        }
      }
    }
    return moves;
  }

  void _aiMove() {
    List<Map<String, dynamic>> allMoves = [];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (_isBlack(board[r][c])) {
          List<Point<int>> moves = _getValidMoves(r, c);
          for (var m in moves) {
            int score = 0;
            String target = board[m.x][m.y];
            if (target.isNotEmpty) {
              switch (target.toUpperCase()) {
                case 'Q': score = 90; break;
                case 'R': score = 50; break;
                case 'B': score = 30; break;
                case 'N': score = 30; break;
                case 'P': score = 10; break;
                case 'K': score = 900; break;
              }
            }
            allMoves.add({'from': Point(r, c), 'to': m, 'score': score});
          }
        }
      }
    }

    if (allMoves.isNotEmpty) {
      allMoves.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

      Map<String, dynamic> chosenMove;
      if (widget.difficulty == 1) {
        chosenMove = allMoves[Random().nextInt(allMoves.length)];
      } else if (widget.difficulty == 2) {
        chosenMove = allMoves[Random().nextInt(min(4, allMoves.length))];
      } else {
        if (Random().nextDouble() < 0.20 && allMoves.length > 1) {
          chosenMove = allMoves[Random().nextInt(min(allMoves.length, 5))];
        } else {
          chosenMove = allMoves.first;
        }
      }

      Point<int> from = chosenMove['from'];
      Point<int> to = chosenMove['to'];
      _makeMove(from.x, from.y, to.x, to.y);
    }

    setState(() {
      isWhiteTurn = true;
      statusMessage = "תור השחקן (לבן) ♟️";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3436),
      appBar: AppBar(title: Text('שחמט (AI הוגן רמה ${widget.difficulty})'), backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
            child: Text(statusMessage, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.white30, width: 3)),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 64,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                  itemBuilder: (context, index) {
                    int r = index ~/ 8;
                    int c = index % 8;
                    bool isDark = (r + c) % 2 != 0;
                    bool isSelected = selectedRow == r && selectedCol == c;
                    bool isValidMove = validMoves.contains(Point(r, c));

                    Color bg = isDark ? const Color(0xFFB88B4A) : const Color(0xFFE3C16F);
                    if (isSelected) bg = Colors.yellow.shade600;
                    if (isValidMove) bg = Colors.green.shade400;

                    return GestureDetector(
                      onTap: () => _onSquareTap(r, c),
                      child: Container(
                        color: bg,
                        child: Center(
                          child: Text(
                            _getPieceSymbol(board[r][c]),
                            style: TextStyle(
                              fontSize: 32,
                              color: _isWhite(board[r][c]) ? Colors.white : Colors.black,
                              shadows: const [Shadow(blurRadius: 2, color: Colors.black45)],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          ElevatedButton.icon(onPressed: _resetBoard, icon: const Icon(Icons.refresh), label: const Text('משחק חדש')),
        ],
      ),
    );
  }
}
