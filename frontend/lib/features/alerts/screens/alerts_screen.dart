import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_badge.dart';
import '../providers/alerts_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _deriveTag(AlertItem alert) {
    final title = alert.title.toLowerCase();
    final body = (alert.body ?? '').toLowerCase();
    if (title.contains('complete') ||
        title.contains('binge') ||
        body.contains('binge')) {
      return 'BINGE READY';
    }
    if (title.contains('new episode') ||
        title.contains('s0') ||
        RegExp(r's\d{2}e\d{2}').hasMatch(title)) {
      return 'NEW EPISODE';
    }
    if (title.contains('leaving') || body.contains('leaving')) {
      return 'LEAVING SOON';
    }
    if (title.contains('friend') || body.contains('friend')) {
      return 'FRIEND ACTIVITY';
    }
    return 'ALERT';
  }

  MsBadgeVariant _tagVariant(String tag) {
    if (tag.contains('BINGE')) return MsBadgeVariant.signal;
    if (tag.contains('FRIEND')) return MsBadgeVariant.track;
    if (tag.contains('LEAVING')) return MsBadgeVariant.star;
    return MsBadgeVariant.neutral;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);
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
                        child:
                            Text('Binge alerts', style: AppTypography.title),
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

          alertsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sp6),
                  child: CircularProgressIndicator(color: AppColors.signal),
                ),
              ),
            ),
            error: (_, __) => SliverToBoxAdapter(
              child: Center(
                child: Text('Error loading alerts', style: AppTypography.body),
              ),
            ),
            data: (alerts) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final alert = alerts[i];
                  final tag = _deriveTag(alert);
                  return GestureDetector(
                    onTap: () {
                      if (!alert.isRead) {
                        ref
                            .read(alertsProvider.notifier)
                            .markRead(alert.id);
                      }
                    },
                    child: Padding(
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
                                ? (isDark
                                    ? AppColors.inkLine
                                    : AppColors.paperLine)
                                : AppColors.signal.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                MsBadge(
                                  label: tag,
                                  variant: _tagVariant(tag),
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
                            if (alert.body != null &&
                                alert.body!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                alert.body!,
                                style: AppTypography.body.copyWith(
                                  color: isDark
                                      ? AppColors.fg2
                                      : AppColors.lightFg2,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sp2),
                            Text(
                              _relativeTime(alert.createdAt),
                              style: AppTypography.micro,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: alerts.length,
              ),
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
