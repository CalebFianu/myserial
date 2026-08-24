package com.myserial.domain.repository;

import com.myserial.domain.entity.Episode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface EpisodeRepository extends JpaRepository<Episode, Long> {
    List<Episode> findByShowIdAndSeasonNumber(Long showId, Integer seasonNumber);
    List<Episode> findByShowIdOrderBySeasonNumberAscEpisodeNumberAsc(Long showId);
    Optional<Episode> findByTmdbId(Integer tmdbId);
    Optional<Episode> findByShowIdAndSeasonNumberAndEpisodeNumber(Long showId, Integer seasonNumber, Integer episodeNumber);
    long countByShowId(Long showId);
    long countByShowIdAndAirDateLessThanEqual(Long showId, LocalDate date);
}
