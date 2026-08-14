import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/colors.dart';
import '../../../design/spacing.dart';
import '../../../design/typography.dart';
import '../../../shared/widgets/ms_avatar.dart';
import '../../../shared/widgets/poster_placeholder.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: isDark ? AppColors.ink0 : AppColors.paper0,
      body: Column(
        children: [
          // Header area
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              topPad + AppSpacing.sp4,
              AppSpacing.pageGutter,
              AppSpacing.sp3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search', style: AppTypography.title),
                const SizedBox(height: AppSpacing.sp4),
                // Search field
                TextField(
                  controller: _ctrl,
                  onChanged: (v) =>
                      ref.read(searchProvider.notifier).setQuery(v),
                  decoration: InputDecoration(
                    hintText: 'Shows, cast, crew...',
                    prefixIcon: state.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.search_rounded),
                    suffixIcon: state.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _ctrl.clear();
                              ref
                                  .read(searchProvider.notifier)
                                  .setQuery('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp3),
                // Segmented control
                SegmentedControl(
                  options: const ['Shows', 'Cast & crew'],
                  selectedIndex: state.tab.index,
                  onChanged: (i) => ref
                      .read(searchProvider.notifier)
                      .setTab(SearchTab.values[i]),
                ),
              ],
            ),
          ),

          // Results header
          if (state.query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                0,
                AppSpacing.pageGutter,
                AppSpacing.sp3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.tab == SearchTab.shows
                          ? '${state.showResults.length} SHOWS'
                          : '${state.peopleResults.length} PEOPLE',
                      style: AppTypography.overline,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      state.isGrid
                          ? Icons.grid_view_rounded
                          : Icons.view_list_rounded,
                      size: 20,
                      color: AppColors.fg3,
                    ),
                    onPressed: () =>
                        ref.read(searchProvider.notifier).toggleLayout(),
                  ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: state.query.isEmpty
                ? _EmptySearchState()
                : state.tab == SearchTab.shows
                    ? _ShowResults(
                        results: state.showResults,
                        isGrid: state.isGrid,
                      )
                    : _PeopleResults(
                        results: state.peopleResults,
                        isGrid: state.isGrid,
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 48,
            color: AppColors.fg3,
          ),
          const SizedBox(height: AppSpacing.sp3),
          Text(
            'Search for shows,\ncast & crew',
            style: AppTypography.body.copyWith(color: AppColors.fg2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ShowResults extends ConsumerWidget {
  const _ShowResults({required this.results, required this.isGrid});
  final List<ShowResult> results;
  final bool isGrid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No shows match that.\nTry another title.',
          style: AppTypography.body.copyWith(color: AppColors.fg2),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageGutter,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.sp3,
          mainAxisSpacing: AppSpacing.sp3,
          childAspectRatio: 0.62,
        ),
        itemCount: results.length,
        itemBuilder: (context, i) {
          final show = results[i];
          return GestureDetector(
            onTap: () => context.push('/show/${show.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                if (show.year != null)
                  Text(show.year!, style: AppTypography.micro),
              ],
            ),
          );
        },
      );
    }

    // List view
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageGutter,
      ),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final show = results[i];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return GestureDetector(
          onTap: () => context.push('/show/${show.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sp3),
            padding: const EdgeInsets.all(AppSpacing.sp3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.ink1 : AppColors.paper1,
              borderRadius: AppRadius.cardRR,
              border: Border.all(
                color: isDark ? AppColors.inkLine : AppColors.paperLine,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
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
                      Text(show.title, style: AppTypography.cardTitle),
                      Text(
                        [
                          if (show.year != null) show.year!,
                          if (show.status != null) show.status!,
                        ].join(' · '),
                        style: AppTypography.caption,
                      ),
                      if (show.overview != null)
                        Text(
                          show.overview!,
                          style: AppTypography.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.fg3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PeopleResults extends StatelessWidget {
  const _PeopleResults({required this.results, required this.isGrid});
  final List<PersonResult> results;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No people found.',
          style: AppTypography.body.copyWith(color: AppColors.fg2),
        ),
      );
    }

    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageGutter,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.sp3,
          mainAxisSpacing: AppSpacing.sp3,
        ),
        itemCount: results.length,
        itemBuilder: (context, i) {
          final person = results[i];
          return GestureDetector(
            onTap: () => context.push('/person/${person.id}'),
            child: Column(
              children: [
                MsAvatar(
                  name: person.name,
                  imageUrl: person.avatarUrl,
                  size: 72,
                ),
                const SizedBox(height: 6),
                Text(
                  person.name,
                  style: AppTypography.micro.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (person.knownFor != null)
                  Text(
                    person.knownFor!,
                    style: AppTypography.micro,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          );
        },
      );
    }

    // List view
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageGutter,
      ),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final person = results[i];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return GestureDetector(
          onTap: () => context.push('/person/${person.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sp3),
            padding: const EdgeInsets.all(AppSpacing.sp3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.ink1 : AppColors.paper1,
              borderRadius: AppRadius.cardRR,
              border: Border.all(
                color: isDark ? AppColors.inkLine : AppColors.paperLine,
              ),
            ),
            child: Row(
              children: [
                MsAvatar(
                  name: person.name,
                  imageUrl: person.avatarUrl,
                  size: 48,
                ),
                const SizedBox(width: AppSpacing.sp3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(person.name, style: AppTypography.cardTitle),
                      if (person.knownFor != null)
                        Text(person.knownFor!, style: AppTypography.caption),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.fg3),
              ],
            ),
          ),
        );
      },
    );
  }
}
