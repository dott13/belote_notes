import 'package:flutter/material.dart';

class WinTally extends StatelessWidget {
  final List<({String id, String name})> scoringEntities;
  final Map<String, int> wins;

  const WinTally({super.key, required this.scoringEntities, required this.wins});

  @override
  Widget build(BuildContext context) {
    if (wins.values.every((count) => count == 0)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        children: scoringEntities.map((entity) {
          final count = wins[entity.id] ?? 0;
          return Text(
            '${entity.name}: $count',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }).toList(),
      ),
    );
  }
}
