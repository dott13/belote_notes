import 'package:belote_notes/models/game.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const _gamesBoxName = "games";
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(BeloteGameAdapter());
    Hive.registerAdapter(PlayerAdapter());
    Hive.registerAdapter(RoundAdapter());
    await Hive.openBox<BeloteGame>(_gamesBoxName);
  }

  static Box<BeloteGame> get gamesBox => Hive.box<BeloteGame>(_gamesBoxName);

   static Future<void> saveGame(BeloteGame game) async {
    await gamesBox.put(game.id, game);
  }

  static BeloteGame? getGame(String id) {
    return gamesBox.get(id);
  }

  static Future<void> deleteGame(String id) async {
    await gamesBox.delete(id);
  }

  static List<BeloteGame> getAllGames() {
    return gamesBox.values.toList();
  }
}
