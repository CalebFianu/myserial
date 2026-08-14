import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

// ── Models ────────────────────────────────────────────────────────────────────

enum SearchTab { shows, people }

class ShowResult {
  const ShowResult({
    required this.id,
    required this.title,
    this.posterUrl,
    this.year,
    this.status,
    this.overview,
    this.voteAverage,
  });
  final int id;
  final String title;
  final String? posterUrl;
  final String? year;
  final String? status;
  final String? overview;
  final double? voteAverage;
}

class PersonResult {
  const PersonResult({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.knownFor,
  });
  final int id;
  final String name;
  final String? avatarUrl;
  final String? knownFor;
}

class SearchState {
  const SearchState({
    this.query = '',
    this.tab = SearchTab.shows,
    this.showResults = const [],
    this.peopleResults = const [],
    this.isLoading = false,
    this.isGrid = true,
  });

  final String query;
  final SearchTab tab;
  final List<ShowResult> showResults;
  final List<PersonResult> peopleResults;
  final bool isLoading;
  final bool isGrid;

  SearchState copyWith({
    String? query,
    SearchTab? tab,
    List<ShowResult>? showResults,
    List<PersonResult>? peopleResults,
    bool? isLoading,
    bool? isGrid,
  }) =>
      SearchState(
        query: query ?? this.query,
        tab: tab ?? this.tab,
        showResults: showResults ?? this.showResults,
        peopleResults: peopleResults ?? this.peopleResults,
        isLoading: isLoading ?? this.isLoading,
        isGrid: isGrid ?? this.isGrid,
      );
}

// Mock results
List<ShowResult> _mockShowResults(String q) => [
      ShowResult(id: 1, title: 'Breaking Bad', year: '2008', status: 'Ended', overview: 'A chemistry teacher turned drug lord.', voteAverage: 4.5),
      ShowResult(id: 2, title: 'Better Call Saul', year: '2015', status: 'Ended', overview: 'Prequel to Breaking Bad.', voteAverage: 4.3),
      ShowResult(id: 3, title: 'The Wire', year: '2002', status: 'Ended', overview: 'Baltimore crime drama.', voteAverage: 4.8),
      ShowResult(id: 4, title: 'Succession', year: '2018', status: 'Ended', overview: 'A powerful family fights for control.', voteAverage: 4.6),
      ShowResult(id: 5, title: 'Severance', year: '2022', status: 'Returning', overview: 'Work-life balance taken to an extreme.', voteAverage: 4.7),
      ShowResult(id: 6, title: 'The Bear', year: '2022', status: 'Returning', overview: 'A chef returns to run his family restaurant.', voteAverage: 4.5),
    ].where((s) => q.isEmpty || s.title.toLowerCase().contains(q.toLowerCase())).toList();

List<PersonResult> _mockPeopleResults(String q) => [
      PersonResult(id: 1, name: 'Bryan Cranston', knownFor: 'Breaking Bad'),
      PersonResult(id: 2, name: 'Jeremy Allen White', knownFor: 'The Bear'),
      PersonResult(id: 3, name: 'Sarah Snook', knownFor: 'Succession'),
      PersonResult(id: 4, name: 'Adam Scott', knownFor: 'Severance'),
    ].where((p) => q.isEmpty || p.name.toLowerCase().contains(q.toLowerCase())).toList();

// ── Provider ──────────────────────────────────────────────────────────────────

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(ref),
);

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._ref) : super(const SearchState());
  final Ref _ref;

  void setQuery(String query) {
    state = state.copyWith(query: query, isLoading: true);
    _debounce(query);
  }

  DateTime? _lastSearch;
  Future<void> _debounce(String query) async {
    final now = DateTime.now();
    _lastSearch = now;
    await Future.delayed(const Duration(milliseconds: 350));
    if (_lastSearch != now) return; // superseded
    _search(query);
  }

  void _search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(
        showResults: [],
        peopleResults: [],
        isLoading: false,
      );
      return;
    }
    // Mock — replace with API call
    state = state.copyWith(
      showResults: _mockShowResults(query),
      peopleResults: _mockPeopleResults(query),
      isLoading: false,
    );
  }

  void setTab(SearchTab tab) => state = state.copyWith(tab: tab);

  void toggleLayout() =>
      state = state.copyWith(isGrid: !state.isGrid);
}
