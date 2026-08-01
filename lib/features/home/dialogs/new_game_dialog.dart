import 'package:belote_notes/models/game.dart';
import 'package:flutter/material.dart';

void showNewGameDialog(
  BuildContext context, {
  required void Function(
    List<String> names,
    String gameMode,
    int maxScore,
  )
  onCreate,
}) {
  final controllers = List.generate(4, (_) => TextEditingController());
  String gameMode = GameMode.twoVsTwo;
  int playerCount = 2;
  int maxScore = 101;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('New Game'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: gameMode,
                  items: const [
                    DropdownMenuItem(
                      value: GameMode.twoVsTwo,
                      child: Text('2 v 2 (Teams)'),
                    ),
                    DropdownMenuItem(
                      value: GameMode.twoPlayers,
                      child: Text('2 Players (Classic)'),
                    ),
                    DropdownMenuItem(
                      value: GameMode.threePlayers,
                      child: Text('3 Players (Cut-throat)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      gameMode = value!;
                      playerCount = switch (gameMode) {
                        GameMode.twoVsTwo => 2,
                        GameMode.twoPlayers => 2,
                        _ => 3,
                      };
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Game Mode'),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  initialValue: maxScore,
                  items: [
                    DropdownMenuItem(value: 51, child: Text('51 points')),
                    DropdownMenuItem(value: 101, child: Text('101 points')),
                    DropdownMenuItem(value: 151, child: Text('151 points')),
                    DropdownMenuItem(value: 201, child: Text('201 points')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      maxScore = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Maximum Score',
                    helperText: 'First to reach wins',
                  ),
                ),
                const SizedBox(height: 16),

                // Team identity is all that matters for now; individual
                // players within a 2v2 team can be picked later once
                // per-player rosters exist.
                ...List.generate(playerCount, (index) {
                  final isTeamName =
                      gameMode == GameMode.twoVsTwo ||
                      gameMode == GameMode.twoPlayers;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        labelText: isTeamName
                            ? 'Team ${index + 1} Name'
                            : 'Player ${index + 1} Name',
                        hintText: isTeamName
                            ? 'Team ${index + 1}'
                            : 'Player ${index + 1}',
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
              final isTeamName =
                  gameMode == GameMode.twoVsTwo ||
                  gameMode == GameMode.twoPlayers;
              final names = <String>[];
              for (var i = 0; i < playerCount; i++) {
                final name = controllers[i].text.trim();
                final defaultName = isTeamName
                    ? 'Team ${i + 1}'
                    : 'Player ${i + 1}';
                names.add(name.isEmpty ? defaultName : name);
              }

              onCreate(names, gameMode, maxScore);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}
