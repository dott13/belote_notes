import 'package:belote_notes/models/game.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget{
  final BeloteGame game;

  const GameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game ${game.createdAt.toString().substring(0, 10)}'),
      ),
      body: Column(
        children: [
          Expanded(child: ListView.builder(
            itemCount: game.rounds.length,
            itemBuilder: (context, index) {
              final round = game.rounds[index];
              return ListTile(
                title: Text('Round ${round.number}'),
                subtitle: Text(round.scores.toString()),
              );
            },
          ))
        ],
      )
      //:TODO add controls here
    );
  }
}