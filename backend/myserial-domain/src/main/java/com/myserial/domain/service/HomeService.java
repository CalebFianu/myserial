package com.myserial.domain.service;

import com.myserial.domain.entity.*;
import com.myserial.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;

@Service
@RequiredArgsConstructor
public class HomeService {

    private final BingeTrackRepository bingeTrackRepository;
    private final WatchedEpisodeRepository watchedEpisodeRepository;
    private final EpisodeRepository episodeRepository;
    private final ActivityEventRepository activityEventRepository;
    private final FriendshipRepository friendshipRepository;
    private final ShowRepository showRepository;
    private final WatchService watchService;

    @Transactional(readOnly = true)
    public HomeData getHomeData(Long userId) {
        // Find distinct shows user has logged episodes for, ordered by most recent watch date DESC
        List<Long> watchedShowIds = watchedEpisodeRepository.findDistinctShowIdsOrderByLatestWatchedAtDesc(userId);
        Set<Long> showIdSet = new LinkedHashSet<>(watchedShowIds);

        // Also include tracked shows
        List<BingeTrack> tracks = bingeTrackRepository.findByUserId(userId);
        for (BingeTrack t : tracks) {
            showIdSet.add(t.getShow().getId());
        }

        List<Show> userShows = new ArrayList<>();
        for (Long showId : showIdSet) {
            showRepository.findById(showId).ifPresent(userShows::add);
        }

        List<MyShow> myShows = userShows.stream()
                .map(MyShow::new)
                .toList();

        // Determine most recently logged / continue watching show
        ContinueWatching continueWatching = null;
        for (Show show : userShows) {
            long watched = watchedEpisodeRepository.countByUserIdAndEpisodeShowId(userId, show.getId());
            long total = episodeRepository.countByShowId(show.getId());
            double progress = total > 0 ? (double) watched / total : 0.0;

            List<Episode> allEpisodes = episodeRepository.findByShowIdOrderBySeasonNumberAscEpisodeNumberAsc(show.getId());
            Set<Long> watchedIds = watchedEpisodeRepository.findEpisodeIdsByUserIdAndShowId(userId, show.getId());
            Episode nextOrLatest = allEpisodes.stream()
                    .filter(ep -> !watchedIds.contains(ep.getId()))
                    .findFirst()
                    .orElse(allEpisodes.isEmpty() ? null : allEpisodes.get(allEpisodes.size() - 1));

            if (nextOrLatest != null) {
                continueWatching = new ContinueWatching(show, nextOrLatest, watched, total, progress);
                break;
            }
        }

        List<WatchService.UpNextResult> upNextResults = watchService.getUpNext(userId);

        List<BingeReady> bingeReady = tracks.stream()
                .map(t -> {
                    long watched = watchedEpisodeRepository.countByUserIdAndEpisodeShowId(userId, t.getShow().getId());
                    long available = episodeRepository.countByShowIdAndAirDateLessThanEqual(t.getShow().getId(), LocalDate.now());
                    return new BingeReady(t.getShow(), available - watched);
                })
                .filter(b -> b.unwatchedCount() >= 3)
                .limit(5)
                .toList();

        List<Long> friendIds = friendshipRepository.findByUserId(userId).stream()
                .map(f -> f.getFriend().getId())
                .toList();
        List<FriendActivity> friendActivity = List.of();
        if (!friendIds.isEmpty()) {
            friendActivity = activityEventRepository
                    .findByUserIdInOrderByCreatedAtDesc(friendIds, PageRequest.of(0, 3))
                    .getContent().stream()
                    .filter(ae -> ae.getShow() != null)
                    .map(ae -> new FriendActivity(
                            ae.getUser().getName(), ae.getUser().getAvatarPath(), ae.getShow()))
                    .toList();
        }

        long diaryCount = watchedEpisodeRepository.countByUserId(userId);

        return new HomeData(continueWatching, myShows, bingeReady, friendActivity,
                upNextResults.size(), diaryCount);
    }

    public record HomeData(
            ContinueWatching continueWatching,
            List<MyShow> myShows,
            List<BingeReady> bingeReady,
            List<FriendActivity> friendActivity,
            int upNextCount,
            long diaryCount
    ) {}

    public record ContinueWatching(Show show, Episode nextEpisode, long watched, long total, double progress) {}
    public record MyShow(Show show) {}
    public record BingeReady(Show show, long unwatchedCount) {}
    public record FriendActivity(String friendName, String friendAvatarPath, Show show) {}
}
