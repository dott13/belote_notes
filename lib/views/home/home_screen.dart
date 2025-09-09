import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/services/storage_service.dart';
import 'package:belote_notes/views/home/game_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Belote Notes'),
        actions: [
          IconButton(onPressed: _exportData, icon: const Icon(Icons.upload)),
          IconButton(onPressed: _importData, icon: const Icon(Icons.download)),
        ],
      ),
      body: _buildGameList(),
      floatingActionButton: FloatingActionButton(onPressed: _showNewGameDialogue, child: const Icon(Icons.add)),
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
                trailing: IconButton(onPressed: () => _deleteGame(game.id), icon: const Icon(Icons.delete)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            _createNewGame(
              nameController1.text.isEmpty ? 'We': nameController1.text,
              nameController2.text.isEmpty ? 'You': nameController2.text,
            );
          },
            child: const Text('Create')
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
    Navigator.push(context, 
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
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              StorageService.deleteGame(gameId);
              Navigator.pop(context);
            }, 
            child: const Text('Delete')
          ),
        ], 
      ),
    );
  }


  //:TODO Import, export functionalities

}