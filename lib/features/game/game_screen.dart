import 'package:belote_notes/features/game/dialogs/delete_round_dialog.dart';
import 'package:belote_notes/features/game/dialogs/multiple_winners_dialog.dart';
import 'package:belote_notes/features/game/finished_game_screen.dart';
import 'package:belote_notes/features/game/widgets/max_score_indicator.dart';
import 'package:belote_notes/features/game/widgets/player_selector.dart';
import 'package:belote_notes/features/game/widgets/round_history_table.dart';
import 'package:belote_notes/features/game/widgets/score_calculator.dart';
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
  final Set<String> _manuallyEnteredPlayerIds =
      {}; // Players whose score this round was typed, not auto-filled
  String _currentInput = '0';
  String _selectedPlayerId = '';
  int _totalRoundPoints = 0;
  bool _isSettingTotal = true;

  List<({String id, String name})> get _scoringEntities =>
      _currentGame.gameMode == GameMode.twoVsTwo
          ? _currentGame.teams.map((t) => (id: t.id, name: t.name)).toList()
          : _currentGame.players.map((p) => (id: p.id, name: p.name)).toList();

  @override
  void initState() {
    super.initState();
    _currentGame = widget.game;

    // Initialize scores
    for (var entity in _scoringEntities) {
      _currentRoundScores[entity.id] = 0;
    }

    // Calculate bolte counts from game history
    _calculateBolteCounts();

    if (_scoringEntities.isNotEmpty) {
      _selectedPlayerId = _scoringEntities.first.id;
    }
  }

  void _calculateBolteCounts() {
    // Reset counts
    for (var entity in _scoringEntities) {
      _gameBolteCounts[entity.id] = 0;
    }

    // Count boltes from all rounds
    for (var round in _currentGame.rounds) {
      for (var entity in _scoringEntities) {
        final score = round.scores[entity.id] ?? 0;
        // Check if this was a bolte (stored as -100, -200, -300)
        if (score == -100) {
          _gameBolteCounts[entity.id] = (_gameBolteCounts[entity.id] ?? 0) + 1;
        } else if (score == -200) {
          _gameBolteCounts[entity.id] = (_gameBolteCounts[entity.id] ?? 0) + 1;
        } else if (score == -300) {
          _gameBolteCounts[entity.id] = (_gameBolteCounts[entity.id] ?? 0) + 1;
        }
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
    if (_currentGame.winnerId != null) {
      return _buildFinishedGameScreen();
    }
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
          _buildMaxScoreIndicator(),
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
    final scoringEntities = _scoringEntities;
    final totalScores = <String, int>{};
    for (var entity in scoringEntities) {
      totalScores[entity.id] = _calculateTotalScore(entity.id);
    }

    return RoundHistoryTable(
      rounds: _currentGame.rounds,
      scoringEntities: scoringEntities,
      totalScores: totalScores,
      onDeleteRound: _deleteRound,
    );
  }

  Widget _buildPlayerSelector() {
    if (_isSettingTotal) {
      return Container();
    }

    return PlayerSelector(
      totalRoundPoints: _totalRoundPoints,
      scoringEntities: _scoringEntities,
      selectedPlayerId: _selectedPlayerId,
      getDisplayScore: _getDisplayScore,
      onSelectEntity: _selectEntity,
    );
  }

  void _selectEntity(String entityId) {
    setState(() {
      _selectedPlayerId = entityId;
      final score = _currentRoundScores[entityId] ?? 0;
      _currentInput = score >= 0 ? score.toString() : '0';
    });
  }

  Widget _buildCalculator() {
    return ScoreCalculator(
      isSettingTotal: _isSettingTotal,
      currentInput: _currentInput,
      selectedEntityDisplayScore: _getDisplayScore(_selectedPlayerId),
      selectedEntityName: _getSelectedEntity()?.name ?? 'Player',
      canSaveRound: _canSaveRound(),
      onButtonPressed: _onCalculatorButtonPressed,
      onSetTotalPoints: _setTotalPoints,
      onResetRound: _resetRound,
      onAddRound: _addRound,
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

  Widget _buildFinishedGameScreen() {
    final entities = _scoringEntities;
    final winner = entities.isEmpty
        ? (id: 'unknown', name: 'Unknown')
        : entities.firstWhere(
            (e) => e.id == _currentGame.winnerId,
            orElse: () => (id: 'unknown', name: 'Unknown'),
          );

    final totalScores = <String, int>{};
    for (var entity in entities) {
      totalScores[entity.id] = _calculateTotalScore(entity.id);
    }

    return FinishedGameScreen(
      entities: entities,
      winner: winner,
      totalScores: totalScores,
      onReopen: () {
        setState(() {
          _currentGame.winnerId = null;
        });
        _saveGame();
      },
    );
  }

  Widget _buildMaxScoreIndicator() {
    final totalScores = <String, int>{};
    for (var entity in _scoringEntities) {
      totalScores[entity.id] = _calculateTotalScore(entity.id);
    }

    return MaxScoreIndicator(
      maxScore: _currentGame.maxScore,
      scoringEntities: _scoringEntities,
      totalScores: totalScores,
    );
  }

  void _declareWinner(String winnerId) {
    setState(() {
      _currentGame.winnerId = winnerId;
    });
    _saveGame();

    final winner = _scoringEntities.firstWhere((e) => e.id == winnerId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${winner.name} wins the game!'),
        duration: const Duration(seconds: 3),
      ),
    );
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
      // Give player a "Bolte". Cycles B1 (-100) -> B2 (-200) -> B3 (-300,
      // costs 10 real points) -> B1 again, for the rest of the game.
      final totalBoltes = _gameBolteCounts[_selectedPlayerId] ?? 0;
      final cyclePosition = totalBoltes % 3;

      if (cyclePosition == 0) {
        _currentRoundScores[_selectedPlayerId] = -100; // B1
      } else if (cyclePosition == 1) {
        _currentRoundScores[_selectedPlayerId] = -200; // B2
      } else {
        _currentRoundScores[_selectedPlayerId] = -300; // B3
      }
      _currentInput = '0';
      _manuallyEnteredPlayerIds.add(_selectedPlayerId);
      _calculateRemainingScores();
    } else if (button == '-10') {
      // Give player -10 points (for going out with 0 actual game points)
      _currentRoundScores[_selectedPlayerId] = -10;
      _currentInput = '0';
      _manuallyEnteredPlayerIds.add(_selectedPlayerId);
      _calculateRemainingScores();
    } else if (button == 'C') {
      _currentInput = '0';
      _currentRoundScores[_selectedPlayerId] = 0;
      _manuallyEnteredPlayerIds.remove(_selectedPlayerId);
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

    // Prevent score from exceeding total
    if (score > _totalRoundPoints) {
      _currentInput = _totalRoundPoints.toString();
      _currentRoundScores[_selectedPlayerId] = _totalRoundPoints;
    } else {
      _currentRoundScores[_selectedPlayerId] = score;
    }

    _manuallyEnteredPlayerIds.add(_selectedPlayerId);
    _calculateRemainingScores();
  }

  void _calculateRemainingScores() {
    // The auto-fill target must be derived only from scores the user
    // actually typed - never from a previous auto-fill result - otherwise
    // each keystroke of a multi-digit number feeds a stale auto-filled
    // value back into the sum and corrupts it.
    final unfilledPlayers = _scoringEntities
        .where((e) => !_manuallyEnteredPlayerIds.contains(e.id))
        .toList();

    // Only auto-assign once exactly one player is left unaccounted for.
    if (unfilledPlayers.length != 1) return;

    final enteredTotal = _manuallyEnteredPlayerIds
        .map((id) => _currentRoundScores[id] ?? 0)
        .where((score) => score > 0)
        .fold(0, (sum, score) => sum + score);

    final remaining = _totalRoundPoints - enteredTotal;
    _currentRoundScores[unfilledPlayers.first.id] = remaining >= 0
        ? remaining
        : 0;
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
      _manuallyEnteredPlayerIds.clear();

      for (var entity in _scoringEntities) {
        _currentRoundScores[entity.id] = 0;
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

  ({String id, String name})? _getSelectedEntity() {
    if (_selectedPlayerId.isEmpty) return null;
    final entities = _scoringEntities;
    if (entities.isEmpty) return null;
    return entities.firstWhere(
      (entity) => entity.id == _selectedPlayerId,
      orElse: () => entities.first,
    );
  }

  int _calculateTotalScore(String playerId) {
    return _currentGame.rounds.fold(0, (total, round) {
      final score = round.scores[playerId] ?? 0;
      if (score == -300) return total - 10; // B3 - costs 10 real points
      if (score == -100 || score == -200) return total; // B1/B2 - no cost
      return total + score; // Regular round points and manual -10 penalty
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

      _checkForWinner();
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

  void _checkForWinner() {
    final totalScores = <String, int>{};
    final playersAboveMax = <({String id, String name})>[];

    for (var entity in _scoringEntities) {
      final score = _calculateTotalScore(entity.id);
      totalScores[entity.id] = score;

      if (score >= _currentGame.maxScore) {
        playersAboveMax.add(entity);
      }
    }

    if (playersAboveMax.isEmpty) {
      return;
    }

    if (playersAboveMax.length == 1) {
      _declareWinner(playersAboveMax.first.id);
      return;
    }

    showMultipleWinnersDialog(
      context,
      maxScore: _currentGame.maxScore,
      playersAboveMax: playersAboveMax,
      totalScores: totalScores,
      onDeclareWinner: _declareWinner,
    );
  }

  void _resetRound() {
    setState(() {
      _isSettingTotal = true;
      _totalRoundPoints = 0;
      _currentInput = '0';
      _manuallyEnteredPlayerIds.clear();

      for (var entity in _scoringEntities) {
        _currentRoundScores[entity.id] = 0;
      }
    });
  }

  void _deleteRound(int roundNumber) {
    showDeleteRoundDialog(
      context,
      onConfirm: () {
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
      },
    );
  }

  void _saveGame() {
    StorageService.saveGame(_currentGame);
  }
}
