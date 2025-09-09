import 'dart:convert';
import 'dart:io';

import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/services/storage_service.dart';
import 'package:belote_notes/views/home/game_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

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
        key: _scaffoldKey,
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
                '${game.players.map((p) => p.name).join(' vs ')}\n'
                '${game.createdAt.toString().substring(0, 16)}',
              ),
              trailing: IconButton(
                onPressed: () => _deleteGame(game.id),
                icon: const Icon(Icons.delete),
              ),
              onTap: () => _loadGame(game),
            );
          },
        );
      },
    );
  }

  void _showNewGameDialogue() {
    final nameController1 = TextEditingController();
    final nameController2 = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Game'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController1,
              decoration: const InputDecoration(labelText: 'Team 1 Players'),
            ),
            TextField(
              controller: nameController2,
              decoration: const InputDecoration(labelText: 'Team 2 Players'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _createNewGame(
                nameController1.text.isEmpty ? 'We' : nameController1.text,
                nameController2.text.isEmpty ? 'You' : nameController2.text,
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createNewGame(String player1, String player2) {
    final newGame = BeloteGame(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      players: [
        Player(id: '1', name: player1),
        Player(id: '2', name: player2),
      ],
      rounds: [],
      createdAt: DateTime.now(),
    );

    StorageService.saveGame(newGame);
  }

  void _loadGame(BeloteGame beloteGame) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(game: beloteGame)),
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
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/belote_backup_${DateTime.now().millisecondsSinceEpoch}.json',
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);

        // Clear existing games
        await StorageService.gamesBox.clear();

        // Import new games
        for (var json in jsonList) {
          final game = BeloteGame.fromJson(json);
          await StorageService.saveGame(game);
        }

        _scaffoldKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Import successful')),
        );
      }
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
}
