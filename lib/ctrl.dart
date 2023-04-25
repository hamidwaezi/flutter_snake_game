import 'package:flutter/material.dart';

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
