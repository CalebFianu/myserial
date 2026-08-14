import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_avatar.dart';
import '../../../shared/widgets/poster_placeholder.dart';

class _PersonCredit {
  const _PersonCredit({
    required this.showId,
    required this.showTitle,
    this.posterUrl,
    required this.character,
    this.years,
    this.episodeCount,
  });
  final int showId;
  final String showTitle;
  final String? posterUrl;
  final String character;
  final String? years;
  final int? episodeCount;
}

// Mock data
List<_PersonCredit> _mockCredits(int personId) => const [
      _PersonCredit(
        showId: 1,
        showTitle: 'Severance',
        character: 'Mark S.',
        years: '2022–',
        episodeCount: 19,
      ),
      _PersonCredit(
        showId: 8,
        showTitle: 'Parks and Recreation',
        character: 'Ben Wyatt',
        years: '2010–2015',
        episodeCount: 125,
      ),
      _PersonCredit(
        showId: 9,
        showTitle: 'Party Down',
        character: 'Henry Pollard',
        years: '2009–2023',
        episodeCount: 21,
      ),
    ];

class PersonScreen extends StatelessWidget {
  const PersonScreen({super.key, required this.personId});
  final int personId;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    // Mock person data
    const name = 'Adam Scott';
    const role = 'Actor';
    const bio =
        'Adam Paul Scott is an American actor and producer best known for his role as Ben Wyatt in Parks and Recreation and Mark Scout in Severance.';
    final credits = _mockCredits(personId);

    return Scaffold(
      backgroundColor: AppColors.ink0,
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
                      MsAvatar(name: name, size: 72),
                      const SizedBox(width: AppSpacing.sp4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTypography.title),
                          Text(role, style: AppTypography.caption),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                  Text(
                    bio,
                    style: AppTypography.body.copyWith(color: AppColors.fg2),
                  ),
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
                final credit = credits[i];
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
                              Text(
                                credit.character,
                                style: AppTypography.caption,
                              ),
                              if (credit.years != null ||
                                  credit.episodeCount != null)
                                Text(
                                  [
                                    if (credit.years != null) credit.years!,
                                    if (credit.episodeCount != null)
                                      '${credit.episodeCount} eps',
                                  ].join(' · '),
                                  style: AppTypography.micro,
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
              childCount: credits.length,
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
