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
            return ListTile(
              title: Text('Game ${index + 1}'),
              subtitle: Text(
                '${DateFormatter.formatDate(game.createdAt)}\n'
                '${game.gameMode}: ${game.players.map((p) => p.name).join(', ')}',
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

  void _showNewGameDialogue() {
    final controllers = List.generate(3, (_) => TextEditingController());
    String gameMode = '2 players/teams';
    int playerCount = 2;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Game'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: gameMode,
                  items: [
                    DropdownMenuItem(
                      value: '2 players/teams',
                      child: const Text('2 Players/Teams (Classic)'),
                    ),
                    DropdownMenuItem(
                      value: '3 players',
                      child: const Text('3 Players (Cut-throat)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      gameMode = value!;
                      playerCount = value == '2 players/teams' ? 2 : 3;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Number of Players',
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(playerCount, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        labelText: gameMode == '2 players/teams'
                            ? index == 0
                                  ? 'Team 1 Name'
                                  : 'Team 2 Name'
                            : 'Player ${index + 1} Name',
                        hintText: gameMode == '2 players/teams'
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final playerNames = <String>[];
                for (var i = 0; i < playerCount; i++) {
                  final name = controllers[i].text.trim();
                  if (gameMode == '2 players/teams') {
                    playerNames.add(name.isEmpty ? 'Team ${i + 1}' : name);
                  } else {
                    playerNames.add(name.isEmpty ? 'Player ${i + 1}' : name);
                  }
                }

                _createNewGame(playerNames, gameMode);
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewGame(List<String> playerNames, String gameMode) {
    final processedPlayerNames = playerNames.map((name) {
      return name.isEmpty ? 'Player ${playerNames.indexOf(name) + 1}' : name;
    }).toList();

    final newGame = BeloteGame(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      players: processedPlayerNames.asMap().entries.map((entry) {
        return Player(id: (entry.key + 1).toString(), name: entry.value);
      }).toList(),
      rounds: [],
      createdAt: DateTime.now(),
      gameMode: gameMode,
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Game'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Game Name: ${game.gameMode}'),
              Text('Created: ${DateFormatter.formatDate(game.createdAt)}'),
              const SizedBox(height: 16),
              ...controllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: game.gameMode == '2 players/teams'
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

                if (game.gameMode == '2 players/teams') {
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

              final updateGame = BeloteGame(
                id: game.id,
                players: updatedPlayers,
                rounds: game.rounds,
                createdAt: game.createdAt,
                gameMode: game.gameMode,
              );

              StorageService.saveGame(updateGame);
              Navigator.pop(context);

              _scaffoldKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Text('Game created successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
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

      final result = await FilePicker.platform.pickFiles(
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
        gameMode: json['gameMode']?.toString() ?? '2 players/teams',
      );
    } catch (e) {
      debugPrint('Error parsing game: $e');
      return null;
    }
  }
}
