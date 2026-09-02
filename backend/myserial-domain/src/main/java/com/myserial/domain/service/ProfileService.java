package com.myserial.domain.service;

import com.myserial.domain.entity.*;
import com.myserial.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final UserRepository userRepository;
    private final StatsService statsService;
    private final WatchedEpisodeRepository watchedEpisodeRepository;
    private final EpisodeRepository episodeRepository;
    private final BingeTrackRepository bingeTrackRepository;
    private final UserListRepository userListRepository;
    private final ShowRepository showRepository;

    @Transactional(readOnly = true)
    public ProfileData getProfile(Long userId) {
        User user = userRepository.findById(userId).orElseThrow();

        StatsService.Stats stats = statsService.getStats(userId);

        List<Long> watchedShowIds = watchedEpisodeRepository.findDistinctShowIdsOrderByLatestWatchedAtDesc(userId);
        Set<Long> showIdSet = new LinkedHashSet<>(watchedShowIds);

        List<BingeTrack> tracks = bingeTrackRepository.findByUserId(userId);
        for (BingeTrack t : tracks) {
            showIdSet.add(t.getShow().getId());
        }

        List<ShowProgress> allProgress = new ArrayList<>();
        for (Long showId : showIdSet) {
            Show show = showRepository.findById(showId).orElse(null);
            if (show != null) {
                long watched = watchedEpisodeRepository.countByUserIdAndEpisodeShowId(userId, show.getId());
                long total = episodeRepository.countByShowId(show.getId());
                double progress = total > 0 ? (double) watched / total : 0.0;
                allProgress.add(new ShowProgress(show, watched, total, progress));
            }
        }

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

        List<UserList> lists = userListRepository.findCustomListsWithItemsByUserId(userId);

        UserList watchlist = userListRepository.findWatchlistWithItemsByUserId(userId).orElse(null);
        long watchlistCount = 0;
        List<String> watchlistPosters = List.of();
        if (watchlist != null && watchlist.getItems() != null) {
            watchlistCount = watchlist.getItems().size();
            watchlistPosters = watchlist.getItems().stream()
                    .map(item -> item.getShow() != null ? item.getShow().getPosterPath() : null)
                    .filter(Objects::nonNull)
                    .limit(4)
                    .toList();
        }

        return new ProfileData(user, stats.episodesWatched(), (long) allProgress.size(), avgRating,
                watchingShows, watchedShows, lists, watchlistCount, watchlistPosters);
    }

    public record ProfileData(
            User user,
            long episodeCount,
            long showCount,
            Double avgRating,
            List<ShowProgress> watchingShows,
            List<ShowProgress> watchedShows,
            List<UserList> lists,
            long watchlistCount,
            List<String> watchlistPosters
    ) {}

    public record ShowProgress(Show show, long watchedEpisodes, long totalEpisodes, double progress) {}
}
