import 'dart:math';

class SudokuGenerator {
  List<List<int>> board = List.generate(9, (_) => List.generate(9, (_) => 0));
  List<List<int>> solution =
      List.generate(9, (_) => List.generate(9, (_) => 0));

  List<List<List<int>>> generate(String difficulty) {
    _fillBoard();
    solution = List.generate(9, (i) => List.from(board[i]));
    _solve();
    _removeNumbers(difficulty);
    return [board, solution];
  }

  void _fillBoard() {
    _fillDiagonal();
    _fillRemaining(0, 3);
  }

  void _fillDiagonal() {
    for (int i = 0; i < 9; i = i + 3) {
      _fillBox(i, i);
    }
  }

  void _fillBox(int row, int col) {
    int num;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        do {
          num = Random().nextInt(9) + 1;
        } while (!_isSafeInBox(row, col, num));
        board[row + i][col + j] = num;
      }
    }
  }

  bool _isSafeInBox(int row, int col, int num) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[row + i][col + j] == num) {
          return false;
        }
      }
    }
    return true;
  }

  bool _fillRemaining(int i, int j) {
    if (j >= 9 && i < 8) {
      i = i + 1;
      j = 0;
    }
    if (i >= 9 && j >= 9) {
      return true;
    }

    if (i < 3) {
      if (j < 3) {
        j = 3;
      }
    } else if (i < 6) {
      if (j == (i ~/ 3) * 3) {
        j = j + 3;
      }
    } else {
      if (j == 6) {
        i = i + 1;
        j = 0;
        if (i >= 9) {
          return true;
        }
      }
    }

    for (int num = 1; num <= 9; num++) {
      if (_isSafe(i, j, num)) {
        board[i][j] = num;
        if (_fillRemaining(i, j + 1)) {
          return true;
        }
        board[i][j] = 0;
      }
    }
    return false;
  }

  bool _solve() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (solution[i][j] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (_isSafeForSolve(i, j, num)) {
              solution[i][j] = num;
              if (_solve()) {
                return true;
              } else {
                solution[i][j] = 0;
              }
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isSafe(int i, int j, int num) {
    return (_isSafeInRow(i, num) &&
        _isSafeInCol(j, num) &&
        _isSafeInBox(i - i % 3, j - j % 3, num));
  }

  bool _isSafeForSolve(int i, int j, int num) {
    return (_isSafeInRowForSolve(i, num) &&
        _isSafeInColForSolve(j, num) &&
        _isSafeInBoxForSolve(i - i % 3, j - j % 3, num));
  }

  bool _isSafeInRow(int i, int num) {
    for (int j = 0; j < 9; j++) {
      if (board[i][j] == num) {
        return false;
      }
    }
    return true;
  }

  bool _isSafeInCol(int j, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[i][j] == num) {
        return false;
      }
    }
    return true;
  }

  bool _isSafeInRowForSolve(int i, int num) {
    for (int j = 0; j < 9; j++) {
      if (solution[i][j] == num) {
        return false;
      }
    }
    return true;
  }

  bool _isSafeInColForSolve(int j, int num) {
    for (int i = 0; i < 9; i++) {
      if (solution[i][j] == num) {
        return false;
      }
    }
    return true;
  }

  bool _isSafeInBoxForSolve(int row, int col, int num) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (solution[row + i][col + j] == num) {
          return false;
        }
      }
    }
    return true;
  }

  void _removeNumbers(String difficulty) {
    int count;
    switch (difficulty) {
      case 'Easy':
        count = 40;
        break;
      case 'Medium':
        count = 50;
        break;
      case 'Hard':
        count = 60;
        break;
      default:
        count = 40;
    }

    while (count != 0) {
      int i = Random().nextInt(9);
      int j = Random().nextInt(9);
      if (board[i][j] != 0) {
        board[i][j] = 0;
        count--;
      }
    }
  }
}
