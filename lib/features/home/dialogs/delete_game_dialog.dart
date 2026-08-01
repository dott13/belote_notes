import 'package:flutter/material.dart';

Future<void> showDeleteGameDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
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
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
