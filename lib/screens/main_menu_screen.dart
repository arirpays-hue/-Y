import 'package:flutter/material.dart';
import '../games/game_registry.dart';
import 'difficulty_select_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final availableGames = GameRegistry.games;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('אוסף המשחקים 🎮'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2D2D44),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: availableGames.length,
        itemBuilder: (context, index) {
          final game = availableGames[index];
          return Card(
            color: const Color(0xFF2D2D44),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Text(game.icon, style: const TextStyle(fontSize: 36)),
              title: Text(
                game.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
              subtitle: Text(
                game.subtitle,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DifficultySelectScreen(gameId: game.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
