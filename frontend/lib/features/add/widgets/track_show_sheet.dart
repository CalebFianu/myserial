import 'package:flutter/material.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_button.dart';
import '../../../shared/widgets/ms_sheet.dart';
import '../../../shared/widgets/poster_placeholder.dart';

const _trackableShows = [
  (id: 1, title: 'Severance', year: '2022–', status: 'Returning', posterUrl: ''),
  (id: 6, title: 'House of the Dragon', year: '2022–', status: 'Returning', posterUrl: ''),
  (id: 7, title: 'Andor', year: '2022–', status: 'Returning', posterUrl: ''),
  (id: 12, title: 'The Last of Us', year: '2023–', status: 'Returning', posterUrl: ''),
  (id: 13, title: 'Dune: Prophecy', year: '2024–', status: 'Returning', posterUrl: ''),
  // Ended shows
  (id: 3, title: 'Succession', year: '2018–2023', status: 'Ended', posterUrl: ''),
  (id: 4, title: 'Breaking Bad', year: '2008–2013', status: 'Cancelled', posterUrl: ''),
];

class TrackShowSheet extends StatefulWidget {
  const TrackShowSheet({super.key});

  @override
  State<TrackShowSheet> createState() => _TrackShowSheetState();
}

class _TrackShowSheetState extends State<TrackShowSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List get _filtered => _trackableShows
      .where((s) =>
          _query.isEmpty ||
          s.title.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  bool _isStillAiring(String status) =>
      status == 'Returning' || status == 'Continuing';

  @override
  Widget build(BuildContext context) {
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
              onChanged: (v) => setState(() => _query = v),
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
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: _filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sp6),
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
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final show = _filtered[i];
                      final airing = _isStillAiring(show.status);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sp3),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(show.title,
                                      style: AppTypography.cardTitle),
                                  Text(
                                    '${show.year} · ${show.status}',
                                    style: AppTypography.caption,
                                  ),
                                  if (!airing)
                                    Text(
                                      'No longer airing — nothing left to wait for.',
                                      style: AppTypography.micro.copyWith(
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
