import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TriviaGameScreen extends StatefulWidget {
  final int difficulty;
  const TriviaGameScreen({super.key, required this.difficulty});

  @override
  State<TriviaGameScreen> createState() => _TriviaGameScreenState();
}

class _TriviaGameScreenState extends State<TriviaGameScreen> {
  int currentQuestionIndex = 0;
  int playerScore = 0;
  int opponentScore = 0;
  int streak = 0;
  bool answered = false;
  int? selectedAnswerIndex;
  
  Timer? questionTimer;
  int timeLeft = 10;

  final List<Map<String, dynamic>> allQuestions = [
    {
      'q': 'מהי עיר הבירה של יפן?',
      'a': ['אוסקה', 'קיוטו', 'טוקיו', 'הירושימה'],
      'correct': 2,
      'category': '🌍 גאוגרפיה'
    },
    {
      'q': 'איזה יסוד כימי מסומן באותיות Au?',
      'a': ['כסף', 'זהב', 'נחושת', 'ברזל'],
      'correct': 1,
      'category': '🧪 מדע וכימיה'
    },
    {
      'q': 'באיזו שנה הוקמה מדינת ישראל?',
      'a': ['1945', '1948', '1950', '1936'],
      'correct': 1,
      'category': '📜 היסטוריה'
    },
    {
      'q': 'מי כתב את הספר "הנסיך הקטן"?',
      'a': ['אנטואן דה סנט-אכזופרי', 'ז\'ול ורן', 'ויקטור הוגו', 'הנס כריסטיאן אנדרסן'],
      'correct': 0,
      'category': '📚 ספרות'
    },
    {
      'q': 'מהו בעל החיים המהיר ביותר ביבשה?',
      'a': ['אריה', 'סוס', 'ברדלס (צ\'יטה)', 'זברה'],
      'correct': 2,
      'category': '🐾 טבע וחיות'
    },
    {
      'q': 'כמה כוכבי לכת יש במערכת השמש שלנו?',
      'a': ['7', '8', '9', '10'],
      'correct': 1,
      'category': '🌌 חלל הארץ'
    },
    {
      'q': 'איזו מדינה היא הגדולה ביותר בעולם מבחינת שטח?',
      'a': ['סין', 'קנדה', 'ארצות הברית', 'רוסיה'],
      'correct': 3,
      'category': '🌍 גאוגרפיה'
    },
    {
      'q': 'מי צייר את יצירת האמנות "מונה ליזה"?',
      'a': ['פאבלו פיקאסו', 'לאונרדו דה וינצ\'י', 'וואן גוך', 'מיכלאנג\'לו'],
      'correct': 1,
      'category': '🎨 אמנות'
    },
    {
      'q': 'מהו האוקיינוס הגדול ביותר בעולם?',
      'a': ['האוקיינוס האטלנטי', 'האוקיינוס ההודי', 'האוקיינוס השקט', 'אוקיינוס הקרח הצפוני'],
      'correct': 2,
      'category': '🌊 טבע ומים'
    },
    {
      'q': 'כמה צבעים יש בקשת בענן?',
      'a': ['5', '6', '7', '8'],
      'correct': 2,
      'category': '🌈 פיזיקה וטבע'
    },
  ];

  late List<Map<String, dynamic>> gameQuestions;

  @override
  void initState() {
    super.initState();
    gameQuestions = List.from(allQuestions)..shuffle();
    gameQuestions = gameQuestions.take(8).toList();
    _startTimer();
  }

  void _startTimer() {
    questionTimer?.cancel();
    timeLeft = widget.difficulty == 3 ? 7 : (widget.difficulty == 2 ? 12 : 20);
    
    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() { timeLeft--; });
      } else {
        timer.cancel();
        _answer(-1);
      }
    });
  }

  void _answer(int index) {
    if (answered) return;
    questionTimer?.cancel();

    setState(() {
      answered = true;
      selectedAnswerIndex = index;

      if (index == gameQuestions[currentQuestionIndex]['correct']) {
        playerScore += (10 + (timeLeft * 2));
        streak++;
      } else {
        streak = 0;
      }

      double opponentAccuracy = widget.difficulty == 1 ? 0.4 : (widget.difficulty == 2 ? 0.7 : 0.85);
      if (Random().nextDouble() < opponentAccuracy) {
        opponentScore += 10;
      }
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (currentQuestionIndex + 1 < gameQuestions.length) {
        setState(() {
          currentQuestionIndex++;
          answered = false;
          selectedAnswerIndex = null;
        });
        _startTimer();
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    questionTimer?.cancel();
    bool won = playerScore >= opponentScore;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? 'ניצחת בטריוויה! 🏆' : 'היריב ניצח! 🤖', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('הניקוד שלך: $playerScore', style: const TextStyle(fontSize: 20, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            Text('הניקוד של היריב: $opponentScore', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(won ? 'כל הכבוד! הפגנת ידע מרשים.' : 'נסה שוב כדי לנצח בסיבוב הבא!'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                gameQuestions.shuffle();
                currentQuestionIndex = 0;
                playerScore = 0;
                opponentScore = 0;
                streak = 0;
                answered = false;
                selectedAnswerIndex = null;
              });
              _startTimer();
            },
            child: const Text('שחק שוב'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = gameQuestions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('טריוויה מאתגרת (רמה ${widget.difficulty})'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text('ניקוד: $playerScore', style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.deepPurple.shade100,
                ),
                Chip(
                  label: Text('⏰ זמן: ${timeLeft}s', style: TextStyle(fontWeight: FontWeight.bold, color: timeLeft <= 3 ? Colors.red : Colors.black)),
                  backgroundColor: Colors.orange.shade100,
                ),
                Chip(
                  label: Text('🔥 רצף: $streak', style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.amber.shade100,
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / gameQuestions.length,
              backgroundColor: Colors.grey.shade300,
              color: const Color(0xFF6C5CE7),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Text(q['category'], style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    q['q'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ...List.generate(4, (i) {
              Color btnColor = Colors.white;
              Color textColor = const Color(0xFF2D3436);

              if (answered) {
                if (i == q['correct']) {
                  btnColor = Colors.green.shade400; // תוקן מ-shade450 ל-shade400 החוקי
                  textColor = Colors.white;
                } else if (i == selectedAnswerIndex) {
                  btnColor = Colors.red.shade400;
                  textColor = Colors.white;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: textColor,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: answered ? null : () => _answer(i),
                  child: Text(q['a'][i], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
