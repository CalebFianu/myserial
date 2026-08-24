import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/tmdb_image.dart';

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

  factory ContinueWatchingItem.fromJson(Map<String, dynamic> json) {
    final ep = json['nextEpisode'] as Map<String, dynamic>? ?? {};
    final sn = ep['seasonNumber'] as int? ?? 0;
    final en = ep['episodeNumber'] as int? ?? 0;
    return ContinueWatchingItem(
      showId: json['showId'] as int? ?? 0,
      showTitle: json['showTitle'] as String? ?? '',
      posterUrl: tmdbImage(json['posterPath'] as String?),
      episodeCode:
          'S${sn.toString().padLeft(2, '0')}E${en.toString().padLeft(2, '0')}',
      episodeTitle: ep['name'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      watchedCount: json['watchedCount'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }
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

  factory BingeReadyItem.fromJson(Map<String, dynamic> json) =>
      BingeReadyItem(
        showId: json['showId'] as int? ?? 0,
        showTitle: json['title'] as String? ?? '',
        posterUrl: tmdbImage(json['posterPath'] as String?),
        description: json['description'] as String? ?? '',
        seasonCount: 0,
        episodeCount: json['episodeCount'] as int? ?? 0,
      );
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

  factory FriendActivityItem.fromJson(Map<String, dynamic> json) =>
      FriendActivityItem(
        friendName: json['friendName'] as String? ?? '',
        friendAvatarUrl: tmdbImage(json['friendAvatarPath'] as String?),
        showTitle: json['showTitle'] as String? ?? '',
        posterUrl: tmdbImage(json['posterPath'] as String?),
      );
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

  factory HomeData.fromJson(Map<String, dynamic> json) {
    final cwJson = json['continueWatching'] as Map<String, dynamic>?;
    final myShowsList = (json['myShows'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((e) => (
              id: e['id'] as int? ?? 0,
              title: e['title'] as String? ?? '',
              posterUrl: tmdbImage(e['posterPath'] as String?),
            ))
        .toList();
    final bingeList = (json['bingeReady'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(BingeReadyItem.fromJson)
        .toList();
    final friendList = (json['friendActivity'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(FriendActivityItem.fromJson)
        .toList();

    return HomeData(
      continueWatching:
          cwJson != null ? ContinueWatchingItem.fromJson(cwJson) : null,
      myShows: myShowsList,
      bingeReady: bingeList,
      friendActivity: friendList,
      upNextCount: json['upNextCount'] as int? ?? 0,
      diaryCount: json['diaryCount'] as int? ?? 0,
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeData>(
  HomeNotifier.new,
);

class HomeNotifier extends AsyncNotifier<HomeData> {
  @override
  Future<HomeData> build() async {
    final api = ref.watch(apiClientProvider);
    final data = await api.get<Map<String, dynamic>>('/home');
    return HomeData.fromJson(data);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      final data = await api.get<Map<String, dynamic>>('/home');
      return HomeData.fromJson(data);
    });
  }
}
