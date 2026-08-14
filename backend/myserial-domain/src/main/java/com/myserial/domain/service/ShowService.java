package com.myserial.domain.service;

import com.myserial.domain.entity.*;
import com.myserial.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

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
    private final ShowSyncPort showSyncPort;

    @Transactional
    public Show getOrFetchShow(int tmdbId) {
        Optional<Show> existing = showRepository.findByTmdbId(tmdbId);
        if (existing.isPresent()) {
            return existing.get();
        }
        return showSyncPort.fetchAndPersistShow(tmdbId);
    }

    @Transactional(readOnly = true)
    public Show findById(Long id) {
        return showRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Show not found: " + id));
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

    @Transactional
    public Show save(Show show) {
        return showRepository.save(show);
    }

    @Transactional(readOnly = true)
    public List<Show> findByStatusAndLastSyncedBefore(String status, java.time.OffsetDateTime threshold) {
        return showRepository.findByStatusAndLastSyncedAtBefore(status, threshold);
    }
}
