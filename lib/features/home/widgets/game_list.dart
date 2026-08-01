import 'package:belote_notes/features/home/widgets/game_list_tile.dart';
import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GameList extends StatelessWidget {
  final void Function(BeloteGame game) onEditGame;
  final void Function(String gameId) onDeleteGame;
  final void Function(BeloteGame game) onLoadGame;

  const GameList({
    super.key,
    required this.onEditGame,
    required this.onDeleteGame,
    required this.onLoadGame,
  });

  @override
  Widget build(BuildContext context) {
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
            return GameListTile(
              game: game,
              index: index,
              onEdit: () => onEditGame(game),
              onDelete: () => onDeleteGame(game.id),
              onTap: () => onLoadGame(game),
            );
          },
        );
      },
    );
  }
}
