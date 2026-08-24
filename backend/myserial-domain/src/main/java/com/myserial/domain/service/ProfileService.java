package com.myserial.domain.service;

import com.myserial.domain.entity.*;
import com.myserial.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final UserRepository userRepository;
    private final StatsService statsService;
    private final WatchedEpisodeRepository watchedEpisodeRepository;
    private final EpisodeRepository episodeRepository;
    private final BingeTrackRepository bingeTrackRepository;
    private final UserListRepository userListRepository;

    @Transactional(readOnly = true)
    public ProfileData getProfile(Long userId) {
        User user = userRepository.findById(userId).orElseThrow();

        StatsService.Stats stats = statsService.getStats(userId);

        List<BingeTrack> tracks = bingeTrackRepository.findByUserId(userId);
        List<ShowProgress> allProgress = tracks.stream()
                .map(t -> {
                    Show show = t.getShow();
                    long watched = watchedEpisodeRepository.countByUserIdAndEpisodeShowId(userId, show.getId());
                    long total = episodeRepository.countByShowId(show.getId());
                    double progress = total > 0 ? (double) watched / total : 0.0;
                    return new ShowProgress(show, watched, total, progress);
                })
                .toList();

        List<ShowProgress> watchingShows = allProgress.stream()
                .filter(s -> s.progress() < 1.0 || s.totalEpisodes() == 0)
                .toList();

        List<ShowProgress> watchedShows = allProgress.stream()
                .filter(s -> s.progress() >= 1.0 && s.totalEpisodes() > 0)
                .toList();

        double sumRatings = stats.ratingsHistogram().entrySet().stream()
                .mapToDouble(e -> Double.parseDouble(e.getKey()) * e.getValue())
                .sum();
        long totalRatings = stats.ratingsHistogram().values().stream().mapToLong(Long::longValue).sum();
        Double avgRating = totalRatings > 0 ? sumRatings / totalRatings : null;

        List<UserList> lists = userListRepository.findByUserIdAndIsWatchlistFalseOrderByCreatedAtDesc(userId);

        UserList watchlist = userListRepository.findByUserIdAndIsWatchlistTrue(userId).orElse(null);
        List<String> watchlistPosters = watchlist != null && watchlist.getItems() != null
                ? watchlist.getItems().stream()
                        .limit(4)
                        .map(item -> item.getShow().getPosterPath())
                        .filter(p -> p != null)
                        .toList()
                : List.of();

        return new ProfileData(user, stats.episodesWatched(), (long) tracks.size(), avgRating,
                watchingShows, watchedShows, lists, watchlistPosters);
    }

    public record ProfileData(
            User user,
            long episodeCount,
            long showCount,
            Double avgRating,
            List<ShowProgress> watchingShows,
            List<ShowProgress> watchedShows,
            List<UserList> lists,
            List<String> watchlistPosters
    ) {}

    public record ShowProgress(Show show, long watchedEpisodes, long totalEpisodes, double progress) {}
}
