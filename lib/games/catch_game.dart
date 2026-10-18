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
  int aiScore = 0;
  Timer? timer;
  bool isPlaying = false;

  void _start() {
    setState(() {
      score = 0;
      aiScore = 0;
      isPlaying = true;
      targetIndex = Random().nextInt(16);
    });

    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 1200 - (widget.difficulty * 250)), (t) {
      setState(() {
        if (Random().nextDouble() < 0.6) aiScore++;
        targetIndex = Random().nextInt(16);
      });
    });
  }

  void _tap(int i) {
    if (!isPlaying) return;
    if (i == targetIndex) {
      setState(() {
        score++;
        targetIndex = Random().nextInt(16);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('תפוס את התפוח - אתה: $score | AI: $aiScore')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (!isPlaying) ElevatedButton(onPressed: _start, child: const Text('התחל משחק זריזות', style: TextStyle(fontSize: 20))),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 16,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _tap(index),
                  child: Container(
                    decoration: BoxDecoration(color: index == targetIndex ? Colors.red.shade100 : Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                    child: Center(child: Text(index == targetIndex ? '🍎' : '', style: const TextStyle(fontSize: 40))),
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
