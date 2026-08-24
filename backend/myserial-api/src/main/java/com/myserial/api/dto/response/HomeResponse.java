package com.myserial.api.dto.response;

import java.util.List;

public record HomeResponse(
        ContinueWatchingItem continueWatching,
        List<MyShowItem> myShows,
        List<BingeReadyItem> bingeReady,
        List<FriendActivityItem> friendActivity,
        int upNextCount,
        long diaryCount
) {
    public record ContinueWatchingItem(
            Long showId, String showTitle, String posterPath,
            EpisodeResponse nextEpisode, long watchedCount, long totalCount, double progress
    ) {}

    public record MyShowItem(Long id, String title, String posterPath) {}

    public record BingeReadyItem(
            Long showId, String title, String posterPath,
            String description, int episodeCount
    ) {}

    public record FriendActivityItem(
            String friendName, String friendAvatarPath,
            String showTitle, String posterPath
    ) {}
}
