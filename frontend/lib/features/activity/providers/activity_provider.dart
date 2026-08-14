import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

class ActivityData {
  const ActivityData({
    this.myActivity = const [],
    this.friendActivity = const [],
  });
  final List<ActivityEvent> myActivity;
  final List<FriendActivity> friendActivity;
}

final _now = DateTime.now();

final _mockActivity = ActivityData(
  myActivity: [
    ActivityEvent(
      id: '1',
      type: ActivityType.watched,
      text: 'Watched S02E04 of Severance',
      timestamp: _now.subtract(const Duration(hours: 2)),
      showId: 1,
      episodeCode: 'S02E04',
      showTitle: 'Severance',
    ),
    ActivityEvent(
      id: '2',
      type: ActivityType.rated,
      text: 'Rated Severance S02E04 ★ 4.5',
      timestamp: _now.subtract(const Duration(hours: 2, minutes: 5)),
      showId: 1,
      episodeCode: 'S02E04',
      rating: 4.5,
      showTitle: 'Severance',
    ),
    ActivityEvent(
      id: '3',
      type: ActivityType.watched,
      text: 'Watched S02E03 of Severance',
      timestamp: _now.subtract(const Duration(days: 1)),
      showId: 1,
      episodeCode: 'S02E03',
      showTitle: 'Severance',
    ),
    ActivityEvent(
      id: '4',
      type: ActivityType.added,
      text: 'Added House of the Dragon to watchlist',
      timestamp: _now.subtract(const Duration(days: 2)),
    ),
    ActivityEvent(
      id: '5',
      type: ActivityType.completed,
      text: 'Finished watching The Bear — Season 2',
      timestamp: _now.subtract(const Duration(days: 4)),
    ),
  ],
  friendActivity: [
    FriendActivity(
      friendId: 'a1',
      friendName: 'Alex',
      friendAvatarUrl: null,
      showTitle: 'The Bear',
      episodeCode: 'S02E07',
      timestamp: _now.subtract(const Duration(hours: 1)),
      rating: 5.0,
      review: 'This season is absolutely phenomenal. Every episode is better than the last.',
      showId: 2,
    ),
    FriendActivity(
      friendId: 'j1',
      friendName: 'Jordan',
      friendAvatarUrl: null,
      showTitle: 'White Lotus',
      episodeCode: 'S03E04',
      timestamp: _now.subtract(const Duration(hours: 5)),
      rating: 4.0,
      showId: 3,
    ),
    FriendActivity(
      friendId: 's1',
      friendName: 'Sam',
      friendAvatarUrl: null,
      showTitle: 'Succession',
      episodeCode: 'S04E09',
      timestamp: _now.subtract(const Duration(days: 1)),
      rating: 4.5,
      review: '"Connor\'s Wedding" is one of the greatest TV episodes ever made.',
      showId: 4,
    ),
  ],
);

final activityProvider =
    AsyncNotifierProvider<ActivityNotifier, ActivityData>(
  ActivityNotifier.new,
);

class ActivityNotifier extends AsyncNotifier<ActivityData> {
  @override
  Future<ActivityData> build() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockActivity;
  }
}
