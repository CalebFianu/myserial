import 'package:flutter/material.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../design/motion.dart';
import 'rating_stars.dart';

class EpisodeRow extends StatefulWidget {
  const EpisodeRow({
    super.key,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    this.watched = false,
    this.rating,
    this.onWatchedChanged,
    this.onRatingChanged,
    this.onTap,
    this.airDate,
    this.runtime,
    this.overview,
  });

  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final bool watched;
  final double? rating;
  final ValueChanged<bool>? onWatchedChanged;
  final ValueChanged<double>? onRatingChanged;
  final VoidCallback? onTap;
  final String? airDate;
  final int? runtime;
  final String? overview;

  @override
  State<EpisodeRow> createState() => _EpisodeRowState();
}

class _EpisodeRowState extends State<EpisodeRow> {
  bool _pressed = false;

  String get _episodeCode =>
      'S${widget.seasonNumber.toString().padLeft(2, '0')}'
      'E${widget.episodeNumber.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? AppMotion.pressScale : 1.0,
        duration: AppMotion.fast,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageGutter,
            vertical: AppSpacing.sp3,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox
              GestureDetector(
                onTap: () =>
                    widget.onWatchedChanged?.call(!widget.watched),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.watched
                        ? AppColors.track
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.watched
                          ? AppColors.track
                          : (isDark
                              ? AppColors.inkLine
                              : AppColors.paperLine),
                      width: 1.5,
                    ),
                  ),
                  child: widget.watched
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),

              // Episode code
              Text(
                _episodeCode,
                style: AppTypography.codeStyle.copyWith(
                  color: widget.watched ? AppColors.fg3 : AppColors.fg2,
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.body.copyWith(
                        color: widget.watched
                            ? (isDark ? AppColors.fg3 : AppColors.lightFg3)
                            : (isDark ? AppColors.fg1 : AppColors.lightFg1),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.airDate != null || widget.runtime != null)
                      Text(
                        [
                          if (widget.airDate != null) widget.airDate!,
                          if (widget.runtime != null)
                            '${widget.runtime}m',
                        ].join(' · '),
                        style: AppTypography.micro,
                      ),
                  ],
                ),
              ),

              // Rating
              if (widget.watched) ...[
                const SizedBox(width: AppSpacing.sp2),
                GestureDetector(
                  onTap: () {
                    // Opens rating dialog — handled by parent
                    widget.onRatingChanged?.call(widget.rating ?? 0);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.rating != null
                          ? const Color(0x25FFB43A)
                          : (isDark ? AppColors.ink2 : AppColors.paper0),
                      borderRadius: AppRadius.pillRR,
                      border: Border.all(
                        color: widget.rating != null
                            ? AppColors.star.withOpacity(0.3)
                            : (isDark
                                ? AppColors.inkLine
                                : AppColors.paperLine),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: widget.rating != null
                              ? AppColors.star
                              : (isDark
                                  ? AppColors.fg3
                                  : AppColors.lightFg3),
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.rating != null
                              ? widget.rating!.toStringAsFixed(1)
                              : 'Rate',
                          style: AppTypography.micro.copyWith(
                            color: widget.rating != null
                                ? AppColors.star
                                : (isDark
                                    ? AppColors.fg3
                                    : AppColors.lightFg3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
