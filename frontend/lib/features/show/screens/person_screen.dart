import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_avatar.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../providers/show_provider.dart';

class PersonScreen extends ConsumerWidget {
  const PersonScreen({super.key, required this.personId});
  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personAsync = ref.watch(personProvider(personId));
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.ink0,
      body: personAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (_, __) => Center(
          child: Text('Error loading person', style: AppTypography.body),
        ),
        data: (person) => CustomScrollView(
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
                          Text('Back',
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.fg3)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp5),
                    Row(
                      children: [
                        MsAvatar(
                          name: person.name,
                          imageUrl: person.avatarUrl,
                          size: 72,
                        ),
                        const SizedBox(width: AppSpacing.sp4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(person.name, style: AppTypography.title),
                            if (person.role != null)
                              Text(person.role!, style: AppTypography.caption),
                          ],
                        ),
                      ],
                    ),
                    if (person.bio != null && person.bio!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sp4),
                      Text(
                        person.bio!,
                        style:
                            AppTypography.body.copyWith(color: AppColors.fg2),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp6)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                child: Text('KNOWN FOR', style: AppTypography.overline),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp3)),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final credit = person.credits[i];
                  return GestureDetector(
                    onTap: () => context.push('/show/${credit.showId}'),
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
                            width: 56,
                            child: PosterPlaceholder(
                              title: credit.showTitle,
                              imageUrl: credit.posterUrl,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  credit.showTitle,
                                  style: AppTypography.cardTitle,
                                ),
                                if (credit.character != null &&
                                    credit.character!.isNotEmpty)
                                  Text(
                                    credit.character!,
                                    style: AppTypography.caption,
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.fg3, size: 18),
                        ],
                      ),
                    ),
                  );
                },
                childCount: person.credits.length,
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
