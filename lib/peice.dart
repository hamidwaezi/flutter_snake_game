import 'package:flutter/material.dart';

class Peice extends StatelessWidget {
  final int size;
  final Color color;
  final Offset position;

  final AnimationController? footAnimationCtrl;
  static final Tween<double> _tween = Tween(begin: 0.5, end: 1.1);

  const Peice({
    super.key,
    required this.size,
    this.color = Colors.cyan,
    required this.position,
    this.footAnimationCtrl,
  });

  @override
  Widget build(BuildContext context) {
    var widget = Container(
      // margin: const EdgeInsets.all(1),
      height: size.toDouble(),
      width: size.toDouble(),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black,
          width: 0.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(0),
      ),
    );
    return Positioned(
      top: position.dx,
      left: position.dy,
      child: footAnimationCtrl == null
          ? widget
          : ScaleTransition(
              scale: _tween.animate(CurvedAnimation(
                  parent: footAnimationCtrl!, curve: Curves.elasticOut)),
              child: widget,
            ),
    );
  }
}
