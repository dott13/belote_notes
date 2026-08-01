import 'package:flutter/material.dart';

Future<void> showMultipleWinnersDialog(
  BuildContext context, {
  required int maxScore,
  required List<({String id, String name})> playersAboveMax,
  required Map<String, int> totalScores,
  required void Function(String winnerId) onDeclareWinner,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Multiple players passed $maxScore'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The following players have reached the maximum score:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...playersAboveMax.map((player) {
            return Text('${player.name}: ${totalScores[player.id]} points');
          }),
          const SizedBox(height: 16),
          const Text("What would you like to do?"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Continue Playing'),
        ),
        ...playersAboveMax.map((player) {
          return TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDeclareWinner(player.id);
            },
            child: Text('${player.name} Wins'),
          );
        }),
      ],
    ),
  );
}
