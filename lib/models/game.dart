import 'package:hive/hive.dart';

part 'game.g.dart';

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

  BeloteGame({
    required this.id,
    required this.players,
    required this.rounds,
    required this.createdAt,
    required this.gameMode,
    this.maxScore = 101,
    this.winnerId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'players': players.map((p) => p.toJson()).toList(),
    'rounds': rounds.map((r) => r.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'gameMode': gameMode,
    'maxScore': maxScore,
    'winnerId': winnerId,
  };

  factory BeloteGame.fromJson(Map<String, dynamic> json) => BeloteGame(
    id: json['id'] as String,
    players: (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
    rounds: (json['rounds'] as List).map((r) => Round.fromJson(r)).toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    gameMode: json['gameMode'] as String,
    maxScore: json['maxScore'] as int? ?? 101,
    winnerId: json['winnerId'] as String?,
  );
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
