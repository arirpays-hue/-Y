import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CatchGameScreen extends StatefulWidget {
  final int difficulty;
  const CatchGameScreen({super.key, required this.difficulty});

  @override
  State<CatchGameScreen> createState() => _CatchGameScreenState();
}

class _CatchGameScreenState extends State<CatchGameScreen> {
  int targetIndex = 0;
  int score = 0;
  int misses = 0; // מעקב אחרי פספוסים
  Timer? timer;
  bool isPlaying = false;

  void _start() {
    setState(() {
      score = 0;
      misses = 0;
      isPlaying = true;
      _spawnTarget();
    });
  }

  void _spawnTarget() {
    timer?.cancel();

    // קביעת מהירות קפיצת התפוח בהתאם לרמת הקושי
    int durationMs = widget.difficulty == 3 ? 500 : (widget.difficulty == 2 ? 900 : 1400);

    timer = Timer.periodic(Duration(milliseconds: durationMs), (t) {
      setState(() {
        misses++;
        if (misses >= 5) {
          _endGame();
          return;
        }
        targetIndex = Random().nextInt(16);
      });
    });
  }

  void _tap(int i) {
    if (!isPlaying) return;

    if (i == targetIndex) {
      setState(() {
        score++;
        _spawnTarget(); // איפוס הטיימר לתפוח הבא מיד כשלוחצים נכון
      });
    } else {
      setState(() {
        score = max(0, score - 1); // קנס קטן על לחיצה שגויה
      });
    }
  }

  void _endGame() {
    timer?.cancel();
    isPlaying = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('המשחק נגמר! 🍎'),
        content: Text('הניקוד הסופי שלך: $score\nכל הכבוד על הזריזות!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _start();
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
      backgroundColor: const Color(0xFF2D3436),
      appBar: AppBar(
        title: Text('תפוס את התפוח (רמה ${widget.difficulty})'),
        backgroundColor: const Color(0xFFE17055),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // לוח תוצאות ופספוסים
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Chip(
                label: Text('נקודות: $score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.orange.shade100,
              ),
              Chip(
                label: Text('פספוסים: $misses / 5', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                backgroundColor: Colors.red.shade100,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 16,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  bool isTarget = index == targetIndex && isPlaying;
                  return GestureDetector(
                    onTap: () => _tap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isTarget ? const Color(0xFFFF7675) : const Color(0xFF636E72),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isTarget
                            ? [const BoxShadow(color: Colors.redAccent, blurRadius: 10, spreadRadius: 2)]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          isTarget ? '🍎' : '',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (!isPlaying)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE17055),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _start,
                  child: const Text('התחל משחק זריזות', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
