import 'package:flutter/material.dart';

Future<void> showDeleteRoundDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Round?'),
      content: const Text('This will remove the round and update scores.'),
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
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
