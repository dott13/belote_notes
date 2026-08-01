import 'dart:convert';
import 'dart:io';

import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportResult {
  final bool success;
  final String message;

  const ExportResult({required this.success, required this.message});
}

class ImportResult {
  final bool success;
  final String message;

  const ImportResult({required this.success, required this.message});
}

class GameBackupService {
  static Future<ExportResult> exportGames() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        return const ExportResult(
          success: false,
          message: 'Storage permission denied',
        );
      }
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        return const ExportResult(
          success: false,
          message: 'Connot access storage',
        );
      }
      final downloadsDir = Directory('${directory.path}/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final file = File(
        '${downloadsDir.path}/belote_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      final games = StorageService.getAllGames();
      final gamesJson = games.map((game) => game.toJson()).toList();
      await file.writeAsString(jsonEncode(gamesJson));

      return ExportResult(success: true, message: 'Exported to ${file.path}');
    } catch (e) {
      return ExportResult(success: false, message: 'Export failed: $e');
    }
  }

  static Future<ImportResult> importGames() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        return const ImportResult(
          success: false,
          message: 'Storage permission denied',
        );
      }

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return const ImportResult(success: false, message: 'Import cancelled');
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      final List<dynamic> jsonList = jsonDecode(content);

      // Clear existing games
      await StorageService.gamesBox.clear();

      int successCount = 0;
      int errorCount = 0;

      for (var json in jsonList) {
        try {
          final game = _parseGameFromJson(json);
          if (game != null) {
            await StorageService.saveGame(game);
            successCount++;
          } else {
            errorCount++;
          }
        } catch (e) {
          errorCount++;
          debugPrint('Failed to parse game: $e');
        }
      }

      return ImportResult(
        success: true,
        message: 'Import completed: $successCount successful, $errorCount failed',
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Import failed: $e');
    }
  }

  static BeloteGame? _parseGameFromJson(dynamic json) {
    try {
      return BeloteGame(
        id:
            json['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        players:
            (json['players'] as List?)?.map((playerJson) {
              return Player(
                id: playerJson['id']?.toString() ?? '0',
                name: playerJson['name']?.toString() ?? 'Unknown',
              );
            }).toList() ??
            [],
        rounds:
            (json['rounds'] as List?)?.map((roundJson) {
              return Round(
                number: roundJson['number'] as int? ?? 0,
                scores: Map<String, int>.from(roundJson['scores'] ?? {}),
              );
            }).toList() ??
            [],
        createdAt: DateTime.parse(
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        ),
        gameMode: json['gameMode']?.toString() ?? GameMode.twoPlayers,
        maxScore: json['maxScore'] as int? ?? 101,
        winnerId: json['winnerId'] as String?,
        teams:
            (json['teams'] as List?)?.map((teamJson) {
              return Team(
                id: teamJson['id']?.toString() ?? '0',
                name: teamJson['name']?.toString() ?? 'Team',
                playerIds: List<String>.from(teamJson['playerIds'] ?? []),
              );
            }).toList() ??
            [],
        wins: Map<String, int>.from(json['wins'] ?? {}),
        history:
            (json['history'] as List?)?.map((historyJson) {
              return MatchHistoryEntry(
                finishedAt: DateTime.parse(
                  historyJson['finishedAt']?.toString() ??
                      DateTime.now().toIso8601String(),
                ),
                winnerId: historyJson['winnerId']?.toString() ?? '0',
                finalScores: Map<String, int>.from(
                  historyJson['finalScores'] ?? {},
                ),
                rounds:
                    (historyJson['rounds'] as List?)?.map((roundJson) {
                      return Round(
                        number: roundJson['number'] as int? ?? 0,
                        scores: Map<String, int>.from(
                          roundJson['scores'] ?? {},
                        ),
                      );
                    }).toList() ??
                    [],
              );
            }).toList() ??
            [],
      );
    } catch (e) {
      debugPrint('Error parsing game: $e');
      return null;
    }
  }
}
