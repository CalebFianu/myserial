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
    final type = _mapEventType(eventType);
    final text = _buildText(eventType, showTitle);
    return ActivityEvent(
      id: json['id'].toString(),
      type: type,
      text: text,
      timestamp: DateTime.parse(json['createdAt'] as String),
      showId: json['showId'] as int?,
      episodeCode: null,
      rating: null,
      showTitle: showTitle,
    );
  }

  static ActivityType _mapEventType(String eventType) {
    switch (eventType) {
      case 'EPISODE_WATCHED':
        return ActivityType.watched;
      case 'EPISODE_RATED':
        return ActivityType.rated;
      case 'LIST_ADD':
        return ActivityType.added;
      case 'SEASON_WATCHED':
        return ActivityType.completed;
      case 'BINGE_STARTED':
        return ActivityType.watched;
      default:
        return ActivityType.watched;
    }
  }

  static String _buildText(String eventType, String? showTitle) {
    final title = showTitle ?? 'a show';
    switch (eventType) {
      case 'EPISODE_WATCHED':
        return 'Watched an episode of $title';
      case 'EPISODE_RATED':
        return 'Rated an episode of $title';
      case 'LIST_ADD':
        return 'Added $title to a list';
      case 'SEASON_WATCHED':
        return 'Finished a season of $title';
      case 'BINGE_STARTED':
        return 'Started watching $title';
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
