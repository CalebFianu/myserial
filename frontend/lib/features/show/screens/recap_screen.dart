import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/pinned_header.dart';
import '../providers/show_provider.dart';

class RecapScreen extends ConsumerStatefulWidget {
  const RecapScreen({super.key, required this.showId});
  final int showId;

  @override
  ConsumerState<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends ConsumerState<RecapScreen> {
  final Set<int> _revealed = {};

  @override
  Widget build(BuildContext context) {
    final recapAsync = ref.watch(recapProvider(widget.showId));
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.ink0,
      body: recapAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (_, __) =>
            const Center(child: Text('Error loading recap')),
        data: (recapData) {
          return CustomScrollView(
            slivers: [
              pinnedHeader(
                height: topPad + 42,
                background: AppColors.ink0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    topPad + AppSpacing.sp4,
                    AppSpacing.pageGutter,
                    0,
                  ),
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back_rounded,
                            size: 18, color: AppColors.fg3),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.fg3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    AppSpacing.sp3,
                    AppSpacing.pageGutter,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The story so far', style: AppTypography.title),
                      const SizedBox(height: AppSpacing.sp2),
                      Text(
                        'No spoilers past your last watched episode.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.star,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final chapter = recapData.chapters[i];
                    final isLocked = chapter.unlockAfterEpisode >
                            recapData.watchedCount &&
                        !_revealed.contains(i);
                    return _ChapterCard(
                      chapter: chapter,
                      index: i,
                      isLocked: isLocked,
                      onReveal: () => setState(() => _revealed.add(i)),
                    );
                  },
                  childCount: recapData.chapters.length,
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

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.index,
    required this.isLocked,
    required this.onReveal,
  });

  final RecapChapter chapter;
  final int index;
  final bool isLocked;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        0,
        AppSpacing.pageGutter,
        AppSpacing.sp5,
      ),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sp4),
            decoration: BoxDecoration(
              color: AppColors.ink1,
              borderRadius: AppRadius.cardRR,
              border: Border.all(color: AppColors.inkLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.range,
                  style: AppTypography.micro.copyWith(
                    color: AppColors.star,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp2),
                Text(chapter.title, style: AppTypography.heading),
                const SizedBox(height: AppSpacing.sp3),
                Text(
                  chapter.body,
                  style: AppTypography.body.copyWith(color: AppColors.fg2),
                ),
              ],
            ),
          ),

          if (isLocked)
            Positioned.fill(
              child: GestureDetector(
                onTap: onReveal,
                child: ClipRRect(
                  borderRadius: AppRadius.cardRR,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.ink0.withOpacity(0.6),
                        borderRadius: AppRadius.cardRR,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.fg2,
                              size: 28,
                            ),
                            const SizedBox(height: AppSpacing.sp2),
                            Text(
                              'Tap to reveal',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.fg2,
                              ),
                            ),
                            Text(
                              'Spoilers ahead',
                              style: AppTypography.micro.copyWith(
                                color: AppColors.alertColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
