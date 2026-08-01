// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BeloteGameAdapter extends TypeAdapter<BeloteGame> {
  @override
  final int typeId = 0;

  @override
  BeloteGame read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BeloteGame(
      id: fields[0] as String,
      players: (fields[1] as List).cast<Player>(),
      rounds: (fields[2] as List).cast<Round>(),
      createdAt: fields[3] as DateTime,
      gameMode: fields[4] as String,
      maxScore: fields[5] as int,
      winnerId: fields[6] as String?,
      teams: fields[7] == null ? [] : (fields[7] as List).cast<Team>(),
      wins: fields[8] == null ? {} : (fields[8] as Map).cast<String, int>(),
      history: fields[9] == null
          ? []
          : (fields[9] as List).cast<MatchHistoryEntry>(),
    );
  }

  @override
  void write(BinaryWriter writer, BeloteGame obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.players)
      ..writeByte(2)
      ..write(obj.rounds)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.gameMode)
      ..writeByte(5)
      ..write(obj.maxScore)
      ..writeByte(6)
      ..write(obj.winnerId)
      ..writeByte(7)
      ..write(obj.teams)
      ..writeByte(8)
      ..write(obj.wins)
      ..writeByte(9)
      ..write(obj.history);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeloteGameAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MatchHistoryEntryAdapter extends TypeAdapter<MatchHistoryEntry> {
  @override
  final int typeId = 4;

  @override
  MatchHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchHistoryEntry(
      finishedAt: fields[0] as DateTime,
      winnerId: fields[1] as String,
      finalScores: (fields[2] as Map).cast<String, int>(),
      rounds: fields[3] == null ? [] : (fields[3] as List).cast<Round>(),
    );
  }

  @override
  void write(BinaryWriter writer, MatchHistoryEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.finishedAt)
      ..writeByte(1)
      ..write(obj.winnerId)
      ..writeByte(2)
      ..write(obj.finalScores)
      ..writeByte(3)
      ..write(obj.rounds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 1;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      id: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoundAdapter extends TypeAdapter<Round> {
  @override
  final int typeId = 2;

  @override
  Round read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Round(
      number: fields[0] as int,
      scores: (fields[1] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Round obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.scores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoundAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TeamAdapter extends TypeAdapter<Team> {
  @override
  final int typeId = 3;

  @override
  Team read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Team(
      id: fields[0] as String,
      name: fields[1] as String,
      playerIds: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Team obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.playerIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
