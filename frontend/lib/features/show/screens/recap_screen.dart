import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../providers/show_provider.dart';

class _RecapChapter {
  const _RecapChapter({
    required this.range,
    required this.title,
    required this.body,
    required this.isRead,
  });
  final String range;
  final String title;
  final String body;
  final bool isRead;
}

// Mock recap data
List<_RecapChapter> _buildChapters(int watchedCount) {
  final all = [
    _RecapChapter(
      range: 'S01E01–02',
      title: 'The Severance Procedure',
      body: 'Mark S. joins Lumon Industries as a department head in Macrodata Refinement. He and his team — Dylan G., Irving B., and Helly R. — work with mysterious files, though they\'re never told what they actually do. Helly attempts to resign but is denied; she learns that only her innie can quit, and her outie can override that choice.',
      isRead: watchedCount >= 2,
    ),
    _RecapChapter(
      range: 'S01E03–04',
      title: 'The Testing Floor',
      body: 'The team discovers the testing floor and its disturbing rituals. Helly escalates her attempts to escape the severed floor. Irving grows obsessed with a mysterious corridor. Mark begins to suspect something is wrong with the program.',
      isRead: watchedCount >= 4,
    ),
    _RecapChapter(
      range: 'S01E05–06',
      title: 'Goat Room & Jazz',
      body: 'The team wins access to the Perpetuity Wing. Burt and Irving\'s relationship deepens. Dylan discovers a way to activate the overtime contingency. Outside Lumon, Mark\'s neighbor turns out to be his supervisor.',
      isRead: watchedCount >= 6,
    ),
    _RecapChapter(
      range: 'S01E07–09',
      title: 'The We We Are',
      body: 'Dylan activates overtime and the three innies briefly experience the outside world. Helly discovers she is Helena Eagan, the CEO\'s granddaughter. Mark learns his wife Gemma may be alive inside Lumon. The season ends with a shocking revelation about what Lumon is really doing.',
      isRead: watchedCount >= 9,
    ),
  ];
  return all;
}

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
    final showAsync = ref.watch(showDetailProvider(widget.showId));
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.ink0,
      body: showAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (_, __) =>
            const Center(child: Text('Error loading recap')),
        data: (show) {
          final chapters = _buildChapters(show.watchedEpisodeCount);

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
                            Text(
                              show.title,
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.fg3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp4),
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
                  (context, i) => _ChapterCard(
                    chapter: chapters[i],
                    index: i,
                    isRevealed: _revealed.contains(i),
                    onReveal: () => setState(() => _revealed.add(i)),
                  ),
                  childCount: chapters.length,
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
    required this.isRevealed,
    required this.onReveal,
  });

  final _RecapChapter chapter;
  final int index;
  final bool isRevealed;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final isLocked = !chapter.isRead && !isRevealed;

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
                // Range label
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

          // Blur overlay for unread
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
