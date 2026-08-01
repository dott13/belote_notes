import 'package:flutter/material.dart';

Future<void> showUndoWinDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Undo Win?'),
      content: const Text(
        'This returns to the game so you can keep playing, and removes '
        'this win from the series tally.',
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
          child: const Text('Undo'),
        ),
      ],
    ),
  );
}
