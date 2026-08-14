import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../providers/profile_provider.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryAsync = ref.watch(diaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.paddingOf(context).top;

    // Group entries by month
    Map<String, List<DiaryEntry>> groupByMonth(List<DiaryEntry> entries) {
      final grouped = <String, List<DiaryEntry>>{};
      for (final entry in entries) {
        final key = DateFormat('MMMM yyyy').format(entry.watchedAt);
        grouped.putIfAbsent(key, () => []).add(entry);
      }
      return grouped;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.ink0 : AppColors.paper0,
      body: diaryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (_, __) =>
            Center(child: Text('Error', style: AppTypography.body)),
        data: (entries) {
          final grouped = groupByMonth(entries);
          final months = grouped.keys.toList();

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
                      Text('Diary', style: AppTypography.title),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp5)),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, mi) {
                    final month = months[mi];
                    final monthEntries = grouped[month]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pageGutter,
                            AppSpacing.sp4,
                            AppSpacing.pageGutter,
                            AppSpacing.sp3,
                          ),
                          child: Text(month.toUpperCase(),
                              style: AppTypography.overline),
                        ),
                        ...monthEntries.map((entry) =>
                            _DiaryEntryRow(entry: entry)),
                      ],
                    );
                  },
                  childCount: months.length,
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

class _DiaryEntryRow extends StatelessWidget {
  const _DiaryEntryRow({required this.entry});
  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final day = DateFormat('d').format(entry.watchedAt);
    final weekday = DateFormat('E').format(entry.watchedAt).toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageGutter,
        vertical: 2,
      ),
      padding: const EdgeInsets.all(AppSpacing.sp3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.ink1 : AppColors.paper1,
        borderRadius: AppRadius.cardRR,
        border: Border.all(
          color: isDark ? AppColors.inkLine : AppColors.paperLine,
        ),
      ),
      child: Row(
        children: [
          // Date block
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.ink2 : AppColors.paper0,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: AppTypography.heading.copyWith(
                    fontSize: 18,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  weekday,
                  style: AppTypography.micro,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.showTitle, style: AppTypography.body),
                Text(
                  entry.episodeCode,
                  style: AppTypography.codeStyle.copyWith(
                    color: AppColors.signal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (entry.rating != null)
            RatingStars(value: entry.rating!, size: 12),
        ],
      ),
    );
  }
}
