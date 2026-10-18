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
      statusMessage = isPvP ? "תור השחקן הלבן ♟️" : "תורך לשחק מול ה-AI (לבן) ♟️";
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
          validMoves = _getValidMoves(board, r, c);
        });
      }
    } else {
      if (validMoves.contains(Point(r, c))) {
        String targetPiece = board[r][c];
        _makeMove(board, selectedRow!, selectedCol!, r, c);

        if (targetPiece == 'k') {
          _endGame("שח מט! השחקן הלבן ניצח! 🎉");
          return;
        } else if (targetPiece == 'K') {
          _endGame("שח מט! השחקן השחור ניצח! 🎉");
          return;
        }

        setState(() {
          selectedRow = null;
          selectedCol = null;
          validMoves.clear();
          isWhiteTurn = !isWhiteTurn;
          statusMessage = isPvP 
              ? (isWhiteTurn ? "תור השחקן הלבן ♟️" : "תור השחקן השחור ♟️")
              : "ה-AI מחשב מהלך... 🤖";
        });

        if (!isPvP && !isWhiteTurn) {
          Timer(const Duration(milliseconds: 500), _aiMove);
        }
      } else {
        setState(() {
          if (isCurrentPlayerPiece) {
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

  void _aiMove() {
    if (isGameOver || isPvP) return;

    List<Map<String, dynamic>> allMoves = [];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (_isBlack(board[r][c])) {
          List<Point<int>> moves = _getValidMoves(board, r, c);
          for (var m in moves) {
            int score = 0;
            String target = board[m.x][m.y];
            if (target.isNotEmpty) {
              score = pieceValues[target.toLowerCase()] ?? 10;
            }
            allMoves.add({'from': Point(r, c), 'to': m, 'score': score});
          }
        }
      }
    }

    if (allMoves.isNotEmpty) {
      allMoves.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      Map<String, dynamic> chosenMove = allMoves.first;

      Point<int> from = chosenMove['from'];
      Point<int> to = chosenMove['to'];
      String targetPiece = board[to.x][to.y];

      _makeMove(board, from.x, from.y, to.x, to.y);

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
