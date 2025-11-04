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
  final Map<String, int> _gameBolteCounts =
      {}; // Track total boltes across entire game
  String _currentInput = '0';
  String _selectedPlayerId = '';
  int _totalRoundPoints = 0;
  bool _isSettingTotal = true;

  @override
  void initState() {
    super.initState();
    _currentGame = widget.game;

    // Initialize scores
    for (var player in _currentGame.players) {
      _currentRoundScores[player.id] = 0;
    }

    // Calculate bolte counts from game history
    _calculateBolteCounts();

    if (_currentGame.players.isNotEmpty) {
      _selectedPlayerId = _currentGame.players.first.id;
    }
  }

  void _calculateBolteCounts() {
    // Reset counts
    for (var player in _currentGame.players) {
      _gameBolteCounts[player.id] = 0;
    }

    // Count boltes from all rounds
    for (var round in _currentGame.rounds) {
      for (var player in _currentGame.players) {
        final score = round.scores[player.id] ?? 0;
        // Check if this was a bolte (stored as -100, -200, -300)
        if (score == -100) {
          _gameBolteCounts[player.id] = (_gameBolteCounts[player.id] ?? 0) + 1;
        } else if (score == -200) {
          _gameBolteCounts[player.id] = (_gameBolteCounts[player.id] ?? 0) + 1;
        } else if (score == -300) {
          _gameBolteCounts[player.id] = (_gameBolteCounts[player.id] ?? 0) + 1;
        }
        // -10 after B3 resets the count (it's stored as -10, not -300)
      }
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
            icon: const Icon(Icons.save),
            tooltip: 'Save Game',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRoundList(),
          _buildPlayerSelector(),
          _buildCalculator(),
        ],
      ),
    );
  }

  String _getDisplayScore(String playerId) {
    final score = _currentRoundScores[playerId] ?? 0;

    // Check for bolte markers
    if (score == -100) {
      return 'B1';
    } else if (score == -200) {
      return 'B2';
    } else if (score == -300) {
      return 'B3';
    } else if (score == -10) {
      return '-10';
    }

    return score.toString();
  }

  Widget _buildRoundList() {
    final players = _currentGame.players;

    if (_currentGame.rounds.isEmpty) {
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

    // Compute total scores
    final totalScores = <String, int>{};
    for (var player in players) {
      totalScores[player.id] = _calculateTotalScore(player.id);
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
              ...players.map((p) => DataColumn(label: Text(p.name))),
              const DataColumn(label: Text('T')),
              const DataColumn(label: Text('')),
            ],
            rows: [
              ..._currentGame.rounds.map((round) {
                final totalPoints = round.scores.values
                    .where((score) => score > 0)
                    .fold(0, (sum, score) => sum + score);

                return DataRow(
                  cells: [
                    DataCell(Text(round.number.toString())),
                    ...players.map((player) {
                      final score = round.scores[player.id] ?? 0;
                      String displayScore;
                      if (score == -10) {
                        displayScore = '-10';
                      } else if (score == -100) {
                        displayScore = 'B1';
                      } else if (score == -200) {
                        displayScore = 'B2';
                      } else if (score == -300) {
                        displayScore = 'B3';
                      } else {
                        displayScore = score.toString();
                      }
                      return DataCell(Text(displayScore));
                    }),
                    DataCell(Text(totalPoints.toString())),
                    DataCell(
                      IconButton(
                        onPressed: () => _deleteRound(round.number),
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
                  ...players.map((p) {
                    final playerTotal = totalScores[p.id] ?? 0;
                    return DataCell(
                      Text(
                        playerTotal.toString(),
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

  Widget _buildPlayerSelector() {
    if (_isSettingTotal) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            'Total Round Points: $_totalRoundPoints',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _currentGame.players.map((player) {
              final isSelected = _selectedPlayerId == player.id;
              final displayScore = _getDisplayScore(player.id);

              return ChoiceChip(
                label: Text('${player.name} ($displayScore)'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPlayerId = player.id;
                    final score = _currentRoundScores[player.id] ?? 0;
                    _currentInput = score >= 0 ? score.toString() : '0';
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculator() {
    String displayText;
    if (_isSettingTotal) {
      displayText = 'Total Round Points: $_currentInput';
    } else {
      final displayScore = _getDisplayScore(_selectedPlayerId);
      displayText = '${_getSelectedPlayer()?.name ?? "Player"}: $displayScore';
    }

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
                if (!_isSettingTotal) _buildCalculatorButton('B'),
                if (_isSettingTotal) _buildCalculatorButton(''),
                _buildCalculatorButton('1'),
                _buildCalculatorButton('2'),
                _buildCalculatorButton('3'),
                if (!_isSettingTotal) _buildCalculatorButton('-10'),
                if (_isSettingTotal) _buildCalculatorButton(''),
                _buildCalculatorButton('0'),
                _buildCalculatorButton('00'),
                _buildCalculatorButton('Del'),
                _buildCalculatorButton(''),
              ],
            ),

            const SizedBox(height: 16),

            if (_isSettingTotal)
              ElevatedButton(
                onPressed: _setTotalPoints,
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
                      onPressed: _resetRound,
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
                      onPressed: _canSaveRound() ? _addRound : null,
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

  Widget _buildCalculatorButton(String label) {
    if (label.isEmpty) {
      return Container(); // Empty space
    }

    Color buttonColor = Colors.blue;
    if (label == 'C' || label == 'Del') {
      buttonColor = Colors.red;
    } else if (label == 'B') {
      buttonColor = Colors.purple;
    } else if (label == '-10') {
      buttonColor = Colors.orange;
    }

    return ElevatedButton(
      onPressed: () => _onCalculatorButtonPressed(label),
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

  void _onCalculatorButtonPressed(String button) {
    setState(() {
      if (_isSettingTotal) {
        _handleTotalInput(button);
      } else {
        _handlePlayerInput(button);
      }
    });
  }

  void _handleTotalInput(String button) {
    if (button == 'C') {
      _currentInput = '0';
    } else if (button == 'Del') {
      if (_currentInput.length > 1) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      } else {
        _currentInput = '0';
      }
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
  }

  void _handlePlayerInput(String button) {
    if (button == 'B') {
      // Give player a "Bolte" (0 points shown as B1, B2, B3)
      final currentGameBoltes = _gameBolteCounts[_selectedPlayerId] ?? 0;

      if (currentGameBoltes < 2) {
        // B1 or B2 - store as -100, -200
        final newBolteCount = currentGameBoltes + 1;
        _currentRoundScores[_selectedPlayerId] = -100 * newBolteCount;
        _currentInput = '0';
      } else {
        // B3 - player gets -10 points and bolte count resets
        _currentRoundScores[_selectedPlayerId] = -10;
        _currentInput = '0';
      }
      _calculateRemainingScores();
    } else if (button == '-10') {
      // Give player -10 points (for going out with 0 actual game points)
      _currentRoundScores[_selectedPlayerId] = -10;
      _currentInput = '0';
      _calculateRemainingScores();
    } else if (button == 'C') {
      _currentInput = '0';
      _currentRoundScores[_selectedPlayerId] = 0;
      _calculateRemainingScores();
    } else if (button == 'Del') {
      if (_currentInput.length > 1) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      } else {
        _currentInput = '0';
      }
      _updateCurrentScore();
    } else if (button == '00') {
      if (_currentInput == '0') {
        _currentInput = '0';
      } else {
        _currentInput += '00';
      }
      _updateCurrentScore();
    } else {
      // Number button
      if (_currentInput == '0') {
        _currentInput = button;
      } else {
        _currentInput += button;
      }
      _updateCurrentScore();
    }
  }

  void _updateCurrentScore() {
    final score = int.tryParse(_currentInput) ?? 0;
    _currentRoundScores[_selectedPlayerId] = score;
    _calculateRemainingScores();
  }

  void _calculateRemainingScores() {
    // Calculate total assigned (only positive scores count toward the total)
    final assignedTotal = _currentRoundScores.values
        .where((score) => score > 0)
        .fold(0, (sum, score) => sum + score);
    final remaining = _totalRoundPoints - assignedTotal;

    if (_currentGame.players.length == 2) {
      final otherPlayer = _currentGame.players.firstWhere(
        (p) => p.id != _selectedPlayerId,
      );
      // Only auto-assign if the other player doesn't have special scores
      if (_currentRoundScores[otherPlayer.id]! >= 0) {
        _currentRoundScores[otherPlayer.id] = remaining;
      }
    } else if (_currentGame.players.length == 3) {
      // Count players with positive scores
      final playersWithPositiveScores = _currentRoundScores.entries
          .where((entry) => entry.value > 0)
          .length;

      if (playersWithPositiveScores == 2) {
        // Find the player without a positive score and assign remaining
        final playerWithoutScore = _currentGame.players.firstWhere(
          (player) => (_currentRoundScores[player.id] ?? 0) <= 0,
          orElse: () => _currentGame.players.first,
        );

        // Only auto-assign if they don't have a special score
        if (_currentRoundScores[playerWithoutScore.id]! == 0) {
          _currentRoundScores[playerWithoutScore.id] = remaining;
        }
      }
    }
  }

  void _setTotalPoints() {
    final total = int.tryParse(_currentInput) ?? 0;
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid total points value'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _totalRoundPoints = total;
      _isSettingTotal = false;
      _currentInput = '0';

      for (var player in _currentGame.players) {
        _currentRoundScores[player.id] = 0;
      }
    });
  }

  bool _canSaveRound() {
    if (_totalRoundPoints <= 0) return false;

    // Calculate total assigned (only positive scores)
    final totalAssigned = _currentRoundScores.values
        .where((score) => score > 0)
        .fold(0, (sum, score) => sum + score);

    return totalAssigned == _totalRoundPoints;
  }

  Player? _getSelectedPlayer() {
    if (_selectedPlayerId.isEmpty) return null;
    return _currentGame.players.firstWhere(
      (player) => player.id == _selectedPlayerId,
      orElse: () => _currentGame.players.first,
    );
  }

  int _calculateTotalScore(String playerId) {
    return _currentGame.rounds.fold(0, (total, round) {
      final score = round.scores[playerId] ?? 0;
      if (score <= -100) return total; // This was a bolte (B1, B2)
      return total + score; // This includes -10 and positive scores
    });
  }

  void _addRound() {
    if (!_canSaveRound()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Points must add up to the total round points'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final roundNumber = _currentGame.rounds.length + 1;

    setState(() {
      _currentGame.rounds.add(
        Round(
          number: roundNumber,
          scores: Map<String, int>.from(_currentRoundScores),
        ),
      );

      // Recalculate bolte counts after adding round
      _calculateBolteCounts();
      _resetRound();
    });

    _saveGame();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Round saved!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _resetRound() {
    setState(() {
      _isSettingTotal = true;
      _totalRoundPoints = 0;
      _currentInput = '0';

      for (var player in _currentGame.players) {
        _currentRoundScores[player.id] = 0;
      }
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

                // Recalculate bolte counts after deletion
                _calculateBolteCounts();
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
