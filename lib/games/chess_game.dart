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
  bool isPvP = false;
  String statusMessage = "תור השחקן הלבן ♟️";

  final Map<String, int> pieceValues = {
    'p': 100, 'n': 320, 'b': 330, 'r': 500, 'q': 900, 'k': 20000,
    'P': 100, 'N': 320, 'B': 330, 'R': 500, 'Q': 900, 'K': 20000,
  };

  @override
  void initState() {
    super.initState();
    _resetBoard(false);
  }

  void _resetBoard(bool pvpMode) {
    setState(() {
      isPvP = pvpMode;
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
      statusMessage = isPvP ? "תור השחקן הלבן ♟️" : "תורך לשחק (לבן) ♟️";
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
    if (isGameOver) return;
    if (!isPvP && !isWhiteTurn) return;

    String currentPiece = board[r][c];
    bool isCurrentPlayerPiece = isWhiteTurn ? _isWhite(currentPiece) : _isBlack(currentPiece);

    if (selectedRow == null) {
      if (isCurrentPlayerPiece) {
        setState(() {
          selectedRow = r;
          selectedCol = c;
          validMoves = _getStrictLegalMoves(board, r, c, isWhiteTurn);
        });
      }
    } else {
      if (validMoves.contains(Point(r, c))) {
        _makeMove(board, selectedRow!, selectedCol!, r, c);

        selectedRow = null;
        selectedCol = null;
        validMoves.clear();
        isWhiteTurn = !isWhiteTurn;

        // בדיקת שח, שח-מט ופילוס
        _checkGameState();

        if (!isGameOver && !isPvP && !isWhiteTurn) {
          Timer(const Duration(milliseconds: 500), _aiMove);
        }
      } else {
        setState(() {
          if (isCurrentPlayerPiece) {
            selectedRow = r;
            selectedCol = c;
            validMoves = _getStrictLegalMoves(board, r, c, isWhiteTurn);
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

  // מחזיר את כל המהלכים החוקיים שלא מעמידים את המלך בשח
  List<Point<int>> _getStrictLegalMoves(List<List<String>> bd, int r, int c, bool forWhite) {
    List<Point<int>> pseudoMoves = _getPseudoLegalMoves(bd, r, c);
    List<Point<int>> legalMoves = [];

    for (var move in pseudoMoves) {
      String tempTarget = bd[move.x][move.y];
      String tempSource = bd[r][c];

      bd[move.x][move.y] = tempSource;
      bd[r][c] = '';

      if (!_isKingInCheck(bd, forWhite)) {
        legalMoves.add(move);
      }

      bd[r][c] = tempSource;
      bd[move.x][move.y] = tempTarget;
    }

    return legalMoves;
  }

  // תנועות בסיסיות של כל הכלים לפי החוקים הרשמיים
  List<Point<int>> _getPseudoLegalMoves(List<List<String>> bd, int r, int c) {
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

  // בדיקה האם המלך נמצא תחת איום (שח)
  bool _isKingInCheck(List<List<String>> bd, bool isWhiteKing) {
    Point<int>? kingPos;
    String kingSymbol = isWhiteKing ? 'K' : 'k';

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (bd[r][c] == kingSymbol) {
          kingPos = Point(r, c);
          break;
        }
      }
    }

    if (kingPos == null) return true;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String p = bd[r][c];
        if (p.isNotEmpty && (isWhiteKing ? _isBlack(p) : _isWhite(p))) {
          List<Point<int>> enemyMoves = _getPseudoLegalMoves(bd, r, c);
          if (enemyMoves.contains(kingPos)) return true;
        }
      }
    }
    return false;
  }

  List<Map<String, dynamic>> _getAllStrictLegalMoves(List<List<String>> bd, bool forWhite) {
    List<Map<String, dynamic>> moves = [];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String p = bd[r][c];
        if (p.isNotEmpty && (forWhite ? _isWhite(p) : _isBlack(p))) {
          List<Point<int>> valid = _getStrictLegalMoves(bd, r, c, forWhite);
          for (var v in valid) {
            moves.add({'from': Point(r, c), 'to': v});
          }
        }
      }
    }
    return moves;
  }

  // בדיקת מצב המשחק (שח, שח-מט, פילוס)
  void _checkGameState() {
    bool inCheck = _isKingInCheck(board, isWhiteTurn);
    List<Map<String, dynamic>> allMoves = _getAllStrictLegalMoves(board, isWhiteTurn);

    setState(() {
      if (allMoves.isEmpty) {
        if (inCheck) {
          String winner = isWhiteTurn ? (isPvP ? "השחקן השחור" : "ה-AI") : (isPvP ? "השחקן הלבן" : "השחקן הלבן (אתה)");
          _endGame("שח-מט! $winner ניצח! 🏆");
        } else {
          _endGame("פילוס (תיקו)! אין שום מהלך חוקי לבצע 🤝");
        }
      } else {
        if (inCheck) {
          statusMessage = isWhiteTurn
              ? "שח על המלך הלבן! ⚠️"
              : "שח על המלך השחור! ⚠️";
        } else {
          statusMessage = isPvP
              ? (isWhiteTurn ? "תור השחקן הלבן ♟️" : "תור השחקן השחור ♟️")
              : (isWhiteTurn ? "תורך לשחק (לבן) ♟️" : "ה-AI מחשב מהלך... 🤖");
        }
      }
    });
  }

  // מנוע AI מתקדם
  void _aiMove() {
    if (isGameOver || isPvP) return;

    List<Map<String, dynamic>> allMoves = _getAllStrictLegalMoves(board, false);
    if (allMoves.isEmpty) {
      _checkGameState();
      return;
    }

    Map<String, dynamic>? bestMove;
    int bestScore = -99999;

    for (var move in allMoves) {
      Point<int> from = move['from'];
      Point<int> to = move['to'];

      String tempTarget = board[to.x][to.y];
      String tempSource = board[from.x][from.y];

      _makeMove(board, from.x, from.y, to.x, to.y);
      int score = _evaluateBoard(board);

      board[from.x][from.y] = tempSource;
      board[to.x][to.y] = tempTarget;

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    if (bestMove != null) {
      Point<int> from = bestMove['from'];
      Point<int> to = bestMove['to'];
      _makeMove(board, from.x, from.y, to.x, to.y);
    }

    setState(() {
      isWhiteTurn = true;
      _checkGameState();
    });
  }

  int _evaluateBoard(List<List<String>> bd) {
    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String p = bd[r][c];
        if (p.isNotEmpty) {
          int val = pieceValues[p] ?? 0;
          if (_isBlack(p)) {
            score += val;
          } else {
            score -= val;
          }
        }
      }
    }
    return score;
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
              _resetBoard(isPvP);
            },
            child: const Text('שחק שוב'),
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
        title: Text(isPvP ? 'שחמט (שחקן מול שחקן)' : 'שחמט מול AI'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _resetBoard(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isPvP ? Colors.deepPurple : Colors.grey.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('מצב AI 🤖'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _resetBoard(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPvP ? Colors.deepPurple : Colors.grey.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('שחקן מול שחקן 👥'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
            child: Text(statusMessage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 15),
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
            onPressed: () => _resetBoard(isPvP),
            icon: const Icon(Icons.refresh),
            label: const Text('איפוס לוח'),
          ),
        ],
      ),
    );
  }
}
