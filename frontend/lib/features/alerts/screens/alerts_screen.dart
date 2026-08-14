import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_badge.dart';

class _Alert {
  const _Alert({
    required this.id,
    required this.tag,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });
  final String id;
  final String tag;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
}

final _now = DateTime.now();
final _mockAlerts = [
  _Alert(
    id: '1',
    tag: 'BINGE READY',
    title: 'House of the Dragon — Season 2 complete',
    body: 'All 8 episodes of Season 2 are available. Time to binge.',
    timestamp: _now.subtract(const Duration(hours: 2)),
  ),
  _Alert(
    id: '2',
    tag: 'NEW EPISODE',
    title: 'Severance — S02E08 is out',
    body: '"Sweet Vitriol" is now available on Apple TV+.',
    timestamp: _now.subtract(const Duration(hours: 6)),
    isRead: true,
  ),
  _Alert(
    id: '3',
    tag: 'BINGE READY',
    title: 'Andor — Season 2 complete',
    body: 'All 12 episodes of Season 2 are available. No waiting required.',
    timestamp: _now.subtract(const Duration(days: 1)),
    isRead: true,
  ),
  _Alert(
    id: '4',
    tag: 'FRIEND ACTIVITY',
    title: 'Alex finished Succession',
    body: 'Alex just watched the series finale of Succession. No spoilers.',
    timestamp: _now.subtract(const Duration(days: 2)),
    isRead: true,
  ),
  _Alert(
    id: '5',
    tag: 'LEAVING SOON',
    title: 'The Wire leaving Max in 7 days',
    body: 'Add it to your watchlist before it\'s gone.',
    timestamp: _now.subtract(const Duration(days: 3)),
    isRead: true,
  ),
];

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late final List<_Alert> _alerts = List.from(_mockAlerts);

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  MsBadgeVariant _tagVariant(String tag) {
    if (tag.contains('BINGE')) return MsBadgeVariant.signal;
    if (tag.contains('FRIEND')) return MsBadgeVariant.track;
    if (tag.contains('LEAVING')) return MsBadgeVariant.star;
    return MsBadgeVariant.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: isDark ? AppColors.ink0 : AppColors.paper0,
      body: CustomScrollView(
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.fg3,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp3),
                      Expanded(
                        child: Text('Binge alerts', style: AppTypography.title),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp2),
                  Text(
                    'You\'ll be notified when shows you follow drop a complete season.',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp5)),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final alert = _alerts[i];
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
                      color: alert.isRead
                          ? (isDark ? AppColors.ink1 : AppColors.paper1)
                          : (isDark ? AppColors.ink2 : AppColors.paper1),
                      borderRadius: AppRadius.cardRR,
                      border: Border.all(
                        color: alert.isRead
                            ? (isDark ? AppColors.inkLine : AppColors.paperLine)
                            : AppColors.signal.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            MsBadge(
                              label: alert.tag,
                              variant: _tagVariant(alert.tag),
                            ),
                            const Spacer(),
                            if (!alert.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.signal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sp2),
                        Text(alert.title, style: AppTypography.cardTitle),
                        const SizedBox(height: 4),
                        Text(
                          alert.body,
                          style: AppTypography.body.copyWith(
                            color: isDark ? AppColors.fg2 : AppColors.lightFg2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp2),
                        Text(
                          _relativeTime(alert.timestamp),
                          style: AppTypography.micro,
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: _alerts.length,
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.bottomContentPad),
          ),
        ],
      ),
    );
  }
}
