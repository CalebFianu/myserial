package com.myserial.domain.repository;

import com.myserial.domain.entity.Season;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SeasonRepository extends JpaRepository<Season, Long> {
    List<Season> findByShowIdOrderBySeasonNumberAsc(Long showId);
    Optional<Season> findByShowIdAndSeasonNumber(Long showId, Integer seasonNumber);
    Optional<Season> findByTmdbId(Integer tmdbId);
}
