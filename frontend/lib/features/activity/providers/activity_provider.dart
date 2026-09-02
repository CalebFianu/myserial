import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

enum ActivityType { watched, rated, added, completed, rewatched }

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.type,
    required this.text,
    required this.timestamp,
    this.showId,
    this.episodeCode,
    this.rating,
    this.showTitle,
  });

  final String id;
  final ActivityType type;
  final String text;
  final DateTime timestamp;
  final int? showId;
  final String? episodeCode;
  final double? rating;
  final String? showTitle;

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    final eventType = json['eventType'] as String? ?? '';
    final showTitle = json['showTitle'] as String?;
    final seasonNumber = json['seasonNumber'] as int?;
    final episodeNumber = json['episodeNumber'] as int?;

    final meta = _decodeMetadata(json['metadata']);
    final metaSeason = meta['seasonNumber'] as int?;
    final episodeCount = meta['episodeCount'] as int?;

    final resolvedSeason = seasonNumber ?? metaSeason;
    final code = (seasonNumber != null && episodeNumber != null)
        ? _episodeCode(seasonNumber, episodeNumber)
        : null;

    return ActivityEvent(
      id: json['id'].toString(),
      type: _mapEventType(eventType),
      text: _buildText(
        eventType,
        showTitle,
        seasonNumber: resolvedSeason,
        episodeNumber: episodeNumber,
        episodeCount: episodeCount,
      ),
      timestamp: DateTime.parse(json['createdAt'] as String),
      showId: json['showId'] as int?,
      episodeCode: code,
      rating: null,
      showTitle: showTitle,
    );
  }

  static Map<String, dynamic> _decodeMetadata(Object? raw) {
    if (raw is Map) return raw.cast<String, dynamic>();
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return decoded.cast<String, dynamic>();
      } catch (_) {
        // ignore malformed metadata
      }
    }
    return const {};
  }

  static String _episodeCode(int season, int episode) =>
      'S${season.toString().padLeft(2, '0')}E${episode.toString().padLeft(2, '0')}';

  static ActivityType _mapEventType(String eventType) {
    switch (eventType) {
      case 'EPISODE_WATCHED':
      case 'EPISODES_WATCHED':
      case 'BINGE_STARTED':
        return ActivityType.watched;
      case 'EPISODE_RATED':
        return ActivityType.rated;
      case 'LIST_ADD':
        return ActivityType.added;
      case 'SEASON_WATCHED':
      case 'SERIES_WATCHED':
        return ActivityType.completed;
      default:
        return ActivityType.watched;
    }
  }

  static String _buildText(
    String eventType,
    String? showTitle, {
    int? seasonNumber,
    int? episodeNumber,
    int? episodeCount,
  }) {
    final title = showTitle ?? 'a show';
    switch (eventType) {
      case 'EPISODE_WATCHED':
        if (seasonNumber != null && episodeNumber != null) {
          return 'Logged ${_episodeCode(seasonNumber, episodeNumber)} of $title';
        }
        return 'Logged an episode of $title';
      case 'EPISODES_WATCHED':
        if (episodeCount != null && seasonNumber != null) {
          final plural = episodeCount == 1 ? 'episode' : 'episodes';
          return 'Logged $episodeCount $plural in season $seasonNumber of $title';
        }
        return 'Logged several episodes of $title';
      case 'EPISODE_RATED':
        if (seasonNumber != null && episodeNumber != null) {
          return 'Rated ${_episodeCode(seasonNumber, episodeNumber)} of $title';
        }
        return 'Rated an episode of $title';
      case 'SEASON_WATCHED':
        if (seasonNumber != null) {
          return 'Caught up on season $seasonNumber of $title';
        }
        return 'Finished a season of $title';
      case 'SERIES_WATCHED':
        return 'Finished $title';
      case 'LIST_ADD':
        return 'Added $title to a list';
      case 'BINGE_STARTED':
        return 'Started tracking $title';
      default:
        return 'Activity on $title';
    }
  }
}

class FriendActivity {
  const FriendActivity({
    required this.friendId,
    required this.friendName,
    required this.friendAvatarUrl,
    required this.showTitle,
    required this.episodeCode,
    required this.timestamp,
    this.review,
    this.rating,
    this.showId,
  });

  final String friendId;
  final String friendName;
  final String? friendAvatarUrl;
  final String showTitle;
  final String episodeCode;
  final DateTime timestamp;
  final String? review;
  final double? rating;
  final int? showId;

  factory FriendActivity.fromJson(Map<String, dynamic> json) {
    final showTitle = json['showTitle'] as String? ?? '';
    return FriendActivity(
      friendId: json['userId'].toString(),
      friendName: json['handle'] as String? ?? '',
      friendAvatarUrl: null,
      showTitle: showTitle,
      episodeCode: showTitle,
      timestamp: DateTime.parse(json['createdAt'] as String),
      review: null,
      rating: null,
      showId: json['showId'] as int?,
    );
  }
}

class ActivityData {
  const ActivityData({
    this.myActivity = const [],
    this.friendActivity = const [],
  });
  final List<ActivityEvent> myActivity;
  final List<FriendActivity> friendActivity;
}

final activityProvider =
    AsyncNotifierProvider<ActivityNotifier, ActivityData>(
  ActivityNotifier.new,
);

class ActivityNotifier extends AsyncNotifier<ActivityData> {
  @override
  Future<ActivityData> build() async {
    final api = ref.watch(apiClientProvider);
    final myFuture =
        api.get<Map<String, dynamic>>('/activity?size=20');
    final friendsFuture =
        api.get<Map<String, dynamic>>('/activity/friends?size=20');
    final results = await Future.wait([myFuture, friendsFuture]);

    final myContent = results[0]['content'] as List? ?? [];
    final friendsContent = results[1]['content'] as List? ?? [];

    final myActivity = myContent
        .cast<Map<String, dynamic>>()
        .map(ActivityEvent.fromJson)
        .toList();
    final friendActivity = friendsContent
        .cast<Map<String, dynamic>>()
        .map(FriendActivity.fromJson)
        .toList();

    return ActivityData(myActivity: myActivity, friendActivity: friendActivity);
  }
}
