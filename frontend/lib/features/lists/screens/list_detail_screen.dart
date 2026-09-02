import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_avatar.dart';
import '../../../shared/widgets/ms_toast.dart';
import '../../../shared/widgets/pinned_header.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../providers/lists_provider.dart';
import '../widgets/edit_list_sheet.dart';

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
              pinnedHeader(
                height: topPad + 56,
                background: isDark ? AppColors.ink0 : AppColors.paper0,
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
                      const Spacer(),
                      if (!list.isWatchlist) ...[
                        GestureDetector(
                          onTap: () => _editList(context, ref, list),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.edit_outlined,
                                size: 20, color: AppColors.fg3),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _deleteList(context, ref, list),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.delete_outline_rounded,
                                size: 20, color: AppColors.alertColor),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    AppSpacing.sp4,
                    AppSpacing.pageGutter,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(list.name, style: AppTypography.title),
                      if (list.description != null) ...[
                        const SizedBox(height: AppSpacing.sp2),
                        Text(
                          list.description!,
                          style: AppTypography.body
                              .copyWith(color: AppColors.fg2),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sp2),
                      Text(
                        '${list.shows.length} show${list.shows.length == 1 ? '' : 's'}',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.fg3),
                      ),
                      if (list.collaborators.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sp4),
                        Row(
                          children: list.collaborators
                              .map((c) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: MsAvatar(
                                      name: c.name,
                                      imageUrl: c.avatarUrl,
                                      size: 28,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp5)),

              if (list.shows.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageGutter,
                      vertical: AppSpacing.sp9,
                    ),
                    child: Center(
                      child: Text(
                        'No shows yet',
                        style: AppTypography.body
                            .copyWith(color: AppColors.fg3),
                      ),
                    ),
                  ),
                ),

              // Poster grid
              if (list.shows.isNotEmpty)
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
                          onLongPress: () =>
                              _removeShow(context, ref, list, show),
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

  void _editList(BuildContext context, WidgetRef ref, ListDetail list) async {
    await EditListSheet.show(
      context,
      listId: list.id,
      currentName: list.name,
      currentNote: list.description,
    );
  }

  void _deleteList(
      BuildContext context, WidgetRef ref, ListDetail list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.ink1 : AppColors.paper1,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRR),
          title: Text('Delete list?', style: AppTypography.heading),
          content: Text(
            'This will permanently delete "${list.name}" and remove all its shows.',
            style: AppTypography.body.copyWith(color: AppColors.fg2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel',
                  style: AppTypography.bodySemiBold
                      .copyWith(color: AppColors.fg3)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Delete',
                  style: AppTypography.bodySemiBold
                      .copyWith(color: AppColors.alertColor)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(listsProvider.notifier).deleteList(list.id);
        if (context.mounted) context.pop();
      } catch (_) {
        if (context.mounted) {
          ref.read(toastProvider.notifier).show(
                const ToastData(message: 'Failed to delete list'),
              );
        }
      }
    }
  }

  void _removeShow(BuildContext context, WidgetRef ref, ListDetail list,
      dynamic show) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.ink1 : AppColors.paper1,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRR),
          title: Text('Remove show?', style: AppTypography.heading),
          content: Text(
            'Remove "${show.title}" from this list?',
            style: AppTypography.body.copyWith(color: AppColors.fg2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel',
                  style: AppTypography.bodySemiBold
                      .copyWith(color: AppColors.fg3)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('Remove',
                  style: AppTypography.bodySemiBold
                      .copyWith(color: AppColors.alertColor)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(listDetailProvider(list.id).notifier)
            .removeItem(show.id as int);
      } catch (_) {
        if (context.mounted) {
          ref.read(toastProvider.notifier).show(
                const ToastData(message: 'Failed to remove show'),
              );
        }
      }
    }
  }
}
