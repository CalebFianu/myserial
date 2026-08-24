import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/tmdb_image.dart';

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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      avatarUrl: tmdbImage(json['avatarPath'] as String?),
      bio: json['bio'] as String?,
      episodeCount: json['episodeCount'] as int? ?? 0,
      showCount: json['showCount'] as int? ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble(),
      watchingShows: (json['watchingShows'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(UserShow.fromJson)
          .toList(),
      watchedShows: (json['watchedShows'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(UserShow.fromJson)
          .toList(),
      lists: (json['lists'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(UserList.fromJson)
          .toList(),
      watchlistPosters: (json['watchlistPosters'] as List? ?? [])
          .cast<String?>()
          .map((p) => tmdbImage(p))
          .toList(),
    );
  }
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

  factory UserShow.fromJson(Map<String, dynamic> json) => UserShow(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        posterUrl: tmdbImage(json['posterPath'] as String?),
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        watchedEpisodes: json['watchedEpisodes'] as int? ?? 0,
        totalEpisodes: json['totalEpisodes'] as int? ?? 0,
        status: json['status'] as String?,
      );
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

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        description: null,
        showCount: json['showCount'] as int? ?? 0,
        posterUrls: const [],
      );
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

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    final ep = json['episode'] as Map<String, dynamic>? ?? {};
    final sn = ep['seasonNumber'] as int? ?? 0;
    final en = ep['episodeNumber'] as int? ?? 0;
    return DiaryEntry(
      id: json['id'].toString(),
      showTitle: json['showTitle'] as String? ?? '',
      episodeCode:
          'S${sn.toString().padLeft(2, '0')}E${en.toString().padLeft(2, '0')}',
      watchedAt: DateTime.parse(json['watchedAt'] as String),
      rating: null,
      review: null,
    );
  }
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

  factory UpNextItem.fromJson(Map<String, dynamic> json) {
    final show = json['show'] as Map<String, dynamic>? ?? {};
    final ep = json['nextEpisode'] as Map<String, dynamic>? ?? {};
    final sn = ep['seasonNumber'] as int? ?? 0;
    final en = ep['episodeNumber'] as int? ?? 0;
    return UpNextItem(
      showId: show['id'] as int? ?? 0,
      showTitle: show['title'] as String? ?? '',
      posterUrl: tmdbImage(show['posterPath'] as String?),
      episodeCode:
          'S${sn.toString().padLeft(2, '0')}E${en.toString().padLeft(2, '0')}',
      episodeTitle: ep['name'] as String? ?? '',
      airDate: ep['airDate'] as String?,
      runtime: ep['runtime'] as int?,
    );
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final api = ref.watch(apiClientProvider);
    final data = await api.get<Map<String, dynamic>>('/profile/me');
    return UserProfile.fromJson(data);
  }

  Future<void> updateProfile({String? name, String? bio}) async {
    final api = ref.read(apiClientProvider);
    await api.patch('/profile/me', data: {
      if (name != null) 'name': name,
      if (bio != null) 'bio': bio,
    });
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final diaryProvider = FutureProvider<List<DiaryEntry>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.get<Map<String, dynamic>>('/watch/diary?size=20');
  final content = data['content'] as List? ?? [];
  return content
      .cast<Map<String, dynamic>>()
      .map(DiaryEntry.fromJson)
      .toList();
});

final upNextProvider = FutureProvider<List<UpNextItem>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.get<List<dynamic>>('/watch/up-next');
  return data
      .cast<Map<String, dynamic>>()
      .map(UpNextItem.fromJson)
      .toList();
});
