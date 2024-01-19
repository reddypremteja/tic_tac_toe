import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<List<String>> board = List.generate(3, (_) => List.filled(3, ''));
  bool isPlayer1Turn = true;
  bool againstComputer = true;

  // Define a key for SharedPreferences
  static const String gameKey = 'ticTacToeGame';

  @override
  void initState() {
    super.initState();
    // Load the saved game state when the app starts
    loadGameState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Play against:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      againstComputer = true;
                      resetGame();
                    });
                  },
                  child: Text('Computer'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      againstComputer = false;
                      resetGame();
                    });
                  },
                  child: Text('Player 2'),
                ),
              ],
            ),
            SizedBox(height: 20),
            for (int i = 0; i < 3; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < 3; j++)
                    GestureDetector(
                      onTap: () {
                        if (board[i][j].isEmpty &&
                            (isPlayer1Turn ||
                                (!isPlayer1Turn && !againstComputer))) {
                          makeMove(i, j, isPlayer1Turn ? 'X' : 'O');
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            board[i][j],
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void makeMove(int row, int col, String player) {
    setState(() {
      board[row][col] = player;
      isPlayer1Turn = !isPlayer1Turn;

      if (checkForWinner()) {
        String winner = player == 'X'
            ? 'Player 1'
            : againstComputer
                ? 'Computer'
                : 'Player 2';
        showWinnerDialog(context, winner);
        resetGame();
      } else {
        if (!isPlayer1Turn && againstComputer) {
          // Computer's turn
          makeComputerMove();
        }
      }

      // Save the game state after each move
      saveGameState();
    });
  }

  bool checkForWinner() {
    // Check rows, columns, and diagonals for a winner
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == board[i][1] &&
          board[i][1] == board[i][2] &&
          board[i][0].isNotEmpty) {
        return true;
      }
      if (board[0][i] == board[1][i] &&
          board[1][i] == board[2][i] &&
          board[0][i].isNotEmpty) {
        return true;
      }
    }
    if (board[0][0] == board[1][1] &&
        board[1][1] == board[2][2] &&
        board[0][0].isNotEmpty) {
      return true;
    }
    if (board[0][2] == board[1][1] &&
        board[1][1] == board[2][0] &&
        board[0][2].isNotEmpty) {
      return true;
    }

    // Check for a tie (no empty cells left)
    if (!board.any((row) => row.any((cell) => cell.isEmpty))) {
      showWinnerDialog(context, 'It\'s a tie!');
      resetGame();
      return true;
    }

    return false;
  }

  void showWinnerDialog(BuildContext context, String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('$winner wins!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, ''));
      isPlayer1Turn = true;
    });

    if (!isPlayer1Turn && againstComputer) {
      // Start the game with a computer move if against the computer
      makeComputerMove();
    }

    // Save the initial game state
    saveGameState();
  }

  void makeComputerMove() {
    // Simulate a simple computer player making a random move
    List<int> emptyCells = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j].isEmpty) {
          emptyCells.add(i * 3 + j);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      // Make a random move
      Random random = Random();
      int randomIndex = random.nextInt(emptyCells.length);
      int cellIndex = emptyCells[randomIndex];

      int row = cellIndex ~/ 3;
      int col = cellIndex % 3;

      makeMove(row, col, 'O');
    }
  }

  // Save the game state to SharedPreferences
  Future<void> saveGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String gameData = board.join(',');
    prefs.setString(gameKey, gameData);
  }

  // Load the game state from SharedPreferences
  Future<void> loadGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? gameData = prefs.getString(gameKey);

    if (gameData != null && gameData.isNotEmpty) {
      List<String> savedBoard = gameData.split(',');
      setState(() {
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            board[i][j] = savedBoard[i * 3 + j];
          }
        }
      });
    }
  }
}
