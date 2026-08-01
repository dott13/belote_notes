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

                if (game.gameMode == GameMode.twoVsTwo)
                  ...List.generate(game.teams.length, (teamIndex) {
                    final team = game.teams[teamIndex];
                    // Filter to only valid player IDs
                    final validPlayerIds = team.playerIds
                        .where((playerId) =>
                            game.players.any((p) => p.id == playerId))
                        .toList();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: teamNameControllers[teamIndex],
                            decoration: const InputDecoration(
                              labelText: 'Team Name',
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...validPlayerIds.asMap().entries.map((entry) {
                            final memberIndex = entry.key;
                            final playerId = entry.value;
                            final controllerIndex = game.players.indexWhere(
                              (p) => p.id == playerId,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8.0,
                                left: 16.0,
                              ),
                              child: TextField(
                                controller: controllers[controllerIndex],
                                decoration: InputDecoration(
                                  labelText: 'Player ${memberIndex + 1} Name',
                                ),
                              ),
                            );
                          }),
                        ],
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
              final updatedPlayers = <Player>[];
              for (var i = 0; i < game.players.length; i++) {
                final name = controllers[i].text.trim();
                String defaultName;

                if (game.gameMode == GameMode.twoVsTwo) {
                  defaultName = game.players[i].name;
                } else if (game.gameMode == GameMode.twoPlayers) {
                  defaultName = i == 0 ? 'Team 1' : 'Team 2';
                } else {
                  defaultName = 'Player ${i + 1}';
                }

                updatedPlayers.add(
                  Player(
                    id: game.players[i].id,
                    name: name.isEmpty ? defaultName : name,
                  ),
                );
              }

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
