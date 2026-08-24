import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_button.dart';
import '../providers/lists_provider.dart';
import '../widgets/create_list_sheet.dart';

class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: isDark ? AppColors.ink0 : AppColors.paper0,
      body: listsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
        error: (_, __) =>
            Center(child: Text('Error', style: AppTypography.body)),
        data: (lists) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageGutter,
                  topPad + AppSpacing.sp4,
                  AppSpacing.pageGutter,
                  0,
                ),
                child: Row(
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
                      child: Text('Lists', style: AppTypography.title),
                    ),
                    MsButton(
                      label: 'New list',
                      variant: MsButtonVariant.secondary,
                      size: MsButtonSize.sm,
                      leading: const Icon(Icons.add_rounded, size: 14),
                      onPressed: () async {
                        final created = await CreateListSheet.show(context);
                        if (created != null && context.mounted) {
                          context.push('/lists/${created.id}');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp5)),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final list = lists[i];
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
                            color: isDark
                                ? AppColors.inkLine
                                : AppColors.paperLine,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(list.name,
                                      style: AppTypography.heading),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.fg3,
                                  size: 18,
                                ),
                              ],
                            ),
                            if (list.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                list.description!,
                                style: AppTypography.caption,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sp2),
                            Text(
                              '${list.shows.length} shows',
                              style: AppTypography.micro.copyWith(
                                color: AppColors.signal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: lists.length,
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
