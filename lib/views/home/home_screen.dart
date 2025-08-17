import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Belote Notes'),
        actions: [
          IconButton(onPressed: _exportData, icon: const Icon(Icons.upload)),
          IconButton(onPressed: _importData, icon: const Icon(Icons.download)),
        ],
      ),
      body: _buildGameList(),
      floatingActionButton: FloatingActionButton(onPressed: _showNewGameDialogue, child: const Icon(Icons.add)),
    );
  }

  Widget _buildGameList() {
    //TODO: Make the game list here
  }

  void _showNewGameDialogue() {
    //TODO: make the dialogue for showing a new game screen
  }

}