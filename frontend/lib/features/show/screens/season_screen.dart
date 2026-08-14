import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/episode_row.dart';
import '../../../shared/widgets/ms_sheet.dart';
import '../../../shared/widgets/rating_histogram.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../providers/show_provider.dart';

class SeasonScreen extends ConsumerStatefulWidget {
  const SeasonScreen({
    super.key,
    required this.showId,
    required this.seasonNumber,
  });
  final int showId;
  final int seasonNumber;

  @override
  ConsumerState<SeasonScreen> createState() => _SeasonScreenState();
}

class _SeasonScreenState extends ConsumerState<SeasonScreen> {
  final Map<int, bool> _watchedState = {};
  final Map<int, double> _ratingState = {};

  @override
  Widget build(BuildContext context) {
    final showAsync = ref.watch(showDetailProvider(widget.showId));
    final episodesAsync = ref.watch(
      seasonEpisodesProvider(
          (showId: widget.showId, seasonNumber: widget.seasonNumber)),
    );

    final show = showAsync.valueOrNull;
    final season = show?.seasons.firstWhere(
      (s) => s.seasonNumber == widget.seasonNumber,
      orElse: () => SeasonSummary(
        seasonNumber: widget.seasonNumber,
        name: 'Season ${widget.seasonNumber}',
        episodeCount: 0,
      ),
    );

    // Build histogram from episode ratings
    Map<double, int> buildHistogram(List<EpisodeDetail> episodes) {
      final hist = <double, int>{};
      for (var i = 0.5; i <= 5.0; i += 0.5) {
        hist[i] = 0;
      }
      for (final ep in episodes) {
        final rating = _ratingState[ep.id] ??
            (ep.watched ? ep.rating : null);
        if (rating != null) {
          hist[rating] = (hist[rating] ?? 0) + 1;
        }
      }
      return hist;
    }

    return Scaffold(
      backgroundColor: AppColors.ink0,
      body: episodesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (e, _) => Center(
          child: Text('Error loading episodes', style: AppTypography.body),
        ),
        data: (episodes) {
          // Merge state
          final mergedEpisodes = episodes.map((ep) {
            final watched = _watchedState[ep.id] ?? ep.watched;
            final rating = _ratingState[ep.id] ?? ep.rating;
            return EpisodeDetail(
              id: ep.id,
              episodeNumber: ep.episodeNumber,
              seasonNumber: ep.seasonNumber,
              name: ep.name,
              overview: ep.overview,
              airDate: ep.airDate,
              runtime: ep.runtime,
              stillUrl: ep.stillUrl,
              watched: watched,
              rating: rating,
            );
          }).toList();

          final watchedCount =
              mergedEpisodes.where((e) => e.watched).length;
          final ratedEps =
              mergedEpisodes.where((e) => e.rating != null).toList();
          final avgRating = ratedEps.isEmpty
              ? null
              : ratedEps.fold(0.0, (a, e) => a + e.rating!) /
                  ratedEps.length;
          final histogram = buildHistogram(mergedEpisodes);

          final topPad = MediaQuery.paddingOf(context).top;

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    topPad + AppSpacing.sp4,
                    AppSpacing.pageGutter,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back_rounded,
                              size: 18,
                              color: AppColors.fg3,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              show?.title ?? 'Show',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.fg3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      Text(
                        season?.name ?? 'Season ${widget.seasonNumber}',
                        style: AppTypography.title,
                      ),
                      if (avgRating != null) ...[
                        const SizedBox(height: AppSpacing.sp2),
                        Row(
                          children: [
                            RatingStars(value: avgRating, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.star,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'avg from your ratings',
                              style: AppTypography.micro,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sp3),
                      Text(
                        '$watchedCount/${episodes.length} episodes watched',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.track,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Histogram
              if (ratedEps.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageGutter,
                      AppSpacing.sp5,
                      AppSpacing.pageGutter,
                      0,
                    ),
                    child: RatingHistogram(
                      bins: histogram,
                      average: avgRating,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sp4)),

              // Divider
              SliverToBoxAdapter(
                child: Container(
                  height: 1,
                  color: AppColors.inkLine,
                ),
              ),

              // Episodes
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final ep = mergedEpisodes[i];
                    return Column(
                      children: [
                        EpisodeRow(
                          seasonNumber: ep.seasonNumber,
                          episodeNumber: ep.episodeNumber,
                          title: ep.name,
                          watched: ep.watched,
                          rating: ep.rating,
                          airDate: ep.airDate,
                          runtime: ep.runtime,
                          onWatchedChanged: (v) {
                            setState(() => _watchedState[ep.id] = v);
                          },
                          onRatingChanged: (_) {
                            _showRatingSheet(context, ep);
                          },
                        ),
                        if (i < mergedEpisodes.length - 1)
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageGutter,
                            ),
                            color: AppColors.inkLine.withOpacity(0.5),
                          ),
                      ],
                    );
                  },
                  childCount: mergedEpisodes.length,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.bottomContentPad),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRatingSheet(BuildContext context, EpisodeDetail ep) {
    final code =
        'S${ep.seasonNumber.toString().padLeft(2, '0')}E${ep.episodeNumber.toString().padLeft(2, '0')}';
    double currentRating = _ratingState[ep.id] ?? ep.rating ?? 0;

    MsSheet.show(
      context,
      title: '$code · ${ep.name}',
      child: StatefulBuilder(
        builder: (context, setSS) => Padding(
          padding: const EdgeInsets.all(AppSpacing.pageGutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingStars(
                value: currentRating,
                size: 36,
                interactive: true,
                onChange: (v) => setSS(() => currentRating = v),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Text(
                currentRating > 0
                    ? currentRating.toStringAsFixed(1)
                    : 'Tap to rate',
                style: AppTypography.heading.copyWith(color: AppColors.star),
              ),
              const SizedBox(height: AppSpacing.sp6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _ratingState.remove(ep.id);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear rating'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp3),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentRating > 0) {
                          setState(() {
                            _ratingState[ep.id] = currentRating;
                            _watchedState[ep.id] = true;
                          });
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
