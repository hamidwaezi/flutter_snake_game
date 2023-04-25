import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'ctrl.dart';
import 'peice.dart';

// enum Direction { up, down, left, right }

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

int getNearestTens(int num, int step) {
  int out;
  out = (num ~/ step) * step;
  if (out == 0) out += step;
  return out;
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  late final AnimationController footAnimationCtrl;
  // final Tween<double> _tween = Tween(begin: 0.75, end: 1.25);
  int points = 0;

  late final int upperBoundX, upperBoundY, lowerBoundX, lowerBoundY;
  late final double boardWidth, boardHeight;
  int step = 20;

  ///snake
  final List<Offset> snakePositions = [];

  Timer? timer;
  SnakeDirection snakeDirection = SnakeDirection.up;

  Duration intervalDuration = const Duration(milliseconds: 500);

  Offset? foodPosition;
  Peice? get food => foodPosition != null
      ? Peice(
          size: step,
          position: foodPosition!,
          color: Colors.white,
          footAnimationCtrl: footAnimationCtrl,
        )
      : null;

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
    try {
      // check if snake eat him self then looos and restart
      if (snakePositions
          .sublist(1, snakePositions.length - 1)
          .where((element) => element == snakePositions[0])
          .isNotEmpty) {
        print('loooos');
        restart();
      }
    } catch (e) {}
  }

  void drawFood() {
//
//check that snake eat the food or not
//increment points and speed of snake
    foodPosition ??= (randomPosition);
    if (foodPosition == snakePositions[0]) {
      snakePositions.add(foodPosition!);
      foodPosition = randomPosition;
      points++;
      if (points % 7 == 0) {
        intervalDuration =
            Duration(milliseconds: intervalDuration.inMilliseconds - 15);
        changeSpeed();
      }
    }
    while (snakePositions.indexWhere((element) =>
            foodPosition!.dy == element.dy && element.dx == foodPosition!.dx) !=
        -1) {
      foodPosition = randomPosition;
    }
  }

  List<Peice> getSnakePeices() {
    // final peices = <Peice>[];
    draw();
    drawFood();
    final peices =
        snakePositions.map((e) => Peice(size: step, position: e)).toList();
    peices[0] = Peice(
      size: peices[0].size,
      position: peices[0].position,
      color: Colors.black,
    );
    return [...peices];
  }

  List<Peice> drawBoard() {
    List<Peice> p = [];

    for (int i = 0; i < (boardWidth / (step)).round(); i++) {
      for (int j = 0; j < (boardHeight / (step)).round(); j++) {
        var x = (step * i).toDouble();
        var y = (step * j).toDouble();
        p.add(Peice(
          size: step,
          position: Offset(x, y),
          color: (i + j) % 2 == 0
              ? Colors.yellow.withOpacity(0.5)
              : Colors.blueGrey.withOpacity(0.5),
        ));
      }
    }
    return p;
  }

  @override
  void initState() {
    footAnimationCtrl = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    footAnimationCtrl.repeat(reverse: true);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      boardWidth = MediaQuery.of(context).size.width;
      boardHeight = boardWidth;
      lowerBoundX = 0;
      lowerBoundY = 0;
      upperBoundX = getNearestTens(boardWidth.toInt(), step);
      upperBoundY = getNearestTens(boardHeight.toInt(), step);
      setState(() {});
    });
    // restart();
    changeSpeed();
  }

  void changeSpeed() {
    if (timer != null && timer!.isActive) {
      timer = Timer.periodic(intervalDuration, (timer) {
        setState(() {});
      });
    } else {
      timer = Timer.periodic(intervalDuration, (timer) {
        setState(() {});
      });
    }
  }

  void restart() {
    intervalDuration = const Duration(milliseconds: 600);
    changeSpeed();
    snakePositions.clear();
    points = 0;
  }

  @override
  Widget build(BuildContext context) {
    try {
      return SafeArea(
        child: Scaffold(
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: boardWidth,
                height: boardHeight,
                color: Colors.green,
                child: Stack(
                  children: [
                    ...drawBoard(),
                    ...getSnakePeices(),
                    if (food != null) food!,
                  ],
                ),
              ),
              Text('$points'),
              ControllerButtons(
                onPressDown: allowDirection(SnakeDirection.down)
                    ? () => setState(() => snakeDirection = SnakeDirection.down)
                    : null,
                onPressUp: allowDirection(SnakeDirection.up)
                    ? () => setState(() => snakeDirection = SnakeDirection.up)
                    : null,
                onPressLeft: allowDirection(SnakeDirection.left)
                    ? () => setState(() => snakeDirection = SnakeDirection.left)
                    : null,
                onPressRight: allowDirection(SnakeDirection.right)
                    ? () =>
                        setState(() => snakeDirection = SnakeDirection.right)
                    : null,
              )
            ],
          )),
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  bool allowDirection(SnakeDirection direction) {
    switch (snakeDirection) {
      case SnakeDirection.up:
      case SnakeDirection.down:
        return !(direction == SnakeDirection.up ||
            direction == SnakeDirection.down);
      case SnakeDirection.left:
      case SnakeDirection.right:
        return !(direction == SnakeDirection.left ||
            direction == SnakeDirection.right);
    }
  }

  Offset getNextSnakePosition(Offset now) {
    Offset next;
    switch (snakeDirection) {
      case SnakeDirection.up:
        next = Offset(now.dx - step, now.dy);
        break;
      case SnakeDirection.down:
        next = Offset(now.dx + step, now.dy);
        break;
      case SnakeDirection.left:
        next = Offset(now.dx, now.dy - step);
        break;
      case SnakeDirection.right:
        next = Offset(now.dx, now.dy + step);
        break;
    }
    next =
        next.dx > upperBoundX ? Offset(lowerBoundX.toDouble(), next.dy) : next;
    next =
        next.dx < lowerBoundX ? Offset(upperBoundX.toDouble(), next.dy) : next;

    next =
        next.dy > upperBoundY ? Offset(next.dx, lowerBoundY.toDouble()) : next;
    next =
        next.dy < lowerBoundY ? Offset(next.dx, upperBoundY.toDouble()) : next;

    return next;
  }
}

enum SnakeDirection { up, down, left, right }
