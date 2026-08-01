import 'package:flutter/material.dart';

class ScoreCalculator extends StatelessWidget {
  final bool isSettingTotal;
  final String currentInput;
  final String selectedEntityDisplayScore;
  final String selectedEntityName;
  final bool canSaveRound;
  final bool isNegativeEntry;
  final void Function(String button) onButtonPressed;
  final VoidCallback onSetTotalPoints;
  final VoidCallback onResetRound;
  final VoidCallback onAddRound;

  const ScoreCalculator({
    super.key,
    required this.isSettingTotal,
    required this.currentInput,
    required this.selectedEntityDisplayScore,
    required this.selectedEntityName,
    required this.canSaveRound,
    required this.isNegativeEntry,
    required this.onButtonPressed,
    required this.onSetTotalPoints,
    required this.onResetRound,
    required this.onAddRound,
  });

  Widget _buildCalculatorButton(String label) {
    if (label.isEmpty) {
      return Container(); // Empty space
    }

    Color buttonColor = Colors.blue;
    if (label == 'C' || label == 'Del') {
      buttonColor = Colors.red;
    } else if (label == 'B') {
      buttonColor = Colors.purple;
    } else if (label == '±') {
      buttonColor = isNegativeEntry ? Colors.deepOrange : Colors.orange;
    }

    return ElevatedButton(
      onPressed: () => onButtonPressed(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.all(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = isSettingTotal
        ? 'Total Round Points: $currentInput'
        : '$selectedEntityName: $selectedEntityDisplayScore';

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              displayText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              childAspectRatio: 1.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildCalculatorButton('7'),
                _buildCalculatorButton('8'),
                _buildCalculatorButton('9'),
                _buildCalculatorButton('C'),
                _buildCalculatorButton('4'),
                _buildCalculatorButton('5'),
                _buildCalculatorButton('6'),
                if (!isSettingTotal) _buildCalculatorButton('B'),
                if (isSettingTotal) _buildCalculatorButton(''),
                _buildCalculatorButton('1'),
                _buildCalculatorButton('2'),
                _buildCalculatorButton('3'),
                if (!isSettingTotal) _buildCalculatorButton('±'),
                if (isSettingTotal) _buildCalculatorButton(''),
                _buildCalculatorButton('0'),
                _buildCalculatorButton('00'),
                _buildCalculatorButton('Del'),
                _buildCalculatorButton(''),
              ],
            ),

            const SizedBox(height: 16),

            if (isSettingTotal)
              ElevatedButton(
                onPressed: onSetTotalPoints,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Set Total Points',
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onResetRound,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Text('Reset Round'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canSaveRound ? onAddRound : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Text('Save Round'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
