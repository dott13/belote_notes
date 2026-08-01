import 'package:flutter/material.dart';

Future<void> showPlayAgainDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Play Again?'),
      content: const Text(
        'This starts a fresh round with the same teams. The win tally is kept.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text('Play Again'),
        ),
      ],
    ),
  );
}
