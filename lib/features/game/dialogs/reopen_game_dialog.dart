import 'package:flutter/material.dart';

Future<void> showReopenGameDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reopen Game?'),
      content: const Text('This will allow you to continue playing'),
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
          child: const Text('Reopen'),
        ),
      ],
    ),
  );
}
