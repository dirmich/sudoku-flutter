import 'package:flutter/material.dart';

import 'game_data.dart';
import 'sudoku_logic.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/game': (context) => const GamePage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _difficulty = 'Easy';
  bool _savedGameExists = false;

  @override
  void initState() {
    super.initState();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final savedGame = await GameDataManager.loadGame();
    setState(() {
      _savedGameExists = savedGame != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_savedGameExists)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/game', arguments: 'resume');
                },
                child: const Text('Resume Game'),
              ),
            const SizedBox(height: 40),
            const Text(
              'Select Difficulty',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _difficulty,
              onChanged: (String? newValue) {
                setState(() {
                  _difficulty = newValue!;
                });
              },
              items: <String>['Easy', 'Medium', 'Hard']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/game', arguments: _difficulty);
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class Cell {
  final int row;
  final int col;

  Cell(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class _GamePageState extends State<GamePage> {
  late Future<GameData> _gameDataFuture;
  int _selectedNumber = 0;
  Cell? _incorrectCell;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments as String;
    _gameDataFuture = _loadOrGenerateGame(arg);
  }

  Future<GameData> _loadOrGenerateGame(String arg) async {
    if (arg == 'resume') {
      final gameData = await GameDataManager.loadGame();
      if (gameData != null) {
        return gameData;
      }
    }
    final difficulty = arg;
    final generator = SudokuGenerator();
    final game = generator.generate(difficulty);
    return GameData(
      board: game[0],
      solution: game[1],
      difficulty: difficulty,
      timestamp: DateTime.now(),
    );
  }

  Future<bool> _onWillPop(GameData gameData) async {
    await GameDataManager.saveGame(gameData);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameData>(
      future: _gameDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Error loading game')),
          );
        }
        final gameData = snapshot.data!;
        final numberCounts = _countNumbers(gameData.board);

        return WillPopScope(
          onWillPop: () => _onWillPop(gameData),
          child: Scaffold(
            appBar: AppBar(
              title: Text('Sudoku - ${gameData.difficulty}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _checkSolution(gameData),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 9,
                        ),
                        itemBuilder: (context, index) {
                          final row = index ~/ 9;
                          final col = index % 9;
                          final number = gameData.board[row][col];
                          final isGiven = gameData.solution[row][col] != 0 &&
                              gameData.board[row][col] ==
                                  gameData.solution[row][col];
                          final isSelected =
                              _selectedNumber != 0 && number == _selectedNumber;
                          final isIncorrect = _incorrectCell != null &&
                              _incorrectCell!.row == row &&
                              _incorrectCell!.col == col;

                          return GestureDetector(
                            onTap: () {
                              if (!isGiven && _selectedNumber != 0) {
                                final isCompleted =
                                    numberCounts[_selectedNumber] == 9;
                                if (isCompleted) {
                                  return;
                                }

                                setState(() {
                                  gameData.board[row][col] = _selectedNumber;
                                  if (gameData.board[row][col] !=
                                      gameData.solution[row][col]) {
                                    _incorrectCell = Cell(row, col);
                                    Future.delayed(const Duration(seconds: 2),
                                        () {
                                      setState(() {
                                        gameData.board[row][col] = 0;
                                        _incorrectCell = null;
                                      });
                                    });
                                  }
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    width: (row % 3 == 0) ? 2.0 : 1.0,
                                  ),
                                  left: BorderSide(
                                    width: (col % 3 == 0) ? 2.0 : 1.0,
                                  ),
                                  right: BorderSide(
                                    width: (col == 8) ? 2.0 : 1.0,
                                  ),
                                  bottom: BorderSide(
                                    width: (row == 8) ? 2.0 : 1.0,
                                  ),
                                ),
                                color: isIncorrect
                                    ? Colors.red[100]
                                    : (isSelected
                                        ? Colors.blue[100]
                                        : (isGiven
                                            ? Colors.grey[300]
                                            : Colors.white)),
                              ),
                              child: Center(
                                child: Text(
                                  number != 0 ? number.toString() : '',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: isGiven
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: 81,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    children: List.generate(9, (index) {
                      final number = index + 1;
                      final isCompleted = numberCounts[number] == 9;
                      return ElevatedButton(
                        onPressed: isCompleted
                            ? null
                            : () {
                                setState(() {
                                  _selectedNumber = number;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedNumber == number
                              ? Colors.blue[200]
                              : (isCompleted ? Colors.grey[400] : Colors.white),
                        ),
                        child: Text(number.toString()),
                      );
                    }),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Map<int, int> _countNumbers(List<List<int>> board) {
    final counts = <int, int>{};
    for (int i = 1; i <= 9; i++) {
      counts[i] = 0;
    }
    for (final row in board) {
      for (final number in row) {
        if (number != 0) {
          counts[number] = counts[number]! + 1;
        }
      }
    }
    return counts;
  }

  void _checkSolution(GameData gameData) {
    bool isSolved = true;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (gameData.board[i][j] != gameData.solution[i][j]) {
          isSolved = false;
          break;
        }
      }
    }

    if (isSolved) {
      GameDataManager.saveGameToHistory(gameData);
      GameDataManager.clearGame();
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incorrect Solution'),
          content: const Text('Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<GameData>> _history;

  @override
  void initState() {
    super.initState();
    _history = GameDataManager.loadGameHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
      ),
      body: FutureBuilder<List<GameData>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No game history yet.'));
          }
          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final game = history[index];
              return ListTile(
                title: Text('Sudoku - ${game.difficulty}'),
                subtitle: Text(game.timestamp.toString()),
              );
            },
          );
        },
      ),
    );
  }
}
