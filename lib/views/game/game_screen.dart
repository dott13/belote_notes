import 'package:belote_notes/models/game.dart';
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
  String _currentInputs = '0';
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
                _currentInputs =
                    _currentRoundScores[player.id]?.toString() ?? '0';
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalculator() {
    //:TODO make calculator
    return Card();
  }

  Widget _buildCalculatorButton(String label) {
    //:TODO make the adding button(auto calculating)
    return ElevatedButton(onPressed: onPressed, child: child);
  }

  Widget _buildRoundsList() {
    //:TODO make the expandable list
  }

  void _saveGame() {}
}
