import 'package:belote_notes/models/game.dart';
import 'package:belote_notes/utils/migration_helper.dart';
import 'package:belote_notes/views/home/home_screen.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belote Notes',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
