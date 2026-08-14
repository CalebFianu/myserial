import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/motion.dart';
import '../../design/typography.dart';
import '../../design/spacing.dart';

class RatingHistogram extends StatelessWidget {
  const RatingHistogram({
    super.key,
    required this.bins,
    this.average,
    this.height = 120,
  });

  // bins: key = star rating (0.5..5.0), value = count
  final Map<double, int> bins;
  final double? average;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (bins.isEmpty) return const SizedBox.shrink();

    final maxCount = bins.values.fold(0, (a, b) => a > b ? a : b);
    final sortedKeys = bins.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (average != null) ...[
          Row(
            children: [
              Text(
                average!.toStringAsFixed(1),
                style: AppTypography.heading.copyWith(color: AppColors.star),
              ),
              const SizedBox(width: 6),
              Icon(Icons.star_rounded,
                  color: AppColors.star, size: 16),
              const SizedBox(width: 4),
              Text(
                'avg',
                style: AppTypography.micro,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp2),
        ],
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: sortedKeys.map((key) {
              final count = bins[key] ?? 0;
              final fraction =
                  maxCount > 0 ? count / maxCount : 0.0;
              final isAvg = average != null &&
                  (key - average!).abs() < 0.25;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (count > 0)
                        Text(
                          count.toString(),
                          style: AppTypography.codeMicro.copyWith(
                            fontSize: 9,
                            color: AppColors.fg3,
                          ),
                        ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: AppMotion.med,
                        height: (height - 30) * fraction,
                        decoration: BoxDecoration(
                          color: isAvg
                              ? AppColors.signal
                              : AppColors.signal.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        key == key.truncate()
                            ? key.toInt().toString()
                            : '',
                        style: AppTypography.micro.copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

extension on double {
  double truncate() => (this * 10).truncateToDouble() / 10;
}

