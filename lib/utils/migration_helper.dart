import 'dart:io';
import 'package:hive/hive.dart';
import 'package:belote_notes/models/game.dart';
import 'package:path_provider/path_provider.dart';

class MigrationHelper {
  static Future<void> migrateGamesBox() async {
    try {
      // Try to open the box
      final box = await Hive.openBox<BeloteGame>('games');

      // Get all games
      final games = box.values.toList();

      // If we successfully opened and read games, we're good
      print('Successfully loaded ${games.length} games');

      // Close the box as it will be reopened in main
      await box.close();
    } catch (e) {
      print('Migration needed: $e');

      try {
        // Close any open boxes
        if (Hive.isBoxOpen('games')) {
          await Hive.box('games').close();
        }
      } catch (_) {
        // Ignore errors when closing
      }

      // Manually delete the box files
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final boxFile = File('${appDocDir.path}/games.hive');
        final lockFile = File('${appDocDir.path}/games.lock');

        if (await boxFile.exists()) {
          await boxFile.delete();
          print('Deleted games.hive');
        }

        if (await lockFile.exists()) {
          await lockFile.delete();
          print('Deleted games.lock');
        }

        print('Old data cleared. Starting fresh.');
      } catch (deleteError) {
        print('Error deleting files: $deleteError');
        // If manual deletion fails, try Hive's method
        try {
          await Hive.deleteBoxFromDisk('games');
        } catch (_) {
          print('Hive deletion also failed, but continuing anyway');
        }
      }
    }
  }
}
