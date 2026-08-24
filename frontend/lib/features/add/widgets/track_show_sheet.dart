import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../features/search/providers/search_provider.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/ms_sheet.dart';
import '../../../shared/widgets/poster_placeholder.dart';

class TrackShowSheet extends ConsumerStatefulWidget {
  const TrackShowSheet({super.key});

  @override
  ConsumerState<TrackShowSheet> createState() => _TrackShowSheetState();
}

class _TrackShowSheetState extends ConsumerState<TrackShowSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isStillAiring(String? status) =>
      status == 'Returning' || status == 'Continuing';

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final results = _query.isEmpty ? <ShowResult>[] : searchState.showResults;
    final isLoading = searchState.isLoading;

    return MsSheet(
      title: 'Track a show',
      showHandle: true,
      showCloseButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
            ),
            child: Text(
              'Get notified when a tracked show drops a complete season.',
              style: AppTypography.caption,
            ),
          ),
          const SizedBox(height: AppSpacing.sp3),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                setState(() => _query = v);
                ref.read(searchProvider.notifier).setQuery(v);
              },
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search shows to track...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                          ref.read(searchProvider.notifier).setQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: _query.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sp6),
                      child: Text(
                        'Search for a show to track.',
                        style: AppTypography.body.copyWith(
                          color: AppColors.fg2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.sp6),
                          child: CircularProgressIndicator(
                              color: AppColors.signal),
                        ),
                      )
                    : results.isEmpty
                        ? Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(AppSpacing.sp6),
                              child: Text(
                                'No shows match that.\nTry another title.',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.fg2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageGutter,
                            ),
                            itemCount: results.length,
                            itemBuilder: (context, i) {
                              final show = results[i];
                              final airing = _isStillAiring(show.status);

                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sp3),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 48,
                                      child: PosterPlaceholder(
                                        title: show.title,
                                        imageUrl: show.posterUrl,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sp3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(show.title,
                                              style:
                                                  AppTypography.cardTitle),
                                          Text(
                                            [
                                              if (show.year != null)
                                                show.year!,
                                              if (show.status != null)
                                                show.status!,
                                            ].join(' · '),
                                            style: AppTypography.caption,
                                          ),
                                          if (!airing)
                                            Text(
                                              'No longer airing — nothing left to wait for.',
                                              style:
                                                  AppTypography.micro.copyWith(
                                                color: AppColors.fg3,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (airing)
                                      MsButton(
                                        label: 'Track',
                                        variant: MsButtonVariant.secondary,
                                        size: MsButtonSize.sm,
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
