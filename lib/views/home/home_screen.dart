import 'dart:convert';
import 'dart:io';

import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/services/storage_service.dart';
import 'package:belote_notes/utils/date_formatter.dart';
import 'package:belote_notes/views/game/game_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Belote Notes'),
          actions: [
            IconButton(onPressed: _exportData, icon: const Icon(Icons.upload)),
            IconButton(
              onPressed: _importData,
              icon: const Icon(Icons.download),
            ),
          ],
        ),
        body: _buildGameList(),
        floatingActionButton: FloatingActionButton(
          onPressed: _showNewGameDialogue,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildGameList() {
    return ValueListenableBuilder(
      valueListenable: StorageService.gamesBox.listenable(),
      builder: (context, box, _) {
        final games = box.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (games.isEmpty) {
          return const Center(child: Text('No games yet'));
        }

        return ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            final winnerText = game.winnerId != null
                ? '\nWinner: ${game.players.firstWhere((p) => p.id == game.winnerId).name}'
                : '';

            return ListTile(
              title: Text(
                'Game ${index + 1}${game.winnerId != null ? ' (Finished)' : ''}',
              ),
              subtitle: Text(
                '${DateFormatter.formatDate(game.createdAt)}\n'
                '${game.gameMode}: ${_formatGameParticipants(game)}\n'
                'Max Score: ${game.maxScore}$winnerText',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editGame(game),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteGame(game.id),
                  ),
                ],
              ),
              onTap: () => _loadGame(game),
            );
          },
        );
      },
    );
  }

  String _formatGameParticipants(BeloteGame game) {
    if (game.gameMode == GameMode.twoVsTwo && game.teams.isNotEmpty) {
      return game.teams.map((team) {
        final memberNames = team.playerIds
            .map((id) => game.players.firstWhere((p) => p.id == id).name)
            .join(', ');
        return '${team.name} ($memberNames)';
      }).join(', ');
    }
    return game.players.map((p) => p.name).join(', ');
  }

  void _showNewGameDialogue() {
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

                _createNewGame(playerNames, gameMode, maxScore);
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewGame(List<String> playerNames, String gameMode, int maxScore) {
    final processedPlayerNames = playerNames.map((name) {
      return name.isEmpty ? 'Player ${playerNames.indexOf(name) + 1}' : name;
    }).toList();

    final players = processedPlayerNames.asMap().entries.map((entry) {
      return Player(id: (entry.key + 1).toString(), name: entry.value);
    }).toList();

    final teams = gameMode == GameMode.twoVsTwo
        ? [
            Team(
              id: '1',
              name: 'Team 1',
              playerIds: [players[0].id, players[1].id],
            ),
            Team(
              id: '2',
              name: 'Team 2',
              playerIds: [players[2].id, players[3].id],
            ),
          ]
        : <Team>[];

    final newGame = BeloteGame(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      players: players,
      rounds: [],
      createdAt: DateTime.now(),
      gameMode: gameMode,
      maxScore: maxScore,
      teams: teams,
    );

    StorageService.saveGame(newGame);

    _scaffoldKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Game created successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _loadGame(BeloteGame beloteGame) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(game: beloteGame)),
    );
  }

  void _editGame(BeloteGame game) {
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
                            ...team.playerIds.asMap().entries.map((entry) {
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
                  return Team(
                    id: team.id,
                    name: name.isEmpty ? team.name : name,
                    playerIds: team.playerIds,
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

                StorageService.saveGame(updateGame);
                Navigator.pop(context);

                _scaffoldKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Game updated successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteGame(String gameId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game?'),
        content: const Text('This cannot be undone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              StorageService.deleteGame(gameId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  //:TODO Import, export functionalities
  Future<void> _exportData() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _scaffoldKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        _scaffoldKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Connot access storage'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      final downloadsDir = Directory('${directory.path}/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final file = File(
        '${downloadsDir.path}/belote_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      final games = StorageService.getAllGames();
      final gamesJson = games.map((game) => game.toJson()).toList();
      await file.writeAsString(jsonEncode(gamesJson));

      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _importData() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _scaffoldKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        final List<dynamic> jsonList = jsonDecode(content);

        // Clear existing games
        await StorageService.gamesBox.clear();

        int successCount = 0;
        int errorCount = 0;

        for (var json in jsonList) {
          try {
            final game = _parseGameFromJson(json);
            if (game != null) {
              await StorageService.saveGame(game);
              successCount++;
            } else {
              errorCount++;
            }
          } catch (e) {
            errorCount++;
            debugPrint('Failed to parse game: $e');
          }
        }

        _scaffoldKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
              'Import completed: $successCount successful, $errorCount failed',
            ),
          ),
        );
      } else {
        // User cancelled file selection
        _scaffoldKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Import cancelled')),
        );
      }
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  BeloteGame? _parseGameFromJson(dynamic json) {
    try {
      return BeloteGame(
        id:
            json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        players:
            (json['players'] as List?)?.map((playerJson) {
              return Player(
                id: playerJson['id']?.toString() ?? '0',
                name: playerJson['name']?.toString() ?? 'Unknown',
              );
            }).toList() ??
            [],
        rounds:
            (json['rounds'] as List?)?.map((roundJson) {
              return Round(
                number: roundJson['number'] as int? ?? 0,
                scores: Map<String, int>.from(roundJson['scores'] ?? {}),
              );
            }).toList() ??
            [],
        createdAt: DateTime.parse(
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        ),
        gameMode: json['gameMode']?.toString() ?? GameMode.twoPlayers,
        maxScore: json['maxScore'] as int? ?? 101,
        winnerId: json['winnerId'].toString(),
        teams:
            (json['teams'] as List?)?.map((teamJson) {
              return Team(
                id: teamJson['id']?.toString() ?? '0',
                name: teamJson['name']?.toString() ?? 'Team',
                playerIds: List<String>.from(teamJson['playerIds'] ?? []),
              );
            }).toList() ??
            [],
      );
    } catch (e) {
      debugPrint('Error parsing game: $e');
      return null;
    }
  }
}
