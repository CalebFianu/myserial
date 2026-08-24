package com.myserial.domain.service;

import com.myserial.domain.entity.*;
import com.myserial.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HomeService {

    private final BingeTrackRepository bingeTrackRepository;
    private final WatchedEpisodeRepository watchedEpisodeRepository;
    private final EpisodeRepository episodeRepository;
    private final ActivityEventRepository activityEventRepository;
    private final FriendshipRepository friendshipRepository;
    private final WatchService watchService;

    @Transactional(readOnly = true)
    public HomeData getHomeData(Long userId) {
        List<BingeTrack> tracks = bingeTrackRepository.findByUserId(userId);

        List<MyShow> myShows = tracks.stream()
                .map(t -> new MyShow(t.getShow()))
                .toList();

        List<WatchService.UpNextResult> upNextResults = watchService.getUpNext(userId);

        ContinueWatching continueWatching = null;
        for (WatchService.UpNextResult r : upNextResults) {
            long watched = watchedEpisodeRepository.countByUserIdAndEpisodeShowId(userId, r.show().getId());
            if (watched > 0) {
                long total = episodeRepository.countByShowId(r.show().getId());
                double progress = total > 0 ? (double) watched / total : 0.0;
                continueWatching = new ContinueWatching(r.show(), r.nextEpisode(), watched, total, progress);
                break;
            }
        }

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
