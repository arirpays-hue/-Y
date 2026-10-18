import 'package:flutter/material.dart';

abstract class BaseGame {
  String get id;
  String get title;
  String get subtitle;
  String get icon;

  Widget buildScreen(int difficulty, {bool initialPvP = false});
}

class GameRegistry {
  static final List<BaseGame> _registeredGames = [];

  static void register(BaseGame game) {
    if (!_registeredGames.any((g) => g.id == game.id)) {
      _registeredGames.add(game);
    }
  }

  static List<BaseGame> get games => List.unmodifiable(_registeredGames);

  static BaseGame? getGame(String id) {
    try {
      return _registeredGames.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}
