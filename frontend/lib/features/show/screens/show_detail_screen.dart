import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_avatar.dart';
import '../../../shared/widgets/ms_badge.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../providers/show_provider.dart';

class ShowDetailScreen extends ConsumerWidget {
  const ShowDetailScreen({super.key, required this.showId});
  final int showId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAsync = ref.watch(showDetailProvider(showId));

    return Scaffold(
      backgroundColor: AppColors.ink0,
      body: showAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (e, _) => Center(
          child: Text('Error loading show', style: AppTypography.body),
        ),
        data: (show) => _ShowDetailContent(show: show, ref: ref),
      ),
    );
  }
}

class _ShowDetailContent extends StatelessWidget {
  const _ShowDetailContent({required this.show, required this.ref});
  final ShowDetail show;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return CustomScrollView(
      slivers: [
        // Hero header
        SliverToBoxAdapter(
          child: Stack(
            children: [
              // Full-bleed hero
              SizedBox(
                width: screenWidth,
                height: screenWidth * 0.55 + topPad,
                child: PosterPlaceholder(
                  title: show.title,
                  imageUrl: show.backdropUrl ?? show.posterUrl,
                  aspectRatio: screenWidth / (screenWidth * 0.55 + topPad),
                  radius: 0,
                ),
              ),
              // Bottom scrim
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 180,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.ink0.withOpacity(0),
                        AppColors.ink0,
                      ],
                    ),
                  ),
                ),
              ),
              // Top gradient for status bar
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: topPad + 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Back button
              Positioned(
                top: topPad + 8,
                left: AppSpacing.sp4,
                child: MsButton(
                  label: '',
                  variant: MsButtonVariant.glass,
                  size: MsButtonSize.sm,
                  leading: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
              // Status/episode badges — hero bottom
              Positioned(
                left: AppSpacing.pageGutter,
                bottom: 12,
                child: Row(
                  children: [
                    if (show.status != null)
                      MsBadge(
                        label: show.status!,
                        variant: show.status == 'Returning'
                            ? MsBadgeVariant.track
                            : MsBadgeVariant.neutral,
                        leadingDot: true,
                      ),
                    if (show.totalEpisodes != null) ...[
                      const SizedBox(width: AppSpacing.sp2),
                      MsBadge(
                        label: '${show.totalEpisodes} eps',
                        variant: MsBadgeVariant.neutral,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Title + meta
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.sp4,
              AppSpacing.pageGutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(show.title, style: AppTypography.hero),
                const SizedBox(height: AppSpacing.sp2),
                Text(
                  [
                    if (show.yearRange.isNotEmpty) show.yearRange,
                    if (show.network != null) show.network!,
                    if (show.status != null) show.status!,
                  ].join(' · '),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sp4),

                // Primary action row
                Row(
                  children: [
                    if (show.hasWatched) ...[
                      Expanded(
                        child: MsButton(
                          label: 'The story so far',
                          variant: MsButtonVariant.secondary,
                          size: MsButtonSize.sm,
                          leading: const Icon(Icons.auto_stories_outlined,
                              size: 14),
                          onPressed: () =>
                              context.push('/show/${show.id}/recap'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp2),
                      Expanded(
                        child: MsButton(
                          label: 'Cast graph',
                          variant: MsButtonVariant.secondary,
                          size: MsButtonSize.sm,
                          leading: const Icon(Icons.hub_outlined, size: 14),
                          onPressed: () =>
                              context.push('/show/${show.id}/cast-graph'),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: show.isInWatchlist
                            ? Row(
                                children: [
                                  Icon(Icons.check_rounded,
                                      color: AppColors.track, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'In your watchlist',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.track,
                                    ),
                                  ),
                                ],
                              )
                            : MsButton(
                                label: 'Add to watchlist',
                                variant: MsButtonVariant.secondary,
                                size: MsButtonSize.sm,
                                leading: const Icon(
                                    Icons.bookmark_border_rounded,
                                    size: 14),
                                onPressed: () => ref
                                    .read(showDetailProvider(show.id).notifier)
                                    .toggleWatchlist(),
                              ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp4)),

        // Streaming provider card
        if (show.streamingProviders.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: _StreamingCard(providers: show.streamingProviders),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp4)),

        // Rewatch + rating row
        if (show.hasWatched)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: Row(
                children: [
                  if (show.avgRating != null) ...[
                    RatingStars(value: show.avgRating!, size: 16),
                    const SizedBox(width: AppSpacing.sp2),
                    Text(
                      show.avgRating!.toStringAsFixed(1),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.star,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp3),
                  ],
                  const Spacer(),
                  _RewatchButton(count: show.rewatchCount),
                ],
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp4)),

        // Overview
        if (show.overview != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: _ExpandableText(text: show.overview!),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

        // Seasons
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
            ),
            child: Text('SEASONS', style: AppTypography.overline),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _SeasonRow(
              season: show.seasons[i],
              showId: show.id,
            ),
            childCount: show.seasons.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

        // Cast
        if (show.cast.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Text('CAST', style: AppTypography.overline)),
                  TextButton(
                    onPressed: () =>
                        context.push('/show/${show.id}/cast'),
                    child: Text(
                      'See all',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final member = show.cast[i];
                return _CastRow(
                  member: member,
                  onTap: () => context.push('/person/${member.id}'),
                );
              },
              childCount: show.cast.take(4).length,
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp4)),

        // Crew
        if (show.crew.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: Text('CREW', style: AppTypography.overline),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final member = show.crew[i];
                return _CrewRow(member: member);
              },
              childCount: show.crew.take(3).length,
            ),
          ),
        ],

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.bottomContentPad),
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StreamingCard extends StatelessWidget {
  const _StreamingCard({required this.providers});
  final List<StreamingProvider> providers;

  @override
  Widget build(BuildContext context) {
    final provider = providers.first;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: AppColors.ink1,
        borderRadius: AppRadius.cardRR,
        border: Border.all(color: AppColors.inkLine),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.ink2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tv_rounded, size: 18, color: AppColors.fg2),
          ),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watch on ${provider.name}',
                  style: AppTypography.bodySemiBold,
                ),
                if (provider.leavingSoon == true &&
                    provider.leavingDate != null)
                  Text(
                    'Leaving ${provider.leavingDate}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.alertColor,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.fg3),
        ],
      ),
    );
  }
}

class _RewatchButton extends StatelessWidget {
  const _RewatchButton({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ink2,
        borderRadius: AppRadius.pillRR,
        border: Border.all(color: AppColors.inkLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.repeat_rounded, size: 14, color: AppColors.fg2),
          const SizedBox(width: 5),
          Text(
            count > 0 ? 'Rewatched $count×' : 'Rewatch',
            style: AppTypography.micro.copyWith(
              color: AppColors.fg2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text});
  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: AppTypography.body.copyWith(color: AppColors.fg2),
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? null : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _expanded ? 'Show less' : 'Read more',
            style: AppTypography.caption.copyWith(color: AppColors.info),
          ),
        ],
      ),
    );
  }
}

class _SeasonRow extends StatelessWidget {
  const _SeasonRow({required this.season, required this.showId});
  final SeasonSummary season;
  final int showId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/show/$showId/season/${season.seasonNumber}'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageGutter,
          vertical: AppSpacing.sp3,
        ),
        child: Row(
          children: [
            // Season progress indicator
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: season.episodeCount > 0
                        ? season.watchedCount / season.episodeCount
                        : 0,
                    strokeWidth: 3,
                    backgroundColor: AppColors.ink3,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.track),
                  ),
                  Text(
                    '${season.seasonNumber}',
                    style: AppTypography.micro.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(season.name, style: AppTypography.cardTitle),
                  Text(
                    '${season.episodeCount} episodes'
                    '${season.watchedCount > 0 ? ' · ${season.watchedCount} watched' : ''}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            if (season.avgRating != null) ...[
              RatingStars(value: season.avgRating!, size: 12),
              const SizedBox(width: 4),
              Text(
                season.avgRating!.toStringAsFixed(1),
                style: AppTypography.micro.copyWith(color: AppColors.star),
              ),
            ],
            const SizedBox(width: AppSpacing.sp2),
            Icon(Icons.chevron_right_rounded, color: AppColors.fg3, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CastRow extends StatelessWidget {
  const _CastRow({required this.member, required this.onTap});
  final CastMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageGutter,
          vertical: AppSpacing.sp2,
        ),
        child: Row(
          children: [
            MsAvatar(name: member.name, imageUrl: member.avatarUrl, size: 40),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: AppTypography.body),
                  Text(member.character, style: AppTypography.caption),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.fg3, size: 18),
          ],
        ),
      ),
    );
  }
}

class _CrewRow extends StatelessWidget {
  const _CrewRow({required this.member});
  final CrewMember member;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageGutter,
        vertical: AppSpacing.sp2,
      ),
      child: Row(
        children: [
          MsAvatar(name: member.name, imageUrl: member.avatarUrl, size: 40),
          const SizedBox(width: AppSpacing.sp3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: AppTypography.body),
                Text(
                  '${member.job} · ${member.department}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
