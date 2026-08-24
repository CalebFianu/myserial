package com.myserial.api.dto.response;

import java.util.List;

public record ProfileResponse(
        Long id,
        String name,
        String handle,
        String bio,
        String avatarPath,
        long episodeCount,
        long showCount,
        Double avgRating,
        List<UserShowProgress> watchingShows,
        List<UserShowProgress> watchedShows,
        List<UserListSummary> lists,
        List<String> watchlistPosters
) {
    public record UserShowProgress(
            Long id, String title, String posterPath, String status,
            long watchedEpisodes, long totalEpisodes, double progress
    ) {}

    public record UserListSummary(Long id, String name, long showCount) {}
}
