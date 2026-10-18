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
  bool isGameOver = false;
  String statusMessage = "תורך לשחק (לבן) ♟️";

  // הערכת שווי כלי שחמט בסיסי
  final Map<String, int> pieceValues = {
    'p': 100, 'n': 320, 'b': 330, 'r': 500, 'q': 900, 'k': 20000,
    'P': 100, 'N': 320, 'B': 330, 'R': 500, 'Q': 900, 'K': 20000,
  };

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
      isGameOver = false;
      statusMessage = "תורך לשחק (לבן) ♟️";
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
    if (!isWhiteTurn || isGameOver) return;

    if (selectedRow == null) {
      if (_isWhite(board[r][c])) {
        setState(() {
          selectedRow = r;
          selectedCol = c;
          validMoves = _getValidMoves(board, r, c);
        });
      }
    } else {
      if (validMoves.contains(Point(r, c))) {
        String targetPiece = board[r][c];
        _makeMove(board, selectedRow!, selectedCol!, r, c);

        // בדיקת ניצחון באכילת מלך
        if (targetPiece == 'k') {
          _endGame("שח מט! ניצחת את ה-AI! 🎉");
          return;
        }

        setState(() {
          selectedRow = null;
          selectedCol = null;
          validMoves.clear();
          isWhiteTurn = false;
          statusMessage = "ה-AI מחשב מהלך אופטימלי... 🤖";
        });

        Timer(const Duration(milliseconds: 500), _aiMove);
      } else {
        setState(() {
          if (_isWhite(board[r][c])) {
            selectedRow = r;
            selectedCol = c;
            validMoves = _getValidMoves(board, r, c);
          } else {
            selectedRow = null;
            selectedCol = null;
            validMoves.clear();
          }
        });
      }
    }
  }

  void _makeMove(List<List<String>> bd, int fromR, int fromC, int toR, int toC) {
    bd[toR][toC] = bd[fromR][fromC];
    bd[fromR][fromC] = '';
  }

  List<Point<int>> _getValidMoves(List<List<String>> bd, int r, int c) {
    List<Point<int>> moves = [];
    String piece = bd[r][c];
    if (piece.isEmpty) return moves;

    bool isWhite = _isWhite(piece);
    String type = piece.toLowerCase();

    if (type == 'p') {
      int dir = isWhite ? -1 : 1;
      if (r + dir >= 0 && r + dir < 8 && bd[r + dir][c].isEmpty) {
        moves.add(Point(r + dir, c));
        if ((isWhite && r == 6) || (!isWhite && r == 1)) {
          if (bd[r + (dir * 2)][c].isEmpty) moves.add(Point(r + (dir * 2), c));
        }
      }
      for (int dc in [-1, 1]) {
        if (r + dir >= 0 && r + dir < 8 && c + dc >= 0 && c + dc < 8) {
          String target = bd[r + dir][c + dc];
          if (target.isNotEmpty && (isWhite ? _isBlack(target) : _isWhite(target))) {
            moves.add(Point(r + dir, c + dc));
          }
        }
      }
    } else if (type == 'n') {
      List<Point<int>> steps = [
        const Point(-2, -1), const Point(-2, 1), const Point(-1, -2), const Point(-1, 2),
        const Point(1, -2), const Point(1, 2), const Point(2, -1), const Point(2, 1)
      ];
      for (var p in steps) {
        int nr = r + p.x, nc = c + p.y;
        if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
          String target = bd[nr][nc];
          if (target.isEmpty || (isWhite ? _isBlack(target) : _isWhite(target))) {
            moves.add(Point(nr, nc));
          }
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
          String target = bd[nr][nc];
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

  // 🧠 אלגוריתם Minimax מעמיק עם Alpha-Beta Pruning
  void _aiMove() {
    if (isGameOver) return;

    int depth = widget.difficulty == 1 ? 1 : (widget.difficulty == 2 ? 2 : 3);
    int bestScore = -99999;
    Map<String, dynamic>? bestMove;

    List<Map<String, dynamic>> allMoves = _getAllPossibleMoves(board, false);

    if (allMoves.isEmpty) {
      _endGame("שח מט! ניצחת את המשחק! 🎉");
      return;
    }

    for (var move in allMoves) {
      Point<int> from = move['from'];
      Point<int> to = move['to'];

      // שמירת מצב זמני
      String tempTarget = board[to.x][to.y];
      String tempSource = board[from.x][from.y];

      // ביצוע מהלך נסיוני
      _makeMove(board, from.x, from.y, to.x, to.y);

      // הערכת הלוח
      int score = _minimax(board, depth - 1, -100000, 100000, false);

      // ביטול המהלך הנסיוני
      board[from.x][from.y] = tempSource;
      board[to.x][to.y] = tempTarget;

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    // 🚨 שילוב טעות אנוש מחושבת (ברמה 3 יש 15% סיכוי למהלך פחות מושלם)
    if (widget.difficulty == 3 && Random().nextDouble() < 0.15 && allMoves.length > 1) {
      allMoves.shuffle();
      bestMove = allMoves.first;
    }

    if (bestMove != null) {
      Point<int> from = bestMove['from'];
      Point<int> to = bestMove['to'];
      String targetPiece = board[to.x][to.y];

      _makeMove(board, from.x, from.y, to.x, to.y);

      // בדיקה אם ה-AI אכל את מלך השחקן
      if (targetPiece == 'K') {
        _endGame("ה-AI אכל את המלך שלך! הפסדת 🤖");
        return;
      }
    }

    setState(() {
      isWhiteTurn = true;
      statusMessage = "תורך לשחק (לבן) ♟️";
    });
  }

  int _minimax(List<List<String>> bd, int depth, int alpha, int beta, bool isMaximizing) {
    if (depth == 0) return _evaluateBoard(bd);

    List<Map<String, dynamic>> moves = _getAllPossibleMoves(bd, !isMaximizing);

    if (isMaximizing) {
      int maxEval = -99999;
      for (var m in moves) {
        Point<int> from = m['from'];
        Point<int> to = m['to'];
        String tempTarget = bd[to.x][to.y];
        String tempSource = bd[from.x][from.y];

        _makeMove(bd, from.x, from.y, to.x, to.y);
        int eval = _minimax(bd, depth - 1, alpha, beta, false);
        bd[from.x][from.y] = tempSource;
        bd[to.x][to.y] = tempTarget;

        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 99999;
      for (var m in moves) {
        Point<int> from = m['from'];
        Point<int> to = m['to'];
        String tempTarget = bd[to.x][to.y];
        String tempSource = bd[from.x][from.y];

        _makeMove(bd, from.x, from.y, to.x, to.y);
        int eval = _minimax(bd, depth - 1, alpha, beta, true);
        bd[from.x][from.y] = tempSource;
        bd[to.x][to.y] = tempTarget;

        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  int _evaluateBoard(List<List<String>> bd) {
    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String p = bd[r][c];
        if (p.isNotEmpty) {
          int val = pieceValues[p] ?? 0;
          if (_isBlack(p)) {
            score += val; // ניקוד חיובי ל-AI
          } else {
            score -= val; // ניקוד שלילי לשחקן
          }
        }
      }
    }
    return score;
  }

  List<Map<String, dynamic>> _getAllPossibleMoves(List<List<String>> bd, bool forWhite) {
    List<Map<String, dynamic>> moves = [];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String p = bd[r][c];
        if (p.isNotEmpty && (forWhite ? _isWhite(p) : _isBlack(p))) {
          List<Point<int>> valid = _getValidMoves(bd, r, c);
          for (var v in valid) {
            moves.add({'from': Point(r, c), 'to': v});
          }
        }
      }
    }
    return moves;
  }

  void _endGame(String message) {
    setState(() {
      isGameOver = true;
      statusMessage = message;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('סיום משחק השחמט ♟️'),
        content: Text(message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetBoard();
            },
            child: const Text('משחק חדש'),
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
        title: Text('שחמט מתקדם (רמה ${widget.difficulty})'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
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
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _resetBoard,
            icon: const Icon(Icons.refresh),
            label: const Text('משחק חדש'),
          ),
        ],
      ),
    );
  }
}
