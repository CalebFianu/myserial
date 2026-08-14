import 'package:flutter/material.dart';
import '../../design/colors.dart';

class RatingStars extends StatefulWidget {
  const RatingStars({
    super.key,
    required this.value,
    this.size = 20,
    this.interactive = false,
    this.onChange,
    this.color,
    this.emptyColor,
  });

  final double value; // 0.0 to 5.0 in 0.5 increments
  final double size;
  final bool interactive;
  final ValueChanged<double>? onChange;
  final Color? color;
  final Color? emptyColor;

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(RatingStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  void _handleTap(int starIndex, bool isRightHalf) {
    if (!widget.interactive) return;
    double newValue = isRightHalf ? starIndex + 1.0 : starIndex + 0.5;

    // Tapping same filled star → decrement by 0.5
    if (newValue == _currentValue && isRightHalf) {
      newValue = starIndex + 0.5;
    } else if (newValue == _currentValue && !isRightHalf && _currentValue == starIndex + 0.5) {
      newValue = 0;
    }

    newValue = newValue.clamp(0.0, 5.0);
    setState(() => _currentValue = newValue);
    widget.onChange?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final starColor = widget.color ?? AppColors.star;
    final emptyColor = widget.emptyColor ?? AppColors.fg3.withOpacity(0.4);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = _currentValue >= i + 1;
        final half = !filled && _currentValue >= i + 0.5;

        Widget star = SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              Icon(
                Icons.star_rounded,
                size: widget.size,
                color: emptyColor,
              ),
              if (filled)
                Icon(
                  Icons.star_rounded,
                  size: widget.size,
                  color: starColor,
                )
              else if (half)
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.5,
                    child: Icon(
                      Icons.star_rounded,
                      size: widget.size,
                      color: starColor,
                    ),
                  ),
                ),
            ],
          ),
        );

        if (widget.interactive) {
          star = GestureDetector(
            onTapUp: (details) {
              final isRightHalf =
                  details.localPosition.dx > widget.size / 2;
              _handleTap(i, isRightHalf);
            },
            child: star,
          );
        }

        return star;
      }),
    );
  }
}
