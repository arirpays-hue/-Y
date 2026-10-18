import 'dart:math';
import 'package:flutter/material.dart';

class TriviaGameScreen extends StatefulWidget {
  final int difficulty;
  const TriviaGameScreen({super.key, required this.difficulty});

  @override
  State<TriviaGameScreen> createState() => _TriviaGameScreenState();
}

class _TriviaGameScreenState extends State<TriviaGameScreen> {
  int currentQuestion = 0;
  int playerScore = 0;
  int aiScore = 0;

  final List<Map<String, dynamic>> questions = [
    {'q': 'מהי עיר הבירה של צרפת?', 'a': ['לונדון', 'פריז', 'ברלין', 'רומא'], 'correct': 1},
    {'q': 'כמה ימים יש בשנה מעוברת?', 'a': ['365', '366', '364', '360'], 'correct': 1},
    {'q': 'איזה כוכב לכת הוא הקרוב ביותר לשמש?', 'a': ['נוגה', 'מאדים', 'חמה', 'צדק'], 'correct': 2},
  ];

  void _answer(int index) {
    if (index == questions[currentQuestion]['correct']) playerScore += 10;
    if (Random().nextDouble() < (widget.difficulty * 0.25)) aiScore += 10;

    if (currentQuestion + 1 < questions.length) {
      setState(() { currentQuestion++; });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('סיום הטריוויה! 💡'),
        content: Text('הניקוד שלך: $playerScore\nהניקוד של ה-AI: $aiScore'),
        actions: [TextButton(onPressed: () { Navigator.pop(context); setState(() { currentQuestion = 0; playerScore = 0; aiScore = 0; }); }, child: const Text('שחק שוב'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestion];
    return Scaffold(
      appBar: AppBar(title: Text('טריוויה נגד AI - ניקוד: $playerScore')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('שאלה ${currentQuestion + 1}/${questions.length}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(q['q'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ...List.generate(4, (i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white),
                  onPressed: () => _answer(i),
                  child: Text(q['a'][i], style: const TextStyle(fontSize: 18)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
