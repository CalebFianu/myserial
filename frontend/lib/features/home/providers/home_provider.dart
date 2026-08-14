import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class ContinueWatchingItem {
  const ContinueWatchingItem({
    required this.showId,
    required this.showTitle,
    required this.posterUrl,
    required this.episodeCode,
    required this.episodeTitle,
    required this.progress,
    required this.watchedCount,
    required this.totalCount,
  });

  final int showId;
  final String showTitle;
  final String? posterUrl;
  final String episodeCode;
  final String episodeTitle;
  final double progress;
  final int watchedCount;
  final int totalCount;
}

class BingeReadyItem {
  const BingeReadyItem({
    required this.showId,
    required this.showTitle,
    required this.posterUrl,
    required this.description,
    required this.seasonCount,
    required this.episodeCount,
  });

  final int showId;
  final String showTitle;
  final String? posterUrl;
  final String description;
  final int seasonCount;
  final int episodeCount;
}

class FriendActivityItem {
  const FriendActivityItem({
    required this.friendName,
    required this.friendAvatarUrl,
    required this.showTitle,
    required this.posterUrl,
  });

  final String friendName;
  final String? friendAvatarUrl;
  final String showTitle;
  final String? posterUrl;
}

class HomeData {
  const HomeData({
    this.continueWatching,
    this.myShows = const [],
    this.bingeReady = const [],
    this.friendActivity = const [],
    this.upNextCount = 0,
    this.diaryCount = 0,
  });

  final ContinueWatchingItem? continueWatching;
  final List<({int id, String title, String? posterUrl})> myShows;
  final List<BingeReadyItem> bingeReady;
  final List<FriendActivityItem> friendActivity;
  final int upNextCount;
  final int diaryCount;
}

// ── Mock data ─────────────────────────────────────────────────────────────────

final _mockHomeData = HomeData(
  continueWatching: const ContinueWatchingItem(
    showId: 1,
    showTitle: 'Severance',
    posterUrl: '',
    episodeCode: 'S02E04',
    episodeTitle: 'Woe\'s Hollow',
    progress: 0.6,
    watchedCount: 6,
    totalCount: 10,
  ),
  myShows: const [
    (id: 1, title: 'Severance', posterUrl: null),
    (id: 2, title: 'The Bear', posterUrl: null),
    (id: 3, title: 'Succession', posterUrl: null),
    (id: 4, title: 'The Wire', posterUrl: null),
    (id: 5, title: 'Slow Horses', posterUrl: null),
  ],
  bingeReady: const [
    BingeReadyItem(
      showId: 6,
      showTitle: 'House of the Dragon',
      posterUrl: null,
      description: 'Season 2 is complete — 8 episodes ready to binge.',
      seasonCount: 2,
      episodeCount: 8,
    ),
    BingeReadyItem(
      showId: 7,
      showTitle: 'Andor',
      posterUrl: null,
      description: 'Both seasons available — 24 episodes total.',
      seasonCount: 2,
      episodeCount: 24,
    ),
  ],
  friendActivity: const [
    FriendActivityItem(
      friendName: 'Alex',
      friendAvatarUrl: null,
      showTitle: 'The Bear',
      posterUrl: null,
    ),
    FriendActivityItem(
      friendName: 'Jordan',
      friendAvatarUrl: null,
      showTitle: 'White Lotus',
      posterUrl: null,
    ),
    FriendActivityItem(
      friendName: 'Sam',
      friendAvatarUrl: null,
      showTitle: 'Succession',
      posterUrl: null,
    ),
  ],
  upNextCount: 12,
  diaryCount: 47,
);

// ── Provider ──────────────────────────────────────────────────────────────────

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeData>(
  HomeNotifier.new,
);

class HomeNotifier extends AsyncNotifier<HomeData> {
  @override
  Future<HomeData> build() async {
    // In production, fetch from API
    // final api = ref.watch(apiClientProvider);
    // return api.get('/home', fromJson: HomeData.fromJson);
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockHomeData;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockHomeData;
    });
  }
}
