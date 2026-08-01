import 'package:flutter/material.dart';

class PlayerSelector extends StatelessWidget {
  final int totalRoundPoints;
  final List<({String id, String name})> scoringEntities;
  final String selectedPlayerId;
  final String Function(String entityId) getDisplayScore;
  final void Function(String entityId) onSelectEntity;

  const PlayerSelector({
    super.key,
    required this.totalRoundPoints,
    required this.scoringEntities,
    required this.selectedPlayerId,
    required this.getDisplayScore,
    required this.onSelectEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            'Total Round Points: $totalRoundPoints',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: scoringEntities.map((entity) {
              final isSelected = selectedPlayerId == entity.id;
              final displayScore = getDisplayScore(entity.id);

              return ChoiceChip(
                label: Text('${entity.name} ($displayScore)'),
                selected: isSelected,
                onSelected: (selected) => onSelectEntity(entity.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
