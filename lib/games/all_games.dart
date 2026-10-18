import 'package:flutter/material.dart';

import 'chess_game.dart';
import 'checkers_game.dart';
import 'snake_game.dart';
import 'catch_game.dart';
import 'trivia_game.dart';

class GameItem {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final WidgetBuilder screenBuilder;

  GameItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screenBuilder,
  });
}

List<GameItem> getAllGames() {
  return [
    GameItem(
      id: 'chess',
      title: 'שחמט',
      subtitle: 'משחק אסטרטגיה מלא מול AI או חבר',
      icon: '♟️',
      screenBuilder: (context) => const ChessGameScreen(difficulty: 1),
    ),
    GameItem(
      id: 'checkers',
      title: 'דמקה',
      subtitle: 'דמקה קלאסית עם חוקי מלך ואפשרות PvP',
      icon: '🔴',
      screenBuilder: (context) => const CheckersGameScreen(difficulty: 1, initialPvP: false),
    ),
    GameItem(
      id: 'snake',
      title: 'סנייק',
      subtitle: 'משחק הנחש הקלאסי',
      icon: '🐍',
      screenBuilder: (context) => const SnakeGameScreen(difficulty: 1), // הוספת difficulty
    ),
    GameItem(
      id: 'catch',
      title: 'תפוס את הנופלים',
      subtitle: 'משחק תגובה מהיר',
      icon: '🎯',
      screenBuilder: (context) => const CatchGameScreen(difficulty: 1), // הוספת difficulty אם נדרש
    ),
    GameItem(
      id: 'trivia',
      title: 'טריוויה',
      subtitle: 'בחן את הידע שלך',
      icon: '❓',
      screenBuilder: (context) => const TriviaGameScreen(difficulty: 1), // הוספת difficulty אם נדרש
    ),
  ];
}
