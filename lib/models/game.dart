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

  BeloteGame({
    required this.id,
    required this.players,
    required this.rounds,
    required this.createdAt,
  });
}

@HiveType(typeId: 1)
class Player {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  Player({
    required this.id,
    required this.name,
  });
}

@HiveType(typeId: 2)
class Round {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final Map<String, int> scores;

  Round({
    required this.number,
    required this.scores,
  });
}