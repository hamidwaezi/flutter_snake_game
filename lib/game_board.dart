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
  return out;
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

  Offset? foodPosition;
  Peice? get food => foodPosition != null
      ? Peice(size: step, position: foodPosition!, color: Colors.white)
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
  }

  void drawFood() {
    // while(foodPosition==null || foodPosition)
    foodPosition ??= (randomPosition);
    while (snakePositions.indexWhere((element) =>
            foodPosition!.dy == element.dy && element.dx == foodPosition!.dx) !=
        -1) {
      foodPosition = randomPosition;
    }

    if (foodPosition == snakePositions[0]) {
      snakePositions.add(foodPosition!);
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
    return peices;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      boardWidth = MediaQuery.of(context).size.width;
      boardHeight = boardWidth;
      lowerBoundX = step;
      lowerBoundY = step;
      upperBoundX = getNearestTens(boardWidth.toInt() - step, step);
      upperBoundY = getNearestTens(boardHeight.toInt() - step, step);
      setState(() {});
    });
    restart();
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
    changeSpeed();
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
                    ...getSnakePeices(),
                    if (food != null) food!,
                  ],
                ),
              ),
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

class ControllerButtons extends StatelessWidget {
  final VoidCallback? onPressLeft;

  final VoidCallback? onPressUp;

  final VoidCallback? onPressDown;

  final VoidCallback? onPressRight;

  const ControllerButtons({
    super.key,
    this.onPressLeft,
    this.onPressUp,
    this.onPressDown,
    this.onPressRight,
  });

  Widget getBtn({onPressed, child}) => ElevatedButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
            shape: const CircleBorder(), padding: const EdgeInsets.all(20)),
        child: child,
      );
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        getBtn(
          onPressed: onPressLeft,
          child: const Icon(Icons.keyboard_arrow_left),
        ),
        Column(
          children: [
            getBtn(
              onPressed: onPressUp,
              child: const Icon(Icons.keyboard_arrow_up),
            ),
            const SizedBox(height: 10),
            getBtn(
              onPressed: onPressDown,
              child: const Icon(Icons.keyboard_arrow_down),
            ),
          ],
        ),
        getBtn(
          onPressed: onPressRight,
          child: const Icon(Icons.keyboard_arrow_right),
        ),
      ],
    );
  }
}
