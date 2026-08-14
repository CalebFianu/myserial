import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_avatar.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../providers/activity_provider.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activityProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: isDark ? AppColors.ink0 : AppColors.paper0,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              topPad + AppSpacing.sp4,
              AppSpacing.pageGutter,
              AppSpacing.sp3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Activity', style: AppTypography.title),
                const SizedBox(height: AppSpacing.sp4),
                SegmentedControl(
                  options: const ['Activity', 'Friends'],
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ],
            ),
          ),
          Expanded(
            child: activityAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.signal),
              ),
              error: (_, __) => Center(
                child: Text('Error loading activity',
                    style: AppTypography.body),
              ),
              data: (data) => _tab == 0
                  ? _MyActivityTab(events: data.myActivity)
                  : _FriendsTab(friends: data.friendActivity),
            ),
          ),
        ],
      ),
    );
  }
}

// ── My Activity Tab ───────────────────────────────────────────────────────────

class _MyActivityTab extends StatelessWidget {
  const _MyActivityTab({required this.events});
  final List<ActivityEvent> events;

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 48, color: AppColors.fg3),
            const SizedBox(height: AppSpacing.sp3),
            Text(
              'No activity yet',
              style: AppTypography.body.copyWith(color: AppColors.fg2),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      itemCount: events.length,
      separatorBuilder: (_, __) => Container(
        height: 1,
        color: isDark ? AppColors.inkLine : AppColors.paperLine,
      ),
      itemBuilder: (context, i) {
        final event = events[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp3),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _typeColor(event.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _typeIcon(event.type),
                  color: _typeColor(event.type),
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.text, style: AppTypography.body),
                    Text(
                      _relativeTime(event.timestamp),
                      style: AppTypography.micro,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _typeColor(ActivityType type) {
    switch (type) {
      case ActivityType.watched:
        return AppColors.track;
      case ActivityType.rated:
        return AppColors.star;
      case ActivityType.added:
        return AppColors.info;
      case ActivityType.completed:
        return AppColors.signal;
      case ActivityType.rewatched:
        return AppColors.fg2;
    }
  }

  IconData _typeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.watched:
        return Icons.check_circle_outline_rounded;
      case ActivityType.rated:
        return Icons.star_outline_rounded;
      case ActivityType.added:
        return Icons.bookmark_add_outlined;
      case ActivityType.completed:
        return Icons.celebration_outlined;
      case ActivityType.rewatched:
        return Icons.repeat_rounded;
    }
  }
}

// ── Friends Tab ───────────────────────────────────────────────────────────────

class _FriendsTab extends StatelessWidget {
  const _FriendsTab({required this.friends});
  final List<FriendActivity> friends;

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      children: [
        // Friends header
        Row(
          children: [
            Expanded(
              child: Text(
                'Friends',
                style: AppTypography.heading,
              ),
            ),
            MsButton(
              label: 'Add friend',
              variant: MsButtonVariant.primary,
              size: MsButtonSize.sm,
              leading: const Icon(Icons.person_add_outlined, size: 14),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sp4),

        // Friend rows (mock)
        ...['Alex', 'Jordan', 'Sam'].map((name) {
          final friend = friends.firstWhere(
            (f) => f.friendName == name,
            orElse: () => FriendActivity(
              friendId: name,
              friendName: name,
              friendAvatarUrl: null,
              showTitle: '',
              episodeCode: '',
              timestamp: DateTime.now(),
            ),
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
            child: Row(
              children: [
                MsAvatar(name: name, size: 44),
                const SizedBox(width: AppSpacing.sp3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTypography.body),
                      Text(
                        friend.showTitle.isNotEmpty
                            ? 'Watching ${friend.showTitle} · ${friend.episodeCode}'
                            : 'No recent activity',
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  _relativeTime(friend.timestamp),
                  style: AppTypography.micro,
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: AppSpacing.sp5),

        // Reviews from friends
        Text('REVIEWS FROM FRIENDS', style: AppTypography.overline),
        const SizedBox(height: AppSpacing.sp3),

        ...friends
            .where((f) => f.review != null)
            .map((friend) => _FriendReviewCard(friend: friend, relTime: _relativeTime(friend.timestamp))),

        const SizedBox(height: AppSpacing.bottomContentPad),
      ],
    );
  }
}

class _FriendReviewCard extends StatelessWidget {
  const _FriendReviewCard({required this.friend, required this.relTime});
  final FriendActivity friend;
  final String relTime;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sp3),
      padding: const EdgeInsets.all(AppSpacing.sp4),
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
          Row(
            children: [
              MsAvatar(
                name: friend.friendName,
                imageUrl: friend.friendAvatarUrl,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.sp2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(friend.friendName, style: AppTypography.captionSemiBold),
                    Text(friend.showTitle, style: AppTypography.micro),
                  ],
                ),
              ),
              Text(
                friend.episodeCode,
                style: AppTypography.codeStyle.copyWith(
                  color: AppColors.signal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          if (friend.rating != null) ...[
            const SizedBox(height: AppSpacing.sp2),
            RatingStars(value: friend.rating!, size: 14),
          ],
          if (friend.review != null) ...[
            const SizedBox(height: AppSpacing.sp2),
            Text(
              friend.review!,
              style: AppTypography.body.copyWith(color: AppColors.fg2),
            ),
          ],
          const SizedBox(height: AppSpacing.sp2),
          Text(relTime, style: AppTypography.micro),
        ],
      ),
    );
  }
}
