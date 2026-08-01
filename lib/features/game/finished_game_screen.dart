import 'package:belote_notes/features/game/dialogs/play_again_dialog.dart';
import 'package:belote_notes/features/game/dialogs/undo_win_dialog.dart';
import 'package:belote_notes/features/game/game_history_screen.dart';
import 'package:belote_notes/features/game/widgets/win_tally.dart';
import 'package:belote_notes/models/game.dart';
import 'package:flutter/material.dart';

class FinishedGameScreen extends StatelessWidget {
  final List<({String id, String name})> entities;
  final ({String id, String name}) winner;
  final Map<String, int> totalScores;
  final Map<String, int> wins;
  final List<MatchHistoryEntry> history;
  final VoidCallback onPlayAgain;
  final VoidCallback onUndo;

  const FinishedGameScreen({
    super.key,
    required this.entities,
    required this.winner,
    required this.totalScores,
    required this.wins,
    required this.history,
    required this.onPlayAgain,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Finished'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GameHistoryScreen(entities: entities, history: history),
              ),
            ),
            icon: const Icon(Icons.history),
            tooltip: 'Match History',
          ),
          IconButton(
            onPressed: () => showUndoWinDialog(context, onConfirm: onUndo),
            icon: const Icon(Icons.undo),
            tooltip: 'Undo Win',
          ),
          IconButton(
            onPressed: () =>
                showPlayAgainDialog(context, onConfirm: onPlayAgain),
            icon: const Icon(Icons.replay),
            tooltip: 'Play Again',
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
              if (wins.values.any((count) => count > 0)) ...[
                const SizedBox(height: 16),
                const Text(
                  'Series:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                WinTally(scoringEntities: entities, wins: wins),
              ],
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
