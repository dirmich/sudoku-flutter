import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameData {
  final List<List<int>> board;
  final List<List<int>> solution;
  final String difficulty;
  final DateTime timestamp;

  GameData({
    required this.board,
    required this.solution,
    required this.difficulty,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'board': board,
        'solution': solution,
        'difficulty': difficulty,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GameData.fromJson(Map<String, dynamic> json) => GameData(
        board: List<List<int>>.from(
            json['board'].map((row) => List<int>.from(row))),
        solution: List<List<int>>.from(
            json['solution'].map((row) => List<int>.from(row))),
        difficulty: json['difficulty'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class GameDataManager {
  static const _currentGameKey = 'currentGame';
  static const _historyKey = 'gameHistory';

  static Future<void> saveGame(GameData game) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(game.toJson());
    await prefs.setString(_currentGameKey, jsonString);
  }

  static Future<GameData?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_currentGameKey);
    if (jsonString != null) {
      return GameData.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  static Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentGameKey);
  }

  static Future<void> saveGameToHistory(GameData game) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadGameHistory();
    history.add(game);
    final jsonString = jsonEncode(history.map((g) => g.toJson()).toList());
    await prefs.setString(_historyKey, jsonString);
  }

  static Future<List<GameData>> loadGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => GameData.fromJson(json)).toList();
    }
    return [];
  }
}
