import 'package:belote_notes/features/game/game_screen.dart';
import 'package:belote_notes/features/home/dialogs/delete_game_dialog.dart';
import 'package:belote_notes/features/home/dialogs/edit_game_dialog.dart';
import 'package:belote_notes/features/home/dialogs/new_game_dialog.dart';
import 'package:belote_notes/features/home/widgets/game_list.dart';
import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/services/game_backup_service.dart';
import 'package:belote_notes/services/storage_service.dart';
import 'package:flutter/material.dart';

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
        body: GameList(
          onEditGame: _editGame,
          onDeleteGame: _deleteGame,
          onLoadGame: _loadGame,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showNewGameDialog(context, onCreate: _createNewGame),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _createNewGame(List<String> names, String gameMode, int maxScore) {
    // For 2v2, `names` are the two team names; individual player identity
    // doesn't matter yet, so members are auto-assigned placeholders until
    // per-player rosters exist.
    final players = gameMode == GameMode.twoVsTwo
        ? List.generate(
            4,
            (i) => Player(id: (i + 1).toString(), name: 'Player ${i + 1}'),
          )
        : names.asMap().entries.map((entry) {
            return Player(id: (entry.key + 1).toString(), name: entry.value);
          }).toList();

    final teams = gameMode == GameMode.twoVsTwo
        ? [
            Team(
              id: '1',
              name: names[0],
              playerIds: [players[0].id, players[1].id],
            ),
            Team(
              id: '2',
              name: names[1],
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
    showEditGameDialog(
      context,
      game,
      onSave: (updateGame) {
        StorageService.saveGame(updateGame);

        _scaffoldKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Game updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _deleteGame(String gameId) {
    showDeleteGameDialog(
      context,
      onConfirm: () => StorageService.deleteGame(gameId),
    );
  }

  Future<void> _exportData() async {
    final result = await GameBackupService.exportGames();
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(result.message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _importData() async {
    final result = await GameBackupService.importGames();
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(result.message), duration: const Duration(seconds: 2)),
    );
  }
}
