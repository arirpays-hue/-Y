import 'package:flutter/material.dart';
import 'difficulty_select_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF0984E3), Color(0xFF6C5CE7), Color(0xFF2D3436)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎮 ', style: TextStyle(fontSize: 32)),
                    Text(
                      'עולם המיני-משחקים (AI הוגן)',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black26, offset: Offset(2, 2))],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    _buildCategoryTitle('♟️ משחקי אסטרטגיה ולוח'),
                    _buildGameCard(
                      context,
                      title: 'משחק שחמט',
                      subtitle: 'שחמט חכם עם טעויות אנוש מחושבות',
                      icon: '♟️',
                      colors: [const Color(0xFF2C3A47), const Color(0xFF1B1464)],
                      screen: const DifficultySelectScreen(gameType: 'chess'),
                    ),
                    _buildGameCard(
                      context,
                      title: 'איקס עיגול',
                      subtitle: 'AI חכם שמדי פעם טועה בכוונה',
                      icon: '❌⭕',
                      colors: [const Color(0xFFFF7675), const Color(0xFFD63031)],
                      screen: const DifficultySelectScreen(gameType: 'tictactoe'),
                    ),
                    const SizedBox(height: 15),
                    _buildCategoryTitle('🧩 משחקי חשיבה וזיכרון'),
                    _buildGameCard(
                      context,
                      title: 'משחק זיכרון',
                      subtitle: 'רובוט שמדי פעם שוכח קלפים',
                      icon: '🧠',
                      colors: [const Color(0xFFA29BFE), const Color(0xFF6C5CE7)],
                      screen: const DifficultySelectScreen(gameType: 'memory'),
                    ),
                    _buildGameCard(
                      context,
                      title: 'טריוויה ואתגר ידע',
                      subtitle: 'שאלות ידע מול AI אנושי',
                      icon: '💡',
                      colors: [const Color(0xFFFD79A8), const Color(0xFFE84393)],
                      screen: const DifficultySelectScreen(gameType: 'trivia'),
                    ),
                    const SizedBox(height: 15),
                    _buildCategoryTitle('⚡ משחקי פעולה וזריזות'),
                    _buildGameCard(
                      context,
                      title: 'משחק סנייק',
                      subtitle: 'נחש AI שעלול להתבלבל בדרך',
                      icon: '🐍',
                      colors: [const Color(0xFF55E6C1), const Color(0xFF1ABC9C)],
                      screen: const DifficultySelectScreen(gameType: 'snake'),
                    ),
                    _buildGameCard(
                      context,
                      title: 'תפוס את התפוח',
                      subtitle: 'זריזות מול מתחרה שיכול לפספס',
                      icon: '🍎',
                      colors: [const Color(0xFFFFEAA7), const Color(0xFFFDCB6E)],
                      screen: const DifficultySelectScreen(gameType: 'catch'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0, right: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 4, color: Colors.black38, offset: Offset(1, 1))],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required List<Color> colors,
    required Widget screen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
