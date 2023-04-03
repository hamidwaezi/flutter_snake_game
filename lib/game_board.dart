import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum Direction { up, down, left, right }

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

int getNearestTens(int num, int step) {
  int out;
  out = (num ~/ step) * step;
  if (out == 0) out += step;
  return step;
}

class _GameBoardState extends State<GameBoard> {
  late final int upperBoundX, upperBoundY, lowerBoundX, lowerBoundY;
  late final double boardWidth, boardHeight;
  int step = 20;

  ///snake
  final List<Offset> snakePositions = [];

  Timer? timer;
  SnakeDirection snakeDirection = SnakeDirection.up;

  Duration intervalDuration = const Duration(milliseconds: 500);

  Offset get randomPosition {
    Offset pos;
    int posX = Random().nextInt(upperBoundX) + lowerBoundX;
    int posY = Random().nextInt(upperBoundY) + lowerBoundY;
    pos = Offset(
      getNearestTens(posX, step).toDouble(),
      getNearestTens(posY, step).toDouble(),
    );
    return pos;
  }

  void draw() {
    if (snakePositions.isEmpty) {
      snakePositions.add(randomPosition);
    }

    for (int i = snakePositions.length - 1; i > 0; --i) {
      snakePositions[i] = snakePositions[i - 1];
    }
    snakePositions[0] = getNextSnakePosition(snakePositions[0]);
  }

  List<Peice> getSnakePeices() {
    // final peices = <Peice>[];
    draw();

    final peices =
        snakePositions.map((e) => Peice(size: step, position: e)).toList();
    return peices;
  }

  @override
  void initState() {
    super.initState();
    boardWidth = MediaQuery.of(context).size.width;
    boardHeight = boardWidth;
    lowerBoundX = step;
    lowerBoundY = step;
    upperBoundX = getNearestTens(boardWidth.toInt() - step, step);
    upperBoundY = getNearestTens(boardHeight.toInt() - step, step);
    restart();
  }

  void changeSpeed() {
    if (timer != null && timer!.isActive) {
      timer = Timer.periodic(intervalDuration, (timer) {
        setState(() {});
      });
    }
  }

  void restart() {
    changeSpeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        width: boardWidth,
        height: boardHeight,
        color: Colors.green,
        child: Stack(
          children: getSnakePeices(),
        ),
      )),
    );
  }

  Offset getNextSnakePosition(Offset now) {
    Offset next;
    switch (snakeDirection) {
      case SnakeDirection.up:
        next = Offset(now.dx, now.dy + step);

        break;

      case SnakeDirection.down:
        next = Offset(now.dx, now.dy - step);
        break;
      case SnakeDirection.left:
        next = Offset(now.dx - step, now.dy);
        break;
      case SnakeDirection.right:
        next = Offset(now.dx + step, now.dy);
        break;
    }
    return next;
  }
}

enum SnakeDirection { up, down, left, right }

class Peice extends StatelessWidget {
  final int size;
  final Color color;
  final Offset position;

  const Peice(
      {super.key,
      required this.size,
      this.color = Colors.cyan,
      required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.dx,
      left: position.dy,
      child: Container(
        margin: const EdgeInsets.all(1),
        height: size - 1,
        width: size - 1,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(size / 4),
        ),
      ),
    );
  }
}


// class Cot