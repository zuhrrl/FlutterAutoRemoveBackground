import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class OverlayWidget extends StatelessWidget {
  final Widget child;
  final transform;
  final onTransformUpdate;
  const OverlayWidget(
      {super.key,
      required this.child,
      required this.transform,
      required this.onTransformUpdate});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return MatrixGestureDetector(
      onMatrixUpdate: (m, tm, sm, rm) {
        notifier.value = m;
        onTransformUpdate(m);
        Logger().d(m);
      },
      child: AnimatedBuilder(
        animation: notifier,
        builder: (ctx, childWidget) {
          return Transform(
            transform: transform ?? notifier.value,
            child: child,
          );
        },
      ),
    );
  }
}
