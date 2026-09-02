package com.myserial.domain.service;

import com.myserial.domain.entity.*;
import com.myserial.domain.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Core show data service. Catalog fetching is delegated via ShowSyncPort
 * (implemented in myserial-catalog to avoid circular dependencies).
 */
@Slf4j
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

    public record RosterEntry(int tmdbId, String title, double popularity) {}

    @Transactional
    public void upsertRosterEntries(List<RosterEntry> entries) {
        if (entries == null || entries.isEmpty()) return;

        Set<Integer> existingTmdbIds = new HashSet<>(showRepository.findAllTmdbIds());
        int createdCount = 0;
        int updatedCount = 0;

        for (RosterEntry entry : entries) {
            BigDecimal pop = BigDecimal.valueOf(entry.popularity());
            if (existingTmdbIds.contains(entry.tmdbId())) {
                Optional<Show> existingOpt = showRepository.findByTmdbId(entry.tmdbId());
                if (existingOpt.isPresent()) {
                    Show show = existingOpt.get();
                    show.setPopularity(pop);
                    showRepository.save(show);
                    updatedCount++;
                }
            } else {
                Show stub = Show.builder()
                        .tmdbId(entry.tmdbId())
                        .title(entry.title())
                        .originalTitle(entry.title())
                        .popularity(pop)
                        .lastSyncedAt(null)
                        .build();
                showRepository.save(stub);
                existingTmdbIds.add(entry.tmdbId());
                createdCount++;
            }
        }
        log.info("Roster upsert complete: {} new stubs created, {} popularity scores updated", createdCount, updatedCount);
    }

    @Transactional(readOnly = true)
    public List<Show> findUnhydrated(int limit) {
        return showRepository.findUnhydrated(PageRequest.of(0, limit));
    }

    @Transactional(readOnly = true)
    public List<Show> findHydratedOlderThan(OffsetDateTime cutoff, int limit) {
        return showRepository.findHydratedOlderThan(cutoff, PageRequest.of(0, limit));
    }

    @Transactional
    public List<Show> search(String q, int limit) {
        if (q == null || q.isBlank()) {
            return Collections.emptyList();
        }
        List<Show> localResults = showRepository.searchByTitle(q.trim(), PageRequest.of(0, limit));
        if (!localResults.isEmpty()) {
            return localResults;
        }
        return showSyncPort.searchAndSeedShows(q.trim(), limit);
    }

    @Transactional
    public Show getOrFetchShow(int tmdbId) {
        Optional<Show> existing = showRepository.findByTmdbId(tmdbId);
        if (existing.isPresent() && existing.get().getLastSyncedAt() != null) {
            return existing.get();
        }
        return showSyncPort.fetchAndPersistShow(tmdbId);
    }

    @Transactional
    public Show findById(Long id) {
        return showRepository.findById(id)
                .map(show -> {
                    if (show.getLastSyncedAt() == null && show.getTmdbId() != null) {
                        return getOrFetchShow(show.getTmdbId());
                    }
                    return show;
                })
                .orElseGet(() -> {
                    if (id <= Integer.MAX_VALUE) {
                        Optional<Show> byTmdb = showRepository.findByTmdbId(id.intValue());
                        if (byTmdb.isPresent()) {
                            Show show = byTmdb.get();
                            if (show.getLastSyncedAt() == null) {
                                return getOrFetchShow(id.intValue());
                            }
                            return show;
                        }
                        return getOrFetchShow(id.intValue());
                    }
                    throw new IllegalArgumentException("Show not found: " + id);
                });
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
        Show show = findById(showId);
        Long resolvedShowId = show.getId();
        List<Episode> episodes = episodeRepository.findByShowIdOrderBySeasonNumberAscEpisodeNumberAsc(resolvedShowId);
        long watchedCount = userId != null ? watchedEpisodeRepository.countByUserIdAndEpisodeShowId(userId, resolvedShowId) : 0;

        List<RecapChapter> chapters = new ArrayList<>();
        int step = Math.max(1, chunkSize);
        int totalSoFar = 0;
        for (int i = 0; i < episodes.size(); i += step) {
            List<Episode> chunk = episodes.subList(i, Math.min(i + step, episodes.size()));
            Episode first = chunk.get(0);
            Episode last = chunk.get(chunk.size() - 1);
            String range = chunk.size() == 1
                    ? String.format("S%02dE%02d", first.getSeasonNumber(), first.getEpisodeNumber())
                    : String.format("S%02dE%02d–S%02dE%02d",
                            first.getSeasonNumber(), first.getEpisodeNumber(),
                            last.getSeasonNumber(), last.getEpisodeNumber());
            String title = chunk.size() == 1
                    ? (first.getName() != null && !first.getName().isBlank() ? first.getName() : range)
                    : String.format("Season %d, Episodes %d–%d",
                            first.getSeasonNumber(), first.getEpisodeNumber(), last.getEpisodeNumber());
            String body = chunk.stream()
                    .map(ep -> {
                        String overview = ep.getOverview() != null && !ep.getOverview().isBlank() ? ep.getOverview() : "No synopsis available for this episode.";
                        return chunk.size() == 1 ? overview : (ep.getName() != null ? ep.getName() + ": " : "") + overview;
                    })
                    .collect(Collectors.joining("\n\n"));
            if (body.isBlank()) body = "No overview available.";
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
