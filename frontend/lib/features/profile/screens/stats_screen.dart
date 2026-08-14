import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/rating_histogram.dart';
import '../providers/profile_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: isDark ? AppColors.ink0 : AppColors.paper0,
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (_, __) =>
            Center(child: Text('Error', style: AppTypography.body)),
        data: (profile) {
          // Mock stats
          final stats = [
            (label: 'Episodes', value: '${profile.episodeCount}', icon: Icons.play_circle_outline_rounded),
            (label: 'Hours', value: '${(profile.episodeCount * 0.72).toInt()}h', icon: Icons.access_time_rounded),
            (label: 'Shows', value: '${profile.showCount}', icon: Icons.tv_rounded),
            (label: 'Avg rating', value: profile.avgRating?.toStringAsFixed(1) ?? '—', icon: Icons.star_outline_rounded),
          ];

          final genres = [
            (genre: 'Drama', count: 18, pct: 0.38),
            (genre: 'Comedy', count: 12, pct: 0.26),
            (genre: 'Thriller', count: 9, pct: 0.19),
            (genre: 'Sci-Fi', count: 5, pct: 0.11),
            (genre: 'Documentary', count: 3, pct: 0.06),
          ];

          final histogram = {
            0.5: 2, 1.0: 3, 1.5: 5, 2.0: 8, 2.5: 14,
            3.0: 28, 3.5: 42, 4.0: 55, 4.5: 38, 5.0: 22,
          };

          return CustomScrollView(
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
                    children: stats.map((s) {
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
                        bins: histogram.map(
                          (k, v) => MapEntry(k, v),
                        ),
                        average: profile.avgRating,
                        height: 140,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

              // Top genres
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
                      ...genres.map((g) => Padding(
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
          );
        },
      ),
    );
  }
}
