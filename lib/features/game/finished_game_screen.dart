import 'package:belote_notes/features/game/dialogs/reopen_game_dialog.dart';
import 'package:flutter/material.dart';

class FinishedGameScreen extends StatelessWidget {
  final List<({String id, String name})> entities;
  final ({String id, String name}) winner;
  final Map<String, int> totalScores;
  final VoidCallback onReopen;

  const FinishedGameScreen({
    super.key,
    required this.entities,
    required this.winner,
    required this.totalScores,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Finished'),
        actions: [
          IconButton(
            onPressed: () =>
                showReopenGameDialog(context, onConfirm: onReopen),
            icon: const Icon(Icons.edit),
            tooltip: 'Reopen Game',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                '${winner.name} Wins!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Final Score: ${totalScores[winner.id]}',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 32),
              const Text(
                'Final Scores:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...entities.map((entity) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${entity.name}: ${totalScores[entity.id]}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: entity.id == winner.id
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: entity.id == winner.id ? Colors.amber : null,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
