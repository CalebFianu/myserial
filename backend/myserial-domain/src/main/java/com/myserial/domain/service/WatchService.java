package com.myserial.domain.service;

import com.myserial.domain.entity.Episode;
import com.myserial.domain.entity.Show;
import com.myserial.domain.entity.User;
import com.myserial.domain.entity.WatchedEpisode;
import com.myserial.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class WatchService {

    private final WatchedEpisodeRepository watchedEpisodeRepository;
    private final EpisodeRepository episodeRepository;
    private final UserRepository userRepository;
    private final BingeTrackRepository bingeTrackRepository;
    private final ShowRepository showRepository;
    private final ShowService showService;

    @Transactional
    public WatchedEpisode markWatched(Long userId, Long episodeId) {
        if (watchedEpisodeRepository.existsByUserIdAndEpisodeId(userId, episodeId)) {
            return watchedEpisodeRepository.findByUserIdAndEpisodeId(userId, episodeId).orElseThrow();
        }
        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
        Episode episode = episodeRepository.findById(episodeId).orElseThrow(() -> new IllegalArgumentException("Episode not found"));
        WatchedEpisode we = WatchedEpisode.builder()
                .user(user)
                .episode(episode)
                .build();
        return watchedEpisodeRepository.save(we);
    }

    @Transactional
    public void markUnwatched(Long userId, Long episodeId) {
        watchedEpisodeRepository.findByUserIdAndEpisodeId(userId, episodeId)
                .ifPresent(watchedEpisodeRepository::delete);
    }

    /**
     * Marks an arbitrary set of episodes watched in one call, skipping any that
     * are already logged or missing. Returns only the episodes newly marked, in
     * the order they were requested, so callers can summarise what changed.
     */
    @Transactional
    public List<WatchedEpisode> markWatchedBatch(Long userId, List<Long> episodeIds) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        List<WatchedEpisode> created = new ArrayList<>();
        for (Long episodeId : episodeIds) {
            if (episodeId == null
                    || watchedEpisodeRepository.existsByUserIdAndEpisodeId(userId, episodeId)) {
                continue;
            }
            Episode episode = episodeRepository.findById(episodeId).orElse(null);
            if (episode == null) {
                continue;
            }
            created.add(watchedEpisodeRepository.save(
                    WatchedEpisode.builder().user(user).episode(episode).build()));
        }
        return created;
    }

    @Transactional
    public List<WatchedEpisode> bulkMarkSeasonWatched(Long userId, Long showId, int seasonNumber) {
        Show show = showService.findById(showId);
        Long resolvedShowId = show.getId();
        List<Episode> episodes = episodeRepository.findByShowIdAndSeasonNumber(resolvedShowId, seasonNumber);
        User user = userRepository.findById(userId).orElseThrow();
        return episodes.stream()
                .filter(ep -> !watchedEpisodeRepository.existsByUserIdAndEpisodeId(userId, ep.getId()))
                .map(ep -> watchedEpisodeRepository.save(WatchedEpisode.builder().user(user).episode(ep).build()))
                .toList();
    }

    @Transactional
    public List<WatchedEpisode> bulkMarkUpToEpisode(Long userId, Long showId, int seasonNumber, int episodeNumber) {
        Show show = showService.findById(showId);
        Long resolvedShowId = show.getId();
        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));

        List<Episode> episodes = episodeRepository.findByShowIdOrderBySeasonNumberAscEpisodeNumberAsc(resolvedShowId);
        List<Episode> targetEpisodes = episodes.stream()
                .filter(ep -> ep.getSeasonNumber() < seasonNumber ||
                        (ep.getSeasonNumber() == seasonNumber && ep.getEpisodeNumber() <= episodeNumber))
                .toList();

        return targetEpisodes.stream()
                .filter(ep -> !watchedEpisodeRepository.existsByUserIdAndEpisodeId(userId, ep.getId()))
                .map(ep -> watchedEpisodeRepository.save(WatchedEpisode.builder().user(user).episode(ep).build()))
                .toList();
    }

    @Transactional
    public List<WatchedEpisode> bulkMarkEntireShowWatched(Long userId, Long showId) {
        Show show = showService.findById(showId);
        Long resolvedShowId = show.getId();
        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));

        List<Episode> episodes = episodeRepository.findByShowIdOrderBySeasonNumberAscEpisodeNumberAsc(resolvedShowId);
        return episodes.stream()
                .filter(ep -> !watchedEpisodeRepository.existsByUserIdAndEpisodeId(userId, ep.getId()))
                .map(ep -> watchedEpisodeRepository.save(WatchedEpisode.builder().user(user).episode(ep).build()))
                .toList();
    }

    @Transactional(readOnly = true)
    public Set<Long> getWatchedEpisodeIds(Long userId, Long showId) {
        return watchedEpisodeRepository.findEpisodeIdsByUserIdAndShowId(userId, showId);
    }

    @Transactional(readOnly = true)
    public WatchProgress getProgress(Long userId, Long showId) {
        long watched = watchedEpisodeRepository.countByUserIdAndEpisodeShowId(userId, showId);
        long total = episodeRepository.countByShowId(showId);
        return new WatchProgress(watched, total);
    }

    @Transactional(readOnly = true)
    public Page<WatchedEpisode> getDiary(Long userId, Pageable pageable) {
        return watchedEpisodeRepository.findByUserIdOrderByWatchedAtDesc(userId, pageable);
    }

    @Transactional(readOnly = true)
    public List<UpNextResult> getUpNext(Long userId) {
        List<com.myserial.domain.entity.BingeTrack> tracks = bingeTrackRepository.findByUserId(userId);
        return tracks.stream()
                .map(track -> {
                    Show show = showRepository.findById(track.getShow().getId()).orElse(null);
                    if (show == null) return null;
                    List<Episode> allEpisodes = episodeRepository.findByShowIdOrderBySeasonNumberAscEpisodeNumberAsc(show.getId());
                    Set<Long> watchedIds = watchedEpisodeRepository.findEpisodeIdsByUserIdAndShowId(userId, show.getId());
                    Episode next = allEpisodes.stream()
                            .filter(ep -> !watchedIds.contains(ep.getId()))
                            .findFirst()
                            .orElse(null);
                    return next != null ? new UpNextResult(show, next) : null;
                })
                .filter(r -> r != null)
                .toList();
    }

    public record WatchProgress(long watched, long total) {}
    public record UpNextResult(Show show, Episode nextEpisode) {}
}
