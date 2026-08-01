import 'package:belote_notes/models/game.dart';
import 'package:flutter/material.dart';

void showNewGameDialog(
  BuildContext context, {
  required void Function(
    List<String> playerNames,
    String gameMode,
    int maxScore,
  )
  onCreate,
}) {
  final controllers = List.generate(4, (_) => TextEditingController());
  String gameMode = GameMode.twoVsTwo;
  int playerCount = 4;
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
                        GameMode.twoVsTwo => 4,
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

                if (gameMode == GameMode.twoVsTwo)
                  ...List.generate(2, (teamIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Team ${teamIndex + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...List.generate(2, (slot) {
                            final index = teamIndex * 2 + slot;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: TextField(
                                controller: controllers[index],
                                decoration: InputDecoration(
                                  labelText:
                                      'Team ${teamIndex + 1} - Player ${slot + 1} Name',
                                  hintText:
                                      'Team ${teamIndex + 1} - Player ${slot + 1}',
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  })
                else
                  ...List.generate(playerCount, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextField(
                        controller: controllers[index],
                        decoration: InputDecoration(
                          labelText: gameMode == GameMode.twoPlayers
                              ? index == 0
                                    ? 'Team 1 Name'
                                    : 'Team 2 Name'
                              : 'Player ${index + 1} Name',
                          hintText: gameMode == GameMode.twoPlayers
                              ? index == 0
                                    ? 'Team 1'
                                    : 'Team 2'
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
              final playerNames = <String>[];
              if (gameMode == GameMode.twoVsTwo) {
                for (var i = 0; i < 4; i++) {
                  final name = controllers[i].text.trim();
                  final team = i ~/ 2 + 1;
                  final slot = i % 2 + 1;
                  playerNames.add(
                    name.isEmpty ? 'Team $team - Player $slot' : name,
                  );
                }
              } else {
                for (var i = 0; i < playerCount; i++) {
                  final name = controllers[i].text.trim();
                  if (gameMode == GameMode.twoPlayers) {
                    playerNames.add(name.isEmpty ? 'Team ${i + 1}' : name);
                  } else {
                    playerNames.add(
                      name.isEmpty ? 'Player ${i + 1}' : name,
                    );
                  }
                }
              }

              onCreate(playerNames, gameMode, maxScore);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    ),
  );
}
