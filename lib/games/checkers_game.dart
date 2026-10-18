import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'game_registry.dart';

// רישום אוטומטי למערכת המשחקים
final _checkersAutoRegister = GameRegistry.register(_CheckersAdapter());

class _CheckersAdapter extends BaseGame {
  @override String get id => 'checkers';
  @override String get title => 'דמקה';
  @override String get subtitle => 'אסטרטגיה קלאסית מול AI או חבר (PvP)';
  @override String get icon => '🔴';

  @override
  Widget buildScreen(int difficulty, {bool initialPvP = false}) {
    return CheckersGameScreen(difficulty: difficulty, initialPvP: initialPvP);
  }
}

class CheckersGameScreen extends StatefulWidget {
  final int difficulty;
  final bool initialPvP;

  const CheckersGameScreen({
    super.key,
    required this.difficulty,
    this.initialPvP = false,
  });

  @override
  State<CheckersGameScreen> createState() => _CheckersGameScreenState();
}

class CheckerPiece {
  final bool isRed; // true = אדום (שחקן), false = שחור (AI / שחקן שני)
  bool isKing;

  CheckerPiece({required this.isRed, this.isKing = false});
}

class _CheckersGameScreenState extends State<CheckersGameScreen> {
  late List<List<CheckerPiece?>> board;
  int? selectedRow;
  int? selectedCol;
  List<Point<int>> validMoves = [];
  bool isRedTurn = true;
  late bool isPvP;
  bool isGameOver = false;
  String statusMessage = "תור השחקן האדום 🔴";

  @override
  void initState() {
    super.initState();
    isPvP = widget.initialPvP;
    _resetBoard(isPvP);
  }

  void _resetBoard(bool pvpMode) {
    setState(() {
      isPvP = pvpMode;
      isRedTurn = true;
      isGameOver = false;
      selectedRow = null;
      selectedCol = null;
      validMoves.clear();
      statusMessage = isPvP ? "תור השחקן האדום 🔴" : "תורך לשחק (אדום) 🔴";

      board = List.generate(8, (_) => List.generate(8, (_) => null));

      // הכלים השחורים למעלה
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 8; c++) {
          if ((r + c) % 2 != 0) {
            board[r][c] = CheckerPiece(isRed: false);
          }
        }
      }

      // הכלים האדומים למטה
      for (int r = 5; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          if ((r + c) % 2 != 0) {
            board[r][c] = CheckerPiece(isRed: true);
          }
        }
      }
    });
  }

  void _onSquareTap(int r, int c) {
    if (isGameOver) return;
    if (!isPvP && !isRedTurn) return;

    CheckerPiece? piece = board[r][c];

    if (selectedRow == null) {
      if (piece != null && piece.isRed == isRedTurn) {
        setState(() {
          selectedRow = r;
          selectedCol = c;
          validMoves = _getValidMoves(r, c);
        });
      }
    } else {
      if (validMoves.contains(Point(r, c))) {
        _makeMove(selectedRow!, selectedCol!, r, c);
      } else {
        setState(() {
          if (piece != null && piece.isRed == isRedTurn) {
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

  List<Point<int>> _getValidMoves(int r, int c) {
    List<Point<int>> moves = [];
    CheckerPiece? piece = board[r][c];
    if (piece == null) return moves;

    List<int> rDirs = [];
    if (piece.isKing) {
      rDirs = [-1, 1];
    } else {
      rDirs = piece.isRed ? [-1] : [1];
    }

    for (int dr in rDirs) {
      for (int dc in [-1, 1]) {
        int nr = r + dr, nc = c + dc;
        if (_inBounds(nr, nc)) {
          if (board[nr][nc] == null) {
            moves.add(Point(nr, nc));
          } else if (board[nr][nc]!.isRed != piece.isRed) {
            int jumpR = nr + dr, jumpC = nc + dc;
            if (_inBounds(jumpR, jumpC) && board[jumpR][jumpC] == null) {
              moves.add(Point(jumpR, jumpC));
            }
          }
        }
      }
    }
    return moves;
  }

  bool _inBounds(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;

  void _makeMove(int fromR, int fromC, int toR, int toC) {
    setState(() {
      CheckerPiece? piece = board[fromR][fromC];
      board[toR][toC] = piece;
      board[fromR][fromC] = null;

      // בדיקת דילוג ואכילה
      if ((toR - fromR).abs() == 2) {
        int midR = (fromR + toR) ~/ 2;
        int midC = (fromC + toC) ~/ 2;
        board[midR][midC] = null;
      }

      // הפיכה למלך
      if (piece != null) {
        if ((piece.isRed && toR == 0) || (!piece.isRed && toR == 7)) {
          piece.isKing = true;
        }
      }

      selectedRow = null;
      selectedCol = null;
      validMoves.clear();

      _checkWinCondition();

      if (!isGameOver) {
        isRedTurn = !isRedTurn;
        statusMessage = isPvP
            ? (isRedTurn ? "תור השחקן האדום 🔴" : "תור השחקן השחור ⚫")
            : "ה-AI מחשב מהלך... 🤖";

        if (!isPvP && !isRedTurn) {
          Timer(const Duration(milliseconds: 600), _aiMove);
        }
      }
    });
  }

  void _aiMove() {
    if (isGameOver || isPvP) return;

    List<Map<String, dynamic>> allMoves = [];

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c] != null && !board[r][c]!.isRed) {
          List<Point<int>> moves = _getValidMoves(r, c);
          for (var m in moves) {
            int score = (m.x - r).abs() == 2 ? 15 : 1; // תעדוף אכילות
            if (board[m.x][m.y] != null && board[m.x][m.y]!.isKing) score += 5;
            allMoves.add({'from': Point(r, c), 'to': m, 'score': score});
          }
        }
      }
    }

    if (allMoves.isNotEmpty) {
      allMoves.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      var chosenMove = allMoves.first;

      Point<int> from = chosenMove['from'];
      Point<int> to = chosenMove['to'];

      _makeMove(from.x, from.y, to.x, to.y);
    } else {
      _endGame("אין לשחור מהלכים! השחקן האדום ניצח! 🎉");
    }
  }

  void _checkWinCondition() {
    bool hasRed = false;
    bool hasBlack = false;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c] != null) {
          if (board[r][c]!.isRed) hasRed = true;
          if (!board[r][c]!.isRed) hasBlack = true;
        }
      }
    }

    if (!hasBlack) _endGame("ניצחת! כל הכלים השחורים נאכלו! 🎉");
    if (!hasRed) _endGame("הפסדת! ה-AI אכל את כל הכלים שלך 🤖");
  }

  void _endGame(String msg) {
    setState(() {
      isGameOver = true;
      statusMessage = msg;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('סיום המשחק 🔴⚫'),
        content: Text(msg, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        title: Text(isPvP ? 'דמקה (שחקן מול שחקן)' : 'דמקה מול AI'),
        backgroundColor: const Color(0xFFD63031),
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _resetBoard(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isPvP ? Colors.red.shade700 : Colors.grey.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('מצב AI 🤖'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _resetBoard(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPvP ? Colors.red.shade700 : Colors.grey.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('שחקן מול שחקן 👥'),
              ),
            ],
          ),
          const SizedBox(height: 10),
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

                    Color bg = isDark ? const Color(0xFF636E72) : const Color(0xFFDFE6E9);
                    if (isSelected) bg = Colors.yellow.shade600;
                    if (isValidMove) bg = Colors.green.shade400;

                    CheckerPiece? piece = board[r][c];

                    return GestureDetector(
                      onTap: () => _onSquareTap(r, c),
                      child: Container(
                        color: bg,
                        child: piece == null
                            ? null
                            : Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: piece.isRed ? const Color(0xFFD63031) : const Color(0xFF2D3436),
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                                  ),
                                  child: piece.isKing
                                      ? const Center(child: Text('👑', style: TextStyle(fontSize: 18)))
                                      : null,
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
