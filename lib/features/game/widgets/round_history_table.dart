import 'package:belote_notes/models/game.dart';
import 'package:flutter/material.dart';

class RoundHistoryTable extends StatelessWidget {
  final List<Round> rounds;
  final List<({String id, String name})> scoringEntities;
  final Map<String, int> totalScores;
  final void Function(int roundNumber) onDeleteRound;

  const RoundHistoryTable({
    super.key,
    required this.rounds,
    required this.scoringEntities,
    required this.totalScores,
    required this.onDeleteRound,
  });

  static String displayScoreFor(int score) {
    if (score == -100) {
      return 'B1';
    } else if (score == -200) {
      return 'B2';
    } else if (score == -300) {
      return 'B3';
    }
    return score.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (rounds.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No rounds yet. Start by entering the total round points below.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              Colors.blue.withValues(alpha: 0.1),
            ),
            border: TableBorder.all(color: Colors.grey.shade300),
            columns: [
              const DataColumn(label: Text('R')),
              ...scoringEntities.map((e) => DataColumn(label: Text(e.name))),
              const DataColumn(label: Text('T')),
              const DataColumn(label: Text('')),
            ],
            rows: [
              ...rounds.map((round) {
                final totalPoints = round.scores.values
                    .where((score) => score > 0)
                    .fold(0, (sum, score) => sum + score);

                return DataRow(
                  cells: [
                    DataCell(Text(round.number.toString())),
                    ...scoringEntities.map((entity) {
                      final score = round.scores[entity.id] ?? 0;
                      return DataCell(Text(displayScoreFor(score)));
                    }),
                    DataCell(Text(totalPoints.toString())),
                    DataCell(
                      IconButton(
                        onPressed: () => onDeleteRound(round.number),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // Add a bottom "total row"
              DataRow(
                color: WidgetStateProperty.all(
                  Colors.grey.withValues(alpha: 0.1),
                ),
                cells: [
                  const DataCell(
                    Text('T', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...scoringEntities.map((e) {
                    final entityTotal = totalScores[e.id] ?? 0;
                    return DataCell(
                      Text(
                        entityTotal.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                  DataCell(
                    Text(
                      totalScores.values
                          .map(
                            (s) => s < 0 ? 0 : s,
                          ) // negative totals count as 0
                          .fold(0, (a, b) => a + b)
                          .toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const DataCell(SizedBox.shrink()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
