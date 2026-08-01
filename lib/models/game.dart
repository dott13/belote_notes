import 'package:hive/hive.dart';

part 'game.g.dart';

/// Canonical game mode identifiers, plus normalization for legacy saved
/// values ('2 players/teams', '3 players') used before the 2v2/1v1 split.
class GameMode {
  static const twoVsTwo = '2 v 2';
  static const twoPlayers = '2 Players';
  static const threePlayers = '3 Players';

  static String normalize(String raw) => switch (raw) {
    '2 players/teams' => twoPlayers,
    '3 players' => threePlayers,
    _ => raw,
  };
}

@HiveType(typeId: 0)
class BeloteGame {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<Player> players;

  @HiveField(2)
  final List<Round> rounds;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String gameMode;

  @HiveField(5)
  final int maxScore;

  @HiveField(6)
  String? winnerId;

  @HiveField(7, defaultValue: <Team>[])
  final List<Team> teams;

  // Wins carried across "Play Again" restarts of this same matchup, keyed by
  // team id (2v2) or player id (1v1/3p). Mutated in place, so it must never
  // be a `const {}` default shared across instances.
  @HiveField(8, defaultValue: <String, int>{})
  final Map<String, int> wins;

  // One entry per completed game in this matchup, oldest first. Mutated in
  // place (see `wins` above for why that rules out a `const []` default).
  @HiveField(9, defaultValue: <MatchHistoryEntry>[])
  final List<MatchHistoryEntry> history;

  BeloteGame({
    required this.id,
    required this.players,
    required this.rounds,
    required this.createdAt,
    required String gameMode,
    this.maxScore = 101,
    this.winnerId,
    this.teams = const [],
    required this.wins,
    required this.history,
  }) : gameMode = GameMode.normalize(gameMode);

  Map<String, dynamic> toJson() => {
    'id': id,
    'players': players.map((p) => p.toJson()).toList(),
    'rounds': rounds.map((r) => r.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'gameMode': gameMode,
    'maxScore': maxScore,
    'winnerId': winnerId,
    'teams': teams.map((t) => t.toJson()).toList(),
    'wins': wins,
    'history': history.map((h) => h.toJson()).toList(),
  };

  factory BeloteGame.fromJson(Map<String, dynamic> json) => BeloteGame(
    id: json['id'] as String,
    players: (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
    rounds: (json['rounds'] as List).map((r) => Round.fromJson(r)).toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    gameMode: json['gameMode'] as String,
    maxScore: json['maxScore'] as int? ?? 101,
    winnerId: json['winnerId'] as String?,
    teams: (json['teams'] as List? ?? [])
        .map((t) => Team.fromJson(t))
        .toList(),
    wins: Map<String, int>.from(json['wins'] ?? {}),
    history: (json['history'] as List? ?? [])
        .map((h) => MatchHistoryEntry.fromJson(h))
        .toList(),
  );
}

@HiveType(typeId: 4)
class MatchHistoryEntry {
  @HiveField(0)
  final DateTime finishedAt;

  @HiveField(1)
  final String winnerId;

  @HiveField(2)
  final Map<String, int> finalScores;

  @HiveField(3, defaultValue: <Round>[])
  final List<Round> rounds;

  MatchHistoryEntry({
    required this.finishedAt,
    required this.winnerId,
    required this.finalScores,
    required this.rounds,
  });

  Map<String, dynamic> toJson() => {
    'finishedAt': finishedAt.toIso8601String(),
    'winnerId': winnerId,
    'finalScores': finalScores,
    'rounds': rounds.map((r) => r.toJson()).toList(),
  };

  factory MatchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return MatchHistoryEntry(
      finishedAt: DateTime.parse(json['finishedAt'] as String),
      winnerId: json['winnerId'] as String,
      finalScores: Map<String, int>.from(json['finalScores'] ?? {}),
      rounds: (json['rounds'] as List? ?? [])
          .map((r) => Round.fromJson(r))
          .toList(),
    );
  }
}

@HiveType(typeId: 1)
class Player {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  Player({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(id: json['id'], name: json['name']);
  }
}

@HiveType(typeId: 2)
class Round {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final Map<String, int> scores;

  Round({required this.number, required this.scores});

  Map<String, dynamic> toJson() => {'number': number, 'scores': scores};

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      number: json['number'],
      scores: Map<String, int>.from(json['scores']),
    );
  }
}

@HiveType(typeId: 3)
class Team {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> playerIds;

  Team({required this.id, required this.name, required this.playerIds});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'playerIds': playerIds,
  };

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      playerIds: List<String>.from(json['playerIds'] as List? ?? []),
    );
  }
}
