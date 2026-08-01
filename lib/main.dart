import 'package:belote_notes/app.dart';
import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/services/migration_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive FIRST
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(BeloteGameAdapter());
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(RoundAdapter());
  Hive.registerAdapter(TeamAdapter());

  // Now migration can work
  await MigrationHelper.migrateGamesBox();

  // Open the games box
  await Hive.openBox<BeloteGame>('games');

  runApp(const MyApp());
}
