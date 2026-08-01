import 'package:flutter/material.dart';

class MaxScoreIndicator extends StatelessWidget {
  final int maxScore;
  final List<({String id, String name})> scoringEntities;
  final Map<String, int> totalScores;

  const MaxScoreIndicator({
    super.key,
    required this.maxScore,
    required this.scoringEntities,
    required this.totalScores,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Target: $maxScore',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ...scoringEntities.map((entity) {
            final score = totalScores[entity.id] ?? 0;
            final isLeading = score >= maxScore;
            return Text(
              '${entity.name}: $score',
              style: TextStyle(
                fontWeight: isLeading ? FontWeight.bold : FontWeight.normal,
                color: isLeading ? Colors.green : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}
