import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/utils/date_formatter.dart';
import 'package:flutter/material.dart';

class GameListTile extends StatelessWidget {
  final BeloteGame game;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const GameListTile({
    super.key,
    required this.game,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  static String formatParticipants(BeloteGame game) {
    if (game.gameMode == GameMode.twoVsTwo && game.teams.isNotEmpty) {
      return game.teams.map((t) => t.name).join(', ');
    }
    return game.players.map((p) => p.name).join(', ');
  }

  static String? resolveWinnerName(BeloteGame game) {
    if (game.winnerId == null) return null;
    if (game.gameMode == GameMode.twoVsTwo) {
      return game.teams.firstWhere(
        (t) => t.id == game.winnerId,
        orElse: () => Team(id: game.winnerId!, name: 'Unknown', playerIds: []),
      ).name;
    }
    return game.players.firstWhere(
      (p) => p.id == game.winnerId,
      orElse: () => Player(id: game.winnerId!, name: 'Unknown'),
    ).name;
  }

  @override
  Widget build(BuildContext context) {
    final winnerName = resolveWinnerName(game);
    final winnerText = winnerName != null ? '\nWinner: $winnerName' : '';

    return ListTile(
      title: Text(
        'Game ${index + 1}${game.winnerId != null ? ' (Finished)' : ''}',
      ),
      subtitle: Text(
        '${DateFormatter.formatDate(game.createdAt)}\n'
        '${game.gameMode}: ${formatParticipants(game)}\n'
        'Max Score: ${game.maxScore}$winnerText',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
