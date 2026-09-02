package com.myserial.catalog;

import com.myserial.catalog.dto.*;
import com.myserial.domain.entity.*;
import com.myserial.domain.repository.*;
import com.myserial.domain.service.ShowSyncPort;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ShowSyncAdapter implements ShowSyncPort {

    private final CatalogProvider catalogProvider;
    private final ShowRepository showRepository;
    private final SeasonRepository seasonRepository;
    private final EpisodeRepository episodeRepository;
    private final PersonRepository personRepository;
    private final CreditRepository creditRepository;
    private final StreamingAvailabilityRepository streamingAvailabilityRepository;

    @Override
    @Transactional
    public Show fetchAndPersistShow(int tmdbId) {
        ShowDetail detail = catalogProvider.fetchShowWithSeasonsAndCredits(tmdbId);
        return persistShowDetail(detail);
    }

    @Override
    @Transactional
    public List<Show> searchAndSeedShows(String query, int limit) {
        List<ShowSummary> summaries = catalogProvider.searchShows(query, "en-US");
        if (summaries == null || summaries.isEmpty()) {
            return Collections.emptyList();
        }

        List<Show> seededShows = new ArrayList<>();
        int count = 0;
        for (ShowSummary summary : summaries) {
            if (limit > 0 && count >= limit) {
                break;
            }
            try {
                Optional<Show> existing = showRepository.findByTmdbId(summary.tmdbId());
                if (existing.isPresent() && existing.get().getLastSyncedAt() != null) {
                    seededShows.add(existing.get());
                } else {
                    Show seeded = fetchAndPersistShow(summary.tmdbId());
                    seededShows.add(seeded);
                }
                count++;
            } catch (Exception e) {
                log.warn("Failed to seed show tmdbId={} ('{}') from TMDB: {}", summary.tmdbId(), summary.title(), e.getMessage());
                try {
                    Show stub = showRepository.findByTmdbId(summary.tmdbId()).orElse(new Show());
                    stub.setTmdbId(summary.tmdbId());
                    stub.setTitle(summary.title());
                    stub.setOriginalTitle(summary.originalTitle());
                    stub.setOverview(summary.overview());
                    stub.setPosterPath(summary.posterPath());
                    stub.setBackdropPath(summary.backdropPath());
                    stub.setFirstAirDate(summary.firstAirDate());
                    stub.setVoteAverage(summary.voteAverage());
                    stub.setPopularity(summary.popularity());
                    stub.setStatus(summary.status());
                    Show savedStub = showRepository.save(stub);
                    seededShows.add(savedStub);
                    count++;
                } catch (Exception ex) {
                    log.error("Failed to save fallback stub for tmdbId={}: {}", summary.tmdbId(), ex.getMessage());
                }
            }
        }
        return seededShows;
    }

    @Transactional
    public Show persistShowDetail(ShowDetail detail) {
        Show show = showRepository.findByTmdbId(detail.tmdbId()).orElse(new Show());
        show.setTmdbId(detail.tmdbId());
        show.setTitle(detail.title());
        show.setOriginalTitle(detail.originalTitle());
        show.setOverview(detail.overview());
        show.setStatus(detail.status());
        show.setFirstAirDate(detail.firstAirDate());
        show.setLastAirDate(detail.lastAirDate());
        show.setPosterPath(detail.posterPath());
        show.setBackdropPath(detail.backdropPath());
        show.setGenres(detail.genres());
        show.setNetwork(detail.network());
        show.setEpisodeRunTime(detail.episodeRunTime());
        show.setVoteAverage(detail.voteAverage());
        show.setVoteCount(detail.voteCount());
        show.setPopularity(detail.popularity());
        show.setLastSyncedAt(OffsetDateTime.now());
        Show saved = showRepository.save(show);

        // Persist seasons and episodes
        if (detail.seasons() != null) {
            for (SeasonDetail sd : detail.seasons()) {
                persistSeason(saved, sd);
            }
        }

        // Persist credits
        if (detail.cast() != null || detail.crew() != null) {
            creditRepository.deleteByShowId(saved.getId());
            if (detail.cast() != null) {
                for (CastMember cm : detail.cast()) {
                    persistCredit(saved, cm.tmdbId(), cm.name(), cm.profilePath(), cm.characterName(), "CAST", null, null, cm.order());
                }
            }
            if (detail.crew() != null) {
                for (CrewMember cm : detail.crew()) {
                    persistCredit(saved, cm.tmdbId(), cm.name(), cm.profilePath(), null, "CREW", cm.department(), cm.job(), 999);
                }
            }
        }

        // Persist streaming availability
        if (detail.watchProviders() != null && !detail.watchProviders().isEmpty()) {
            streamingAvailabilityRepository.deleteByShowId(saved.getId());
            for (WatchProviderInfo wp : detail.watchProviders()) {
                StreamingAvailability sa = StreamingAvailability.builder()
                        .show(saved)
                        .providerId(wp.providerId())
                        .providerName(wp.providerName())
                        .providerLogoPath(wp.logoPath())
                        .countryCode(wp.countryCode())
                        .offerType(wp.offerType())
                        .link(wp.link())
                        .lastSyncedAt(OffsetDateTime.now())
                        .build();
                streamingAvailabilityRepository.save(sa);
            }
        }

        return saved;
    }

    private void persistSeason(Show show, SeasonDetail sd) {
        Season season = seasonRepository.findByTmdbId(sd.tmdbId())
                .orElse(Season.builder().show(show).build());
        season.setTmdbId(sd.tmdbId());
        season.setShow(show);
        season.setSeasonNumber(sd.seasonNumber());
        season.setName(sd.name());
        season.setOverview(sd.overview());
        season.setPosterPath(sd.posterPath());
        season.setAirDate(sd.airDate());
        season.setEpisodeCount(sd.episodes() != null ? sd.episodes().size() : null);
        Season savedSeason = seasonRepository.save(season);

        if (sd.episodes() != null) {
            for (EpisodeDetail ed : sd.episodes()) {
                persistEpisode(show, savedSeason, ed);
            }
        }
    }

    private void persistEpisode(Show show, Season season, EpisodeDetail ed) {
        Episode episode = episodeRepository.findByTmdbId(ed.tmdbId())
                .orElse(Episode.builder().show(show).season(season).build());
        episode.setTmdbId(ed.tmdbId());
        episode.setShow(show);
        episode.setSeason(season);
        episode.setSeasonNumber(ed.seasonNumber());
        episode.setEpisodeNumber(ed.episodeNumber());
        episode.setName(ed.name());
        episode.setOverview(ed.overview());
        episode.setAirDate(ed.airDate());
        episode.setStillPath(ed.stillPath());
        episode.setRuntime(ed.runtime());
        episode.setVoteAverage(ed.voteAverage());
        episodeRepository.save(episode);
    }

    private void persistCredit(Show show, int personTmdbId, String personName, String profilePath,
                                String characterName, String creditType, String department, String job, int order) {
        Person person = personRepository.findByTmdbId(personTmdbId).orElse(Person.builder().build());
        person.setTmdbId(personTmdbId);
        person.setName(personName);
        person.setProfilePath(profilePath);
        Person savedPerson = personRepository.save(person);

        Credit credit = Credit.builder()
                .person(savedPerson)
                .show(show)
                .characterName(characterName)
                .creditType(creditType)
                .department(department)
                .job(job)
                .displayOrder(order)
                .build();
        creditRepository.save(credit);
    }
}
