import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value, // 0.0 to 1.0
    this.height = 4,
    this.fillColor,
    this.trackColor,
    this.radius,
  });

  final double value;
  final double height;
  final Color? fillColor;
  final Color? trackColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? height / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          backgroundColor: trackColor ?? AppColors.ink3,
          valueColor: AlwaysStoppedAnimation<Color>(
            fillColor ?? AppColors.track,
          ),
          minHeight: height,
        ),
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 48,
    this.strokeWidth = 4,
    this.fillColor,
    this.trackColor,
    this.child,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Color? fillColor;
  final Color? trackColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: trackColor ?? AppColors.ink3,
              valueColor: AlwaysStoppedAnimation<Color>(
                fillColor ?? AppColors.track,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
