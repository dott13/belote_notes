import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/services/storage_service.dart';
import 'package:belote_notes/utils/date_formatter.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final BeloteGame game;

  const GameScreen({super.key, required this.game});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BeloteGame _currentGame;
  final Map<String, int> _currentRoundScores = {};
  String _currentInput = '0';
  String _selectedPlayerId = '';

  @override
  void initState() {
    super.initState();
    _currentGame = widget.game;

    for (var player in _currentGame.players) {
      _currentRoundScores[player.id] = 0;
    }

    if (_currentGame.players.isNotEmpty) {
      _selectedPlayerId = _currentGame.players.first.id;
    }
  }

  @override
  void dispose() {
    _saveGame();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Game - ${DateFormatter.formatDate(_currentGame.createdAt)}',
        ),
        actions: [
          IconButton(
            onPressed: _saveGame,
            icon: Icon(Icons.save),
            tooltip: 'Save Game',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildScoreBoard(),
          _buildPlayerSelector(),
          _buildCalculator(),
          _buildRoundList(),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Total Scores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _currentGame.players.map((player) {
                final totalScore = _calculateTotalScore(player.id);
                return Column(
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _selectedPlayerId == player.id
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedPlayerId == player.id
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                    Text(
                      totalScore.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: _currentGame.players.map((player) {
          final isSelected = _selectedPlayerId == player.id;
          return ChoiceChip(
            label: Text(player.name),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedPlayerId = player.id;
                _currentInput =
                    _currentRoundScores[player.id]?.toString() ?? '0';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalculator() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //Display Current Score
            Text(
              '${_getSelectedPlayer()?.name ?? "Player"}: $_currentInput',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 1.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildCalculatorButton('7'),
                _buildCalculatorButton('8'),
                _buildCalculatorButton('9'),
                _buildCalculatorButton('4'),
                _buildCalculatorButton('5'),
                _buildCalculatorButton('6'),
                _buildCalculatorButton('1'),
                _buildCalculatorButton('2'),
                _buildCalculatorButton('3'),
                _buildCalculatorButton('0'),
                _buildCalculatorButton('00'),
                _buildCalculatorButton('C'),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _clearAllScores,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Clear All'),
                ),
                ElevatedButton(
                  onPressed: _addRound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Save Round'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorButton(String label) {
    return ElevatedButton(
      onPressed: () => _onCalculatorButtonPressed(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: label == 'C' ? Colors.red : Colors.blue,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRoundList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _currentGame.rounds.length,
        itemBuilder: (context, index) {
          final round = _currentGame.rounds[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text('Round ${round.number}'),
              subtitle: Text(
                _currentGame.players
                    .map((player) {
                      final score = round.scores[player.id] ?? 0;
                      return '${player.name}: $score';
                    })
                    .join(' | '),
              ),
              trailing: IconButton(
                onPressed: () => _deleteRound(round.number),
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                tooltip: 'Delete Round',
              ),
            ),
          );
        },
      ),
    );
  }

  void _onCalculatorButtonPressed(String button) {
    setState(() {
      if (button == 'C') {
        _currentInput = '0';
      } else if (button == '00') {
        if (_currentInput == '0') {
          _currentInput = '0';
        } else {
          _currentInput += '00';
        }
      } else {
        if (_currentInput == '0') {
          _currentInput = button;
        } else {
          _currentInput += button;
        }
      }
    });
  }

  Player? _getSelectedPlayer() {
    return _currentGame.players.firstWhere(
      (player) => player.id == _selectedPlayerId,
      orElse: () => _currentGame.players.first,
    );
  }

  int _calculateTotalScore(String playerId) {
    return _currentGame.rounds.fold(0, (total, round) {
      return total + (round.scores[playerId] ?? 0);
    });
  }

  void _addRound() {
    final hasScores = _currentRoundScores.values.any((score) => score > 0);

    if (!hasScores) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter scores for at least one player'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final roundNumber = _currentGame.rounds.length;

    setState(() {
      _currentGame.rounds.add(
        Round(
          number: roundNumber,
          scores: Map<String, int>.from(_currentRoundScores),
        ),
      );

      for (var player in _currentGame.players) {
        _currentRoundScores[player.id] = 0;
        _currentInput = '0';
      }
    });

    _saveGame();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Round saved!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearAllScores() {
    setState(() {
      for (var player in _currentGame.players) {
        _currentRoundScores[player.id] = 0;
      }
      _currentInput = '0';
    });
  }

  void _deleteRound(int roundNumber) {
    showDialog(
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
              setState(() {
                _currentGame.rounds.removeWhere(
                  (round) => round.number == roundNumber,
                );

                for (var i = 0; i < _currentGame.rounds.length; i++) {
                  _currentGame.rounds[i] = Round(
                    number: i + 1,
                    scores: _currentGame.rounds[i].scores,
                  );
                }
              });

              _saveGame();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveGame() {
    StorageService.saveGame(_currentGame);
  }
}
