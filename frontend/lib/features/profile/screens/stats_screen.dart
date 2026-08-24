import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/rating_histogram.dart';
import '../providers/profile_provider.dart';

// ── Stats model & provider ────────────────────────────────────────────────────

class StatsData {
  const StatsData({
    required this.episodesWatched,
    required this.totalMinutes,
    required this.ratingsHistogram,
    required this.genreBreakdown,
  });

  final int episodesWatched;
  final int totalMinutes;
  final Map<double, int> ratingsHistogram;
  final List<({String genre, int count, double pct})> genreBreakdown;

  factory StatsData.fromJson(Map<String, dynamic> json) {
    final rawHistogram =
        (json['ratingsHistogram'] as Map<String, dynamic>? ?? {});
    final histogram = <double, int>{};
    rawHistogram.forEach((k, v) {
      final key = double.tryParse(k);
      if (key != null) histogram[key] = (v as num).toInt();
    });

    final genres = (json['genreBreakdown'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((g) => (
              genre: g['genre'] as String? ?? '',
              count: g['count'] as int? ?? 0,
              pct: () {
                final raw = (g['percentage'] as num?)?.toDouble() ?? 0.0;
                // Normalize: backend may send 0–100; UI expects 0.0–1.0
                return raw > 1.0 ? raw / 100.0 : raw;
              }(),
            ))
        .toList();

    return StatsData(
      episodesWatched: json['episodesWatched'] as int? ?? 0,
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      ratingsHistogram: histogram,
      genreBreakdown: genres,
    );
  }
}

final statsProvider = FutureProvider<StatsData>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.get<Map<String, dynamic>>('/stats');
  return StatsData.fromJson(data);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final statsAsync = ref.watch(statsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.paddingOf(context).top;

    // Show loading if either is loading
    if (profileAsync.isLoading || statsAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.ink0,
        body: Center(child: CircularProgressIndicator(color: AppColors.signal)),
      );
    }

    if (profileAsync.hasError || statsAsync.hasError) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.ink0 : AppColors.paper0,
        body: Center(child: Text('Error loading stats', style: AppTypography.body)),
      );
    }

    final profile = profileAsync.value!;
    final stats = statsAsync.value!;

    final statCards = [
      (
        label: 'Episodes',
        value: '${stats.episodesWatched}',
        icon: Icons.play_circle_outline_rounded
      ),
      (
        label: 'Hours',
        value: '${(stats.totalMinutes / 60).toInt()}h',
        icon: Icons.access_time_rounded
      ),
      (
        label: 'Shows',
        value: '${profile.showCount}',
        icon: Icons.tv_rounded
      ),
      (
        label: 'Avg rating',
        value: profile.avgRating?.toStringAsFixed(1) ?? '—',
        icon: Icons.star_outline_rounded
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.ink0 : AppColors.paper0,
      body: CustomScrollView(
        slivers: [
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
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back_rounded,
                            size: 18, color: AppColors.fg3),
                        const SizedBox(width: 4),
                        Text('Profile',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.fg3)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                  Text('Your year', style: AppTypography.title),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp5)),

          // 2-col stat grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sp3,
                mainAxisSpacing: AppSpacing.sp3,
                childAspectRatio: 1.6,
                children: statCards.map((s) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.sp4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.ink1 : AppColors.paper1,
                      borderRadius: AppRadius.cardRR,
                      border: Border.all(
                        color: isDark
                            ? AppColors.inkLine
                            : AppColors.paperLine,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(s.icon, size: 20, color: AppColors.signal),
                        const Spacer(),
                        Text(s.value, style: AppTypography.title),
                        Text(s.label, style: AppTypography.micro),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

          // Rating histogram
          if (stats.ratingsHistogram.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HOW YOU RATE', style: AppTypography.overline),
                    const SizedBox(height: AppSpacing.sp4),
                    RatingHistogram(
                      bins: stats.ratingsHistogram,
                      average: profile.avgRating,
                      height: 140,
                    ),
                  ],
                ),
              ),
            ),

          if (stats.ratingsHistogram.isNotEmpty)
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

          // Top genres
          if (stats.genreBreakdown.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOP GENRES', style: AppTypography.overline),
                    const SizedBox(height: AppSpacing.sp4),
                    ...stats.genreBreakdown.map((g) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sp3,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(g.genre,
                                        style: AppTypography.body),
                                  ),
                                  Text(
                                    '${g.count} shows',
                                    style: AppTypography.caption,
                                  ),
                                  const SizedBox(width: AppSpacing.sp2),
                                  Text(
                                    '${(g.pct * 100).toInt()}%',
                                    style: AppTypography.captionSemiBold
                                        .copyWith(color: AppColors.signal),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: AppRadius.pillRR,
                                child: SizedBox(
                                  height: 6,
                                  child: LinearProgressIndicator(
                                    value: g.pct,
                                    backgroundColor: AppColors.ink3,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppColors.signal,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.bottomContentPad),
          ),
        ],
      ),
    );
  }
}
