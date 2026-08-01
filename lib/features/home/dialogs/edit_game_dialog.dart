import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/utils/date_formatter.dart';
import 'package:flutter/material.dart';

void showEditGameDialog(
  BuildContext context,
  BeloteGame game, {
  required void Function(BeloteGame updatedGame) onSave,
}) {
  final controllers = game.players
      .map((player) => TextEditingController(text: player.name))
      .toList();
  final teamNameControllers = game.teams
      .map((team) => TextEditingController(text: team.name))
      .toList();
  int maxScore = game.maxScore;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Edit Game'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Game Mode: ${game.gameMode}'),
                Text('Created: ${DateFormatter.formatDate(game.createdAt)}'),
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  initialValue: maxScore,
                  items: const [
                    DropdownMenuItem(value: 51, child: Text('51 points')),
                    DropdownMenuItem(value: 101, child: Text('101 points')),
                    DropdownMenuItem(value: 151, child: Text('151 points')),
                    DropdownMenuItem(value: 201, child: Text('201 points')),
                    DropdownMenuItem(value: 301, child: Text('301 points')),
                    DropdownMenuItem(value: 501, child: Text('501 points')),
                    DropdownMenuItem(value: 1001, child: Text('1001 points')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      maxScore = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Maximum Score',
                  ),
                ),
                const SizedBox(height: 16),

                // Individual player identity doesn't matter yet for 2v2 —
                // only the team name is editable, until per-player rosters
                // exist.
                if (game.gameMode == GameMode.twoVsTwo)
                  ...List.generate(game.teams.length, (teamIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextField(
                        controller: teamNameControllers[teamIndex],
                        decoration: const InputDecoration(
                          labelText: 'Team Name',
                        ),
                      ),
                    );
                  })
                else
                  ...controllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: game.gameMode == GameMode.twoPlayers
                              ? index == 0
                                    ? 'Team 1 Name'
                                    : 'Team 2 Name'
                              : 'Player ${index + 1} Name',
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Individual player names aren't editable for 2v2 anymore
              // (only the team name is), so those players pass through
              // unchanged.
              final updatedPlayers = game.gameMode == GameMode.twoVsTwo
                  ? game.players
                  : controllers.asMap().entries.map((entry) {
                      final i = entry.key;
                      final name = entry.value.text.trim();
                      final defaultName = game.gameMode == GameMode.twoPlayers
                          ? (i == 0 ? 'Team 1' : 'Team 2')
                          : 'Player ${i + 1}';
                      return Player(
                        id: game.players[i].id,
                        name: name.isEmpty ? defaultName : name,
                      );
                    }).toList();

              final updatedTeams = game.teams.asMap().entries.map((entry) {
                final index = entry.key;
                final team = entry.value;
                final name = teamNameControllers[index].text.trim();
                // Filter to only valid player IDs
                final validPlayerIds = team.playerIds
                    .where((playerId) =>
                        updatedPlayers.any((p) => p.id == playerId))
                    .toList();
                return Team(
                  id: team.id,
                  name: name.isEmpty ? team.name : name,
                  playerIds: validPlayerIds,
                );
              }).toList();

              final updateGame = BeloteGame(
                id: game.id,
                players: updatedPlayers,
                rounds: game.rounds,
                createdAt: game.createdAt,
                gameMode: game.gameMode,
                maxScore: maxScore,
                winnerId: game.winnerId,
                teams: updatedTeams,
              );

              onSave(updateGame);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
