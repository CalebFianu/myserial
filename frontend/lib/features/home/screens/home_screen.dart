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

        // 3-up stat grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
            ),
            child: Row(
              children: [
                _StatCard(
                  label: 'Up Next',
                  value: '${data.upNextCount}',
                  icon: Icons.play_circle_outline_rounded,
                  onTap: () => context.push('/profile/up-next'),
                ),
                const SizedBox(width: AppSpacing.sp3),
                _StatCard(
                  label: 'Diary',
                  value: '${data.diaryCount}',
                  icon: Icons.book_outlined,
                  onTap: () => context.push('/profile/diary'),
                ),
                const SizedBox(width: AppSpacing.sp3),
                _StatCard(
                  label: 'Stats',
                  value: '→',
                  icon: Icons.bar_chart_rounded,
                  onTap: () => context.push('/profile/stats'),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

        // Continue watching
        if (data.continueWatching != null)
          SliverToBoxAdapter(
            child: _ContinueWatchingCard(item: data.continueWatching!),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

        // Your Shows
        if (data.myShows.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: Text(
                'YOUR SHOWS',
                style: AppTypography.overline,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),
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
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),
        ],

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
                    // Show track sheet
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatCard extends StatefulWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 140),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sp3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.ink1 : AppColors.paper1,
              borderRadius: AppRadius.cardRR,
              border: Border.all(
                color: isDark ? AppColors.inkLine : AppColors.paperLine,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, size: 18, color: AppColors.signal),
                const SizedBox(height: 6),
                Text(
                  widget.value,
                  style: AppTypography.heading,
                ),
                Text(
                  widget.label,
                  style: AppTypography.micro,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueWatchingCard extends StatelessWidget {
  const _ContinueWatchingCard({required this.item});
  final ContinueWatchingItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
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
                    Text(
                      item.showTitle,
                      style: AppTypography.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        Text(
                          ' · ${item.episodeTitle}',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.fg2
                                : AppColors.lightFg2,
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
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

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
              Row(
                children: [
                  _Bone(
                      width: double.infinity,
                      height: 80,
                      opacity: opacity,
                      flex: true),
                  const SizedBox(width: AppSpacing.sp3),
                  _Bone(
                      width: double.infinity,
                      height: 80,
                      opacity: opacity,
                      flex: true),
                  const SizedBox(width: AppSpacing.sp3),
                  _Bone(
                      width: double.infinity,
                      height: 80,
                      opacity: opacity,
                      flex: true),
                ],
              ),
              const SizedBox(height: AppSpacing.sp6),
              _Bone(width: double.infinity, height: 100, opacity: opacity),
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
