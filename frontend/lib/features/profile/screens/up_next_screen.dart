import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../providers/profile_provider.dart';

class UpNextScreen extends ConsumerWidget {
  const UpNextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upNextAsync = ref.watch(upNextProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: isDark ? AppColors.ink0 : AppColors.paper0,
      body: upNextAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (_, __) =>
            Center(child: Text('Error', style: AppTypography.body)),
        data: (items) => CustomScrollView(
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
                    Text('Up next', style: AppTypography.title),
                    const SizedBox(height: AppSpacing.sp2),
                    Text(
                      '${items.length} shows to catch up on',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp5)),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _UpNextCard(item: items[i]),
                childCount: items.length,
              ),
            ),

            if (items.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sp8),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.track,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.sp3),
                        Text(
                          'All caught up!',
                          style: AppTypography.heading,
                        ),
                        const SizedBox(height: AppSpacing.sp2),
                        Text(
                          'You\'re up to date on all your shows.',
                          style: AppTypography.body
                              .copyWith(color: AppColors.fg2),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.bottomContentPad),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpNextCard extends StatelessWidget {
  const _UpNextCard({required this.item});
  final UpNextItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        0,
        AppSpacing.pageGutter,
        AppSpacing.sp3,
      ),
      child: Container(
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
            // Poster
            SizedBox(
              width: 52,
              child: PosterPlaceholder(
                title: item.showTitle,
                imageUrl: item.posterUrl,
              ),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.showTitle, style: AppTypography.cardTitle),
                  const SizedBox(height: 2),
                  Text(
                    item.episodeCode,
                    style: AppTypography.codeStyle.copyWith(
                      color: AppColors.signal,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    item.episodeTitle,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.airDate != null || item.runtime != null)
                    Text(
                      [
                        if (item.airDate != null) item.airDate!,
                        if (item.runtime != null) '${item.runtime}m',
                      ].join(' · '),
                      style: AppTypography.micro,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sp2),
            MsButton(
              label: 'Watched',
              variant: MsButtonVariant.secondary,
              size: MsButtonSize.sm,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
