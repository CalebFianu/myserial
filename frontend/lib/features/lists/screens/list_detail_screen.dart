import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_avatar.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../providers/lists_provider.dart';

class ListDetailScreen extends ConsumerWidget {
  const ListDetailScreen({super.key, required this.listId});
  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(listDetailProvider(listId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: isDark ? AppColors.ink0 : AppColors.paper0,
      body: listAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (_, __) =>
            Center(child: Text('Error', style: AppTypography.body)),
        data: (list) {
          if (list == null) {
            return Center(
              child: Text('List not found', style: AppTypography.body),
            );
          }

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
                            Text('Lists',
                                style: AppTypography.caption
                                    .copyWith(color: AppColors.fg3)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp4),
                      Text(list.name, style: AppTypography.title),
                      if (list.description != null) ...[
                        const SizedBox(height: AppSpacing.sp2),
                        Text(
                          list.description!,
                          style: AppTypography.body
                              .copyWith(color: AppColors.fg2),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sp4),
                      // Collaborators + invite
                      Row(
                        children: [
                          ...list.collaborators.map((c) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: MsAvatar(
                                  name: c.name,
                                  imageUrl: c.avatarUrl,
                                  size: 28,
                                ),
                              )),
                          MsButton(
                            label: 'Invite',
                            variant: MsButtonVariant.secondary,
                            size: MsButtonSize.sm,
                            leading: const Icon(Icons.person_add_outlined,
                                size: 12),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp5)),

              // Poster grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.sp3,
                    mainAxisSpacing: AppSpacing.sp3,
                    childAspectRatio: 2 / 3,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final show = list.shows[i];
                      return GestureDetector(
                        onTap: () => context.push('/show/${show.id}'),
                        child: Column(
                          children: [
                            Expanded(
                              child: PosterPlaceholder(
                                title: show.title,
                                imageUrl: show.posterUrl,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              show.title,
                              style: AppTypography.micro.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: list.shows.length,
                  ),
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
