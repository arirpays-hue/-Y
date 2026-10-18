import 'package:flutter/material.dart';
import '../games/game_registry.dart';

class DifficultySelectScreen extends StatelessWidget {
  final String gameId;
  const DifficultySelectScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final game = GameRegistry.getGame(gameId);

    return Scaffold(
      appBar: AppBar(title: Text(game != null ? 'בחר רמת קושי - ${game.title}' : 'בחר רמת קושי')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _launch(context, 1),
              child: const Text('קל 🟢'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _launch(context, 2),
              child: const Text('בינוני 🟡'),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _launch(context, 3),
              child: const Text('קשה 🔴'),
            ),
          ],
        ),
      ),
    );
  }

  void _launch(BuildContext context, int difficulty) {
    final game = GameRegistry.getGame(gameId);
    if (game == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => game.buildScreen(difficulty)),
    );
  }
}
