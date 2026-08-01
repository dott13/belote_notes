import 'package:belote_notes/features/game/widgets/round_history_table.dart';
import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/utils/date_formatter.dart';
import 'package:flutter/material.dart';

class GameHistoryDetailScreen extends StatelessWidget {
  final List<({String id, String name})> entities;
  final MatchHistoryEntry entry;

  const GameHistoryDetailScreen({
    super.key,
    required this.entities,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final winner = entities.firstWhere(
      (e) => e.id == entry.winnerId,
      orElse: () => (id: 'unknown', name: 'Unknown'),
    );

    return Scaffold(
      appBar: AppBar(title: Text(DateFormatter.formatDate(entry.finishedAt))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${winner.name} won',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          RoundHistoryTable(
            rounds: entry.rounds,
            scoringEntities: entities,
            totalScores: entry.finalScores,
          ),
        ],
      ),
    );
  }
}
