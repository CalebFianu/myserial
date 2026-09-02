import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/providers/core_providers.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/ms_avatar.dart';
import '../../../shared/widgets/ms_badge.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _showsTab = 0; // 0=Watching, 1=Watched

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final themeMode = ref.watch(themeModeProvider);
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
        data: (profile) => RefreshIndicator(
          color: AppColors.signal,
          onRefresh: () => ref.read(profileProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      Row(
                        children: [
                          MsAvatar(
                            name: profile.name,
                            imageUrl: profile.avatarUrl,
                            size: 64,
                            ringColor: AppColors.signal,
                            ringWidth: 2,
                          ),
                          const Spacer(),
                          // Theme toggle
                          IconButton(
                            onPressed: () => ref
                                .read(themeModeProvider.notifier)
                                .toggle(),
                            icon: Icon(
                              themeMode == ThemeMode.dark
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                              color: isDark ? AppColors.fg2 : AppColors.lightFg2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sp3),
                      Text(profile.name, style: AppTypography.title),
                      Text(
                        profile.handle,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.fg3,
                        ),
                      ),
                      if (profile.bio != null) ...[
                        const SizedBox(height: AppSpacing.sp3),
                        Text(
                          profile.bio!,
                          style: AppTypography.body.copyWith(
                            color: isDark ? AppColors.fg2 : AppColors.lightFg2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp4)),

              // 3-up stat cards moved from homepage (Up Next, Diary, Stats)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: Row(
                    children: [
                      _InteractiveStatCard(
                        label: 'Up Next',
                        value: '${profile.watchingShows.length}',
                        icon: Icons.play_circle_outline_rounded,
                        onTap: () => context.push('/profile/up-next'),
                      ),
                      const SizedBox(width: AppSpacing.sp3),
                      _InteractiveStatCard(
                        label: 'Diary',
                        value: '${profile.episodeCount}',
                        icon: Icons.book_outlined,
                        onTap: () => context.push('/profile/diary'),
                      ),
                      const SizedBox(width: AppSpacing.sp3),
                      _InteractiveStatCard(
                        label: 'Stats',
                        value: profile.avgRating != null
                            ? profile.avgRating!.toStringAsFixed(1)
                            : '→',
                        icon: Icons.bar_chart_rounded,
                        onTap: () => context.push('/profile/stats'),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),

              // Detailed summary stats (Episodes, Shows, Avg rating)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: Row(
                    children: [
                      _StatCard(
                        label: 'Episodes',
                        value: '${profile.episodeCount}',
                      ),
                      const SizedBox(width: AppSpacing.sp3),
                      _StatCard(
                        label: 'Shows',
                        value: '${profile.showCount}',
                      ),
                      const SizedBox(width: AppSpacing.sp3),
                      _StatCard(
                        label: 'Avg rating',
                        value: profile.avgRating != null
                            ? profile.avgRating!.toStringAsFixed(1)
                            : '—',
                        valueColor: profile.avgRating != null
                            ? AppColors.star
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp4)),

              // Edit profile button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: MsButton(
                    label: 'Edit profile',
                    variant: MsButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: () => _showEditProfileDialog(profile),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

              // My Shows
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('MY SHOWS', style: AppTypography.overline),
                      ),
                      // Up Next link
                      TextButton(
                        onPressed: () => context.push('/profile/up-next'),
                        child: Text(
                          'Up next →',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: SegmentedControl(
                    options: const ['Watching', 'Watched'],
                    selectedIndex: _showsTab,
                    onChanged: (i) => setState(() => _showsTab = i),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),
              if ((_showsTab == 0 ? profile.watchingShows : profile.watchedShows).isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageGutter,
                      vertical: AppSpacing.sp4,
                    ),
                    child: Text(
                      _showsTab == 0
                          ? 'No shows being watched yet.'
                          : 'No completed shows yet.',
                      style: AppTypography.body.copyWith(color: AppColors.fg3),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final shows = _showsTab == 0
                          ? profile.watchingShows
                          : profile.watchedShows;
                      if (i >= shows.length) return null;
                      final show = shows[i];
                      return _ShowRow(show: show);
                    },
                    childCount: _showsTab == 0
                        ? profile.watchingShows.length
                        : profile.watchedShows.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

              // Watchlist
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: GestureDetector(
                    onTap: () => context.push('/lists'),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Watchlist',
                                    style: AppTypography.cardTitle),
                                Text(
                                  '${profile.watchlistCount} show${profile.watchlistCount == 1 ? '' : 's'}',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          // Mini poster rail
                          if (profile.watchlistPosters.isNotEmpty)
                            Row(
                              children: profile.watchlistPosters.take(3).map((url) {
                                return Container(
                                  width: 32,
                                  height: 48,
                                  margin: const EdgeInsets.only(left: 4),
                                  child: PosterPlaceholder(
                                    imageUrl: url,
                                    radius: 4,
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(width: AppSpacing.sp2),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.fg3, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

              // YOUR LISTS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('YOUR LISTS', style: AppTypography.overline),
                      ),
                      GestureDetector(
                        onTap: _showCreateListDialog,
                        child: Icon(Icons.add_rounded,
                            color: AppColors.signal, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),
              if (profile.lists.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageGutter,
                      vertical: AppSpacing.sp3,
                    ),
                    child: Text(
                      'No lists yet. Tap + to create one.',
                      style: AppTypography.body.copyWith(color: AppColors.fg3),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ListCard(
                      list: profile.lists[i],
                    ),
                    childCount: profile.lists.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

              // Logout
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageGutter,
                  ),
                  child: MsButton(
                    label: 'Log out',
                    variant: MsButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/');
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.bottomContentPad),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(UserProfile profile) {
    final nameCtrl = TextEditingController(text: profile.name);
    final bioCtrl = TextEditingController(text: profile.bio ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.ink1 : AppColors.paper1,
        title: Text('Edit profile', style: AppTypography.heading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: AppSpacing.sp3),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(profileProvider.notifier).updateProfile(
                    name: nameCtrl.text.trim(),
                    bio: bioCtrl.text.trim(),
                  );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text('Save',
                style: TextStyle(color: AppColors.signal)),
          ),
        ],
      ),
    );
  }

  void _showCreateListDialog() {
    final nameCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.ink1 : AppColors.paper1,
        title: Text('New list', style: AppTypography.heading),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'List name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final api = ref.read(apiClientProvider);
              await api.post('/lists', data: {'name': name});
              ref.read(profileProvider.notifier).refresh();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text('Create',
                style: TextStyle(color: AppColors.signal)),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _InteractiveStatCard extends StatefulWidget {
  const _InteractiveStatCard({
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
  State<_InteractiveStatCard> createState() => _InteractiveStatCardState();
}

class _InteractiveStatCardState extends State<_InteractiveStatCard> {
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
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
          children: [
            Text(
              value,
              style: AppTypography.heading.copyWith(
                color: valueColor,
              ),
            ),
            Text(label, style: AppTypography.micro),
          ],
        ),
      ),
    );
  }
}

class _ShowRow extends StatelessWidget {
  const _ShowRow({required this.show});
  final UserShow show;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push('/show/${show.id}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          0,
          AppSpacing.pageGutter,
          AppSpacing.sp3,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: PosterPlaceholder(
                title: show.title,
                imageUrl: show.posterUrl,
              ),
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(show.title, style: AppTypography.body),
                  if (show.totalEpisodes > 0) ...[
                    const SizedBox(height: 4),
                    ProgressBar(value: show.progress),
                    const SizedBox(height: 2),
                    Text(
                      '${show.watchedEpisodes}/${show.totalEpisodes} episodes',
                      style: AppTypography.micro,
                    ),
                  ],
                ],
              ),
            ),
            if (show.status != null)
              MsBadge(
                label: show.status!,
                variant: show.status == 'Ended'
                    ? MsBadgeVariant.neutral
                    : MsBadgeVariant.track,
                small: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.list});
  final UserList list;

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
      child: GestureDetector(
        onTap: () => context.push('/lists/${list.id}'),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(list.name, style: AppTypography.cardTitle),
                    Text(
                      '${list.showCount} shows',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.fg3, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
