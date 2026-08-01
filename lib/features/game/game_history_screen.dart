import 'package:belote_notes/features/game/game_history_detail_screen.dart';
import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/utils/date_formatter.dart';
import 'package:flutter/material.dart';

class GameHistoryScreen extends StatelessWidget {
  final List<({String id, String name})> entities;
  final List<MatchHistoryEntry> history;

  const GameHistoryScreen({
    super.key,
    required this.entities,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final entries = history.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Match History')),
      body: entries.isEmpty
          ? const Center(child: Text('No completed games yet.'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final gameNumber = entries.length - index;
                final winner = entities.firstWhere(
                  (e) => e.id == entry.winnerId,
                  orElse: () => (id: 'unknown', name: 'Unknown'),
                );
                final scoreLine = entities
                    .map((e) => '${e.name}: ${entry.finalScores[e.id] ?? 0}')
                    .join('   ');

                return ListTile(
                  leading: CircleAvatar(child: Text('$gameNumber')),
                  title: Text(
                    '${winner.name} won',
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    '$scoreLine\n${DateFormatter.formatDate(entry.finishedAt)}',
                    textAlign: TextAlign.center,
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameHistoryDetailScreen(
                        entities: entities,
                        entry: entry,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
