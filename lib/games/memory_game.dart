import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MemoryGameScreen extends StatefulWidget {
  final int difficulty;
  const MemoryGameScreen({super.key, required this.difficulty});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<String> _items = ['🐶', '🐱', '🐭', '🐹', '🦊', '🐻'];
  late List<String> _cards;
  late List<bool> _cardFlips;
  Map<int, String> memoryAI = {};
  int? _prev;
  bool _busy = false;
  int playerScore = 0;
  int aiScore = 0;
  bool isPlayerTurn = true;

  @override
  void initState() {
    super.initState();
    _startNew();
  }

  void _startNew() {
    setState(() {
      _cards = [..._items, ..._items]..shuffle();
      _cardFlips = List.filled(_cards.length, false);
      memoryAI.clear();
      _prev = null;
      playerScore = 0;
      aiScore = 0;
      isPlayerTurn = true;
      _busy = false;
    });
  }

  void _onTap(int index) {
    if (_busy || _cardFlips[index] || !isPlayerTurn) return;

    setState(() {
      _cardFlips[index] = true;
      memoryAI[index] = _cards[index];
    });

    if (_prev == null) {
      _prev = index;
    } else {
      if (_cards[_prev!] == _cards[index]) {
        playerScore++;
        _prev = null;
        if (playerScore + aiScore == _items.length) _showEnd();
      } else {
        _busy = true;
        Timer(const Duration(milliseconds: 800), () {
          setState(() {
            _cardFlips[_prev!] = false;
            _cardFlips[index] = false;
            _prev = null;
            _busy = false;
            isPlayerTurn = false;
          });
          Timer(const Duration(seconds: 1), _aiTurn);
        });
      }
    }
  }

  void _aiTurn() {
    if (playerScore + aiScore == _items.length) return;
    int first = -1, second = -1;

    bool makeHumanMistake = widget.difficulty == 3 ? (Random().nextDouble() < 0.3) : true;

    if (widget.difficulty == 3 && !makeHumanMistake) {
      for (var entry1 in memoryAI.entries) {
        if (!_cardFlips[entry1.key]) {
          for (var entry2 in memoryAI.entries) {
            if (entry1.key != entry2.key && entry1.value == entry2.value && !_cardFlips[entry2.key]) {
              first = entry1.key;
              second = entry2.key;
              break;
            }
          }
        }
        if (first != -1) break;
      }
    }

    if (first == -1 || second == -1) {
      List<int> hidden = [];
      for (int i = 0; i < _cards.length; i++) if (!_cardFlips[i]) hidden.add(i);
      hidden.shuffle();
      first = hidden[0];
      second = hidden[1];
    }

    setState(() {
      _cardFlips[first] = true;
      _cardFlips[second] = true;
      memoryAI[first] = _cards[first];
      memoryAI[second] = _cards[second];
    });

    Timer(const Duration(milliseconds: 900), () {
      setState(() {
        if (_cards[first] == _cards[second]) {
          aiScore++;
        } else {
          _cardFlips[first] = false;
          _cardFlips[second] = false;
        }
        isPlayerTurn = true;
      });
      if (playerScore + aiScore == _items.length) _showEnd();
    });
  }

  void _showEnd() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('המשחק נגמר!'),
        content: Text(playerScore > aiScore ? 'ניצחת את ה-AI! 🎉' : 'ה-AI ניצח! 🤖'),
        actions: [TextButton(onPressed: () { Navigator.pop(context); _startNew(); }, child: const Text('שחק שוב'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(title: Text('משחק זיכרון (AI הוגן רמה ${widget.difficulty})')),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Text('שחקן: $playerScore | AI רובוט: $aiScore', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(isPlayerTurn ? 'תורך לשחק 👤' : 'תור ה-AI... 🤖', style: const TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold)),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardFlips[index] ? Colors.white : const Color(0xFF6C5CE7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: Text(_cardFlips[index] ? _cards[index] : '❓', style: const TextStyle(fontSize: 36))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
