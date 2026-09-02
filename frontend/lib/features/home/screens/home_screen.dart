import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../../../shared/widgets/poster_rail.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/ms_badge.dart';
import '../../../shared/widgets/ms_avatar.dart';
import '../../../shared/widgets/ms_button.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.ink0 : AppColors.paper0,
      body: homeAsync.when(
        loading: () => const _HomeSkeleton(),
        error: (e, _) => Center(
          child: Text('Failed to load', style: AppTypography.body),
        ),
        data: (data) => _HomeContent(data: data),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'MySerial',
                          style: AppTypography.heading,
                        ),
                        TextSpan(
                          text: '.',
                          style: AppTypography.heading.copyWith(
                            color: AppColors.signal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/alerts'),
                  icon: Badge(
                    backgroundColor: AppColors.signal,
                    smallSize: 8,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? AppColors.fg1 : AppColors.lightFg1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.sp2,
              AppSpacing.pageGutter,
              0,
            ),
            child: Text(
              'Track it. Rate it. Binge it.',
              style: AppTypography.caption.copyWith(color: AppColors.fg3),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp5)),

        // MY SHOWS Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MY SHOWS',
                  style: AppTypography.overline,
                ),
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: Text(
                    'View all \u2192',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),

        // Most recently logged show card (if exists) or empty state
        if (data.continueWatching != null)
          SliverToBoxAdapter(
            child: _MostRecentShowCard(item: data.continueWatching!),
          )
        else if (data.myShows.isEmpty)
          SliverToBoxAdapter(
            child: _EmptyMyShowsCard(),
          ),

        // If there are watched / watching shows, display the rail in order of most recently logged
        if (data.myShows.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp4)),
          SliverToBoxAdapter(
            child: PosterRail(
              items: data.myShows
                  .map((s) => PosterRailItem(
                        title: s.title,
                        imageUrl: s.posterUrl,
                        onTap: () => context.push('/show/${s.id}'),
                      ))
                  .toList(),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

        // Binge Ready
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('BINGE-READY', style: AppTypography.overline),
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/search');
                  },
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.fg3,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),
        if (data.bingeReady.isEmpty)
          SliverToBoxAdapter(
            child: _EmptyBingeCard(),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _BingeReadyCard(item: data.bingeReady[i]),
              childCount: data.bingeReady.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

        // Popular with friends
        if (data.friendActivity.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: Text(
                'POPULAR WITH FRIENDS',
                style: AppTypography.overline,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                itemCount: data.friendActivity.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.railGap),
                itemBuilder: (_, i) {
                  final item = data.friendActivity[i];
                  return SizedBox(
                    width: 90,
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            PosterPlaceholder(
                              title: item.showTitle,
                              imageUrl: item.posterUrl,
                              width: 90,
                            ),
                            Positioned(
                              bottom: -8,
                              right: -4,
                              child: MsAvatar(
                                name: item.friendName,
                                imageUrl: item.friendAvatarUrl,
                                size: 28,
                                ringColor: AppColors.ink0,
                                ringWidth: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.friendName,
                          style: AppTypography.micro,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.bottomContentPad),
        ),
      ],
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _MostRecentShowCard extends StatelessWidget {
  const _MostRecentShowCard({required this.item});
  final ContinueWatchingItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      child: GestureDetector(
        onTap: () => context.push('/show/${item.showId}'),
        child: Container(
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.card),
                  bottomLeft: Radius.circular(AppRadius.card),
                ),
                child: SizedBox(
                  width: 80,
                  height: 100,
                  child: PosterPlaceholder(
                    title: item.showTitle,
                    imageUrl: item.posterUrl,
                    aspectRatio: 80 / 100,
                    radius: 0,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sp3,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.showTitle,
                              style: AppTypography.cardTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sp3),
                            child: MsBadge(
                              label: 'Recent',
                              variant: MsBadgeVariant.signal,
                              small: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            item.episodeCode,
                            style: AppTypography.codeStyle.copyWith(
                              color: AppColors.signal,
                              fontSize: 12,
                            ),
                          ),
                          if (item.episodeTitle.isNotEmpty)
                            Expanded(
                              child: Text(
                                ' \u00b7 ${item.episodeTitle}',
                                style: AppTypography.caption.copyWith(
                                  color: isDark
                                      ? AppColors.fg2
                                      : AppColors.lightFg2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      ProgressBar(value: item.progress),
                      const SizedBox(height: 4),
                      Text(
                        '${item.watchedCount}/${item.totalCount} episodes',
                        style: AppTypography.micro,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sp3),
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  color: AppColors.signal,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMyShowsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      child: GestureDetector(
        onTap: () => context.go('/search'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sp4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.ink1 : AppColors.paper1,
            borderRadius: AppRadius.cardRR,
            border: Border.all(
              color: isDark ? AppColors.inkLine : AppColors.paperLine,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.tv_outlined, color: AppColors.signal, size: 32),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No shows logged yet', style: AppTypography.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      'Search and log what you are watching',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.fg3, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _BingeReadyCard extends StatelessWidget {
  const _BingeReadyCard({required this.item});
  final BingeReadyItem item;

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
        padding: const EdgeInsets.all(AppSpacing.sp4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.ink1 : AppColors.paper1,
          borderRadius: AppRadius.cardRR,
          border: Border.all(
            color: isDark ? AppColors.inkLine : AppColors.paperLine,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
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
                  Text(
                    item.showTitle,
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: AppTypography.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sp3),
            MsBadge(
              label: '${item.seasonCount}S',
              variant: MsBadgeVariant.signal,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBingeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.ink1 : AppColors.paper1,
          borderRadius: AppRadius.cardRR,
          border: Border.all(
            color: isDark ? AppColors.inkLine : AppColors.paperLine,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.tv_off_outlined,
              color: AppColors.fg3,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.sp3),
            Text(
              'Nothing left to binge',
              style: AppTypography.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sp2),
            Text(
              'Track shows that are still airing and we\'ll tell you when a full season drops.',
              style: AppTypography.body.copyWith(color: AppColors.fg2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sp5),
            MsButton(
              label: 'Track a show',
              variant: MsButtonVariant.secondary,
              onPressed: () {
                context.go('/search');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ────────────────────────────────────────────────────────────────

class _HomeSkeleton extends StatefulWidget {
  const _HomeSkeleton();

  @override
  State<_HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<_HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final opacity = 0.3 + _anim.value * 0.3;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            MediaQuery.paddingOf(context).top + AppSpacing.sp4,
            AppSpacing.pageGutter,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bone(width: 120, height: 22, opacity: opacity),
              const SizedBox(height: AppSpacing.sp5),
              _Bone(width: double.infinity, height: 100, opacity: opacity),
              const SizedBox(height: AppSpacing.sp6),
              _Bone(width: 100, height: 16, opacity: opacity),
              const SizedBox(height: AppSpacing.sp3),
              Row(
                children: [
                  _Bone(width: 90, height: 135, opacity: opacity),
                  const SizedBox(width: AppSpacing.sp3),
                  _Bone(width: 90, height: 135, opacity: opacity),
                  const SizedBox(width: AppSpacing.sp3),
                  _Bone(width: 90, height: 135, opacity: opacity),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    required this.opacity,
    this.flex = false,
  });
  final double width;
  final double height;
  final double opacity;
  final bool flex;

  @override
  Widget build(BuildContext context) {
    final box = Opacity(
      opacity: opacity,
      child: Container(
        width: flex ? null : width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.ink2,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
    );
    return flex ? Expanded(child: box) : box;
  }
}
