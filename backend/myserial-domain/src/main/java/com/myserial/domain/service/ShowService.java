package com.myserial.domain.service;

import com.myserial.domain.entity.*;
import com.myserial.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Core show data service. Catalog fetching is delegated via ShowSyncPort
 * (implemented in myserial-catalog to avoid circular dependencies).
 */
@Service
@RequiredArgsConstructor
public class ShowService {

    private final ShowRepository showRepository;
    private final SeasonRepository seasonRepository;
    private final EpisodeRepository episodeRepository;
    private final CreditRepository creditRepository;
    private final StreamingAvailabilityRepository streamingAvailabilityRepository;
    private final WatchedEpisodeRepository watchedEpisodeRepository;
    private final ShowSyncPort showSyncPort;

    @Transactional
    public Show getOrFetchShow(int tmdbId) {
        Optional<Show> existing = showRepository.findByTmdbId(tmdbId);
        if (existing.isPresent()) {
            return existing.get();
        }
        return showSyncPort.fetchAndPersistShow(tmdbId);
    }

    @Transactional
    public Show findById(Long id) {
        return showRepository.findById(id)
                .orElseGet(() -> getOrFetchShow(id.intValue()));
    }

    @Transactional(readOnly = true)
    public Optional<Show> findByTmdbId(int tmdbId) {
        return showRepository.findByTmdbId(tmdbId);
    }

    @Transactional(readOnly = true)
    public List<Season> getSeasons(Long showId) {
        return seasonRepository.findByShowIdOrderBySeasonNumberAsc(showId);
    }

    @Transactional(readOnly = true)
    public Optional<Season> getSeasonWithEpisodes(Long showId, int seasonNumber) {
        return seasonRepository.findByShowIdAndSeasonNumber(showId, seasonNumber);
    }

    @Transactional(readOnly = true)
    public List<Episode> getEpisodes(Long showId) {
        return episodeRepository.findByShowIdOrderBySeasonNumberAscEpisodeNumberAsc(showId);
    }

    @Transactional(readOnly = true)
    public List<Episode> getSeasonEpisodes(Long showId, int seasonNumber) {
        return episodeRepository.findByShowIdAndSeasonNumber(showId, seasonNumber);
    }

    @Transactional(readOnly = true)
    public List<Credit> getCredits(Long showId) {
        return creditRepository.findByShowIdOrderByDisplayOrderAsc(showId);
    }

    @Transactional(readOnly = true)
    public List<StreamingAvailability> getStreamingAvailability(Long showId, String countryCode) {
        if (countryCode != null && !countryCode.isBlank()) {
            return streamingAvailabilityRepository.findByShowIdAndCountryCode(showId, countryCode);
        }
        return streamingAvailabilityRepository.findByShowId(showId);
    }

    @Transactional(readOnly = true)
    public List<Show> getPopular(int limit) {
        return showRepository.findTopByOrderByPopularityDesc(PageRequest.of(0, limit));
    }

    @Transactional(readOnly = true)
    public RecapResult getRecap(Long showId, Long userId, int chunkSize) {
        List<Episode> episodes = episodeRepository.findByShowIdOrderBySeasonNumberAscEpisodeNumberAsc(showId);
        long watchedCount = watchedEpisodeRepository.countByUserIdAndEpisodeShowId(userId, showId);

        List<RecapChapter> chapters = new ArrayList<>();
        int totalSoFar = 0;
        for (int i = 0; i < episodes.size(); i += chunkSize) {
            List<Episode> chunk = episodes.subList(i, Math.min(i + chunkSize, episodes.size()));
            Episode first = chunk.get(0);
            Episode last = chunk.get(chunk.size() - 1);
            String range = String.format("S%02dE%02d\u2013S%02dE%02d",
                    first.getSeasonNumber(), first.getEpisodeNumber(),
                    last.getSeasonNumber(), last.getEpisodeNumber());
            String title = chunk.size() == 1
                    ? (first.getName() != null ? first.getName() : range)
                    : String.format("Season %d, Episodes %d\u2013%d",
                            first.getSeasonNumber(), first.getEpisodeNumber(), last.getEpisodeNumber());
            String body = chunk.stream()
                    .filter(ep -> ep.getOverview() != null && !ep.getOverview().isBlank())
                    .map(ep -> ep.getName() + ": " + ep.getOverview())
                    .collect(Collectors.joining("\n\n"));
            if (body.isBlank()) body = "No overview available for this episode range.";
            totalSoFar += chunk.size();
            chapters.add(new RecapChapter(range, title, body, totalSoFar));
        }

        return new RecapResult(chapters, watchedCount);
    }

    public record RecapResult(List<RecapChapter> chapters, long watchedCount) {}
    public record RecapChapter(String range, String title, String body, int unlockAfterEpisode) {}

    @Transactional
    public Show save(Show show) {
        return showRepository.save(show);
    }

    @Transactional(readOnly = true)
    public List<Show> findByStatusAndLastSyncedBefore(String status, java.time.OffsetDateTime threshold) {
        return showRepository.findByStatusAndLastSyncedAtBefore(status, threshold);
    }
}
