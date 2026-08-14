import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.handle,
    this.avatarUrl,
    this.bio,
    this.episodeCount = 0,
    this.showCount = 0,
    this.avgRating,
    this.watchingShows = const [],
    this.watchedShows = const [],
    this.lists = const [],
    this.watchlistPosters = const [],
  });

  final String id;
  final String name;
  final String handle;
  final String? avatarUrl;
  final String? bio;
  final int episodeCount;
  final int showCount;
  final double? avgRating;
  final List<UserShow> watchingShows;
  final List<UserShow> watchedShows;
  final List<UserList> lists;
  final List<String?> watchlistPosters;
}

class UserShow {
  const UserShow({
    required this.id,
    required this.title,
    this.posterUrl,
    this.progress = 0.0,
    this.watchedEpisodes = 0,
    this.totalEpisodes = 0,
    this.status,
  });

  final int id;
  final String title;
  final String? posterUrl;
  final double progress;
  final int watchedEpisodes;
  final int totalEpisodes;
  final String? status;
}

class UserList {
  const UserList({
    required this.id,
    required this.name,
    this.description,
    this.showCount = 0,
    this.posterUrls = const [],
  });

  final String id;
  final String name;
  final String? description;
  final int showCount;
  final List<String?> posterUrls;
}

class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.showTitle,
    required this.episodeCode,
    required this.watchedAt,
    this.rating,
    this.review,
  });

  final String id;
  final String showTitle;
  final String episodeCode;
  final DateTime watchedAt;
  final double? rating;
  final String? review;
}

class UpNextItem {
  const UpNextItem({
    required this.showId,
    required this.showTitle,
    this.posterUrl,
    required this.episodeCode,
    required this.episodeTitle,
    this.airDate,
    this.runtime,
  });

  final int showId;
  final String showTitle;
  final String? posterUrl;
  final String episodeCode;
  final String episodeTitle;
  final String? airDate;
  final int? runtime;
}

// Mock data
final _mockProfile = UserProfile(
  id: 'u1',
  name: 'Caleb Johnson',
  handle: '@caleb',
  bio: 'Peak TV enthusiast. I take my TV too seriously and I\'m not sorry about it.',
  episodeCount: 1240,
  showCount: 47,
  avgRating: 3.8,
  watchingShows: const [
    UserShow(id: 1, title: 'Severance', progress: 0.63, watchedEpisodes: 12, totalEpisodes: 19),
    UserShow(id: 2, title: 'The Bear', progress: 0.5, watchedEpisodes: 10, totalEpisodes: 20),
    UserShow(id: 5, title: 'Slow Horses', progress: 0.83, watchedEpisodes: 25, totalEpisodes: 30),
  ],
  watchedShows: const [
    UserShow(id: 3, title: 'Succession', progress: 1.0, watchedEpisodes: 39, totalEpisodes: 39, status: 'Ended'),
    UserShow(id: 4, title: 'The Wire', progress: 1.0, watchedEpisodes: 60, totalEpisodes: 60, status: 'Ended'),
    UserShow(id: 8, title: 'Fleabag', progress: 1.0, watchedEpisodes: 12, totalEpisodes: 12, status: 'Ended'),
  ],
  lists: const [
    UserList(id: 'l1', name: 'Desert Island Picks', showCount: 8),
    UserList(id: 'l2', name: 'Best Season Finales', showCount: 12),
    UserList(id: 'l3', name: 'Watch with Partner', showCount: 5),
  ],
  watchlistPosters: const [null, null, null, null],
);

final _mockDiary = List.generate(20, (i) {
  final now = DateTime.now();
  return DiaryEntry(
    id: 'entry_$i',
    showTitle: ['Severance', 'The Bear', 'Succession', 'Slow Horses'][i % 4],
    episodeCode: 'S0${(i % 3) + 1}E${(i % 10 + 1).toString().padLeft(2, '0')}',
    watchedAt: now.subtract(Duration(days: i)),
    rating: i % 3 == 0 ? null : 3.5 + (i % 5) * 0.5,
  );
});

final _mockUpNext = const [
  UpNextItem(
    showId: 1,
    showTitle: 'Severance',
    episodeCode: 'S02E07',
    episodeTitle: 'Chikhai Bardo',
    airDate: 'Feb 28, 2025',
    runtime: 52,
  ),
  UpNextItem(
    showId: 2,
    showTitle: 'The Bear',
    episodeCode: 'S03E01',
    episodeTitle: 'Tomorrow',
    runtime: 38,
  ),
  UpNextItem(
    showId: 5,
    showTitle: 'Slow Horses',
    episodeCode: 'S05E02',
    episodeTitle: 'Dead Ends',
    runtime: 46,
  ),
];

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockProfile;
  }
}

final diaryProvider = FutureProvider<List<DiaryEntry>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockDiary;
});

final upNextProvider = FutureProvider<List<UpNextItem>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockUpNext;
});
