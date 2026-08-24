import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/ms_sheet.dart';
import '../../../shared/widgets/ms_toast.dart';
import '../providers/lists_provider.dart';
import 'create_list_sheet.dart';

class AddToListSheet extends ConsumerWidget {
  const AddToListSheet({super.key, required this.showId, required this.showTitle});

  final int showId;
  final String showTitle;

  static Future<void> show(BuildContext context,
      {required int showId, required String showTitle}) {
    return MsSheet.show(
      context,
      title: 'Add to list',
      child: AddToListSheet(showId: showId, showTitle: showTitle),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);

    return listsAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.signal),
        ),
      ),
      error: (_, __) => SizedBox(
        height: 120,
        child: Center(
          child: Text('Failed to load lists', style: AppTypography.body),
        ),
      ),
      data: (lists) {
        // Filter to custom lists only (exclude watchlist)
        final customLists = lists.where((l) => !l.isWatchlist).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (customLists.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp6),
                  child: Center(
                    child: Text(
                      'No custom lists yet',
                      style:
                          AppTypography.body.copyWith(color: AppColors.fg3),
                    ),
                  ),
                ),
              ...customLists.map((list) {
                final alreadyIn =
                    list.shows.any((s) => s.id == showId);
                return _ListRow(
                  list: list,
                  alreadyIn: alreadyIn,
                  onToggle: () async {
                    try {
                      if (alreadyIn) {
                        await ref
                            .read(listsProvider.notifier)
                            .removeItem(list.id, showId);
                        if (context.mounted) {
                          ref.read(toastProvider.notifier).show(
                                ToastData(
                                    message:
                                        'Removed from ${list.name}'),
                              );
                        }
                      } else {
                        await ref
                            .read(listsProvider.notifier)
                            .addItem(list.id, showId);
                        if (context.mounted) {
                          ref.read(toastProvider.notifier).show(
                                ToastData(
                                    message:
                                        'Added to ${list.name}'),
                              );
                        }
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ref.read(toastProvider.notifier).show(
                              const ToastData(message: 'Something went wrong'),
                            );
                      }
                    }
                  },
                );
              }),
              const SizedBox(height: AppSpacing.sp3),
              MsButton(
                label: 'New list',
                variant: MsButtonVariant.secondary,
                fullWidth: true,
                leading: const Icon(Icons.add_rounded, size: 16),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (context.mounted) {
                    await CreateListSheet.show(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.list,
    required this.alreadyIn,
    required this.onToggle,
  });

  final ListDetail list;
  final bool alreadyIn;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp3),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: alreadyIn
                    ? AppColors.signal
                    : (isDark ? AppColors.ink2 : AppColors.paper0),
                borderRadius: BorderRadius.circular(6),
                border: alreadyIn
                    ? null
                    : Border.all(
                        color:
                            isDark ? AppColors.inkLine : AppColors.paperLine,
                      ),
              ),
              child: alreadyIn
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSpacing.sp3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(list.name, style: AppTypography.body),
                  Text(
                    '${list.shows.length} show${list.shows.length == 1 ? '' : 's'}',
                    style: AppTypography.caption.copyWith(color: AppColors.fg3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
