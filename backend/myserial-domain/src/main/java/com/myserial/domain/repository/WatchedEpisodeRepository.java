package com.myserial.domain.repository;

import com.myserial.domain.entity.WatchedEpisode;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.Set;

@Repository
public interface WatchedEpisodeRepository extends JpaRepository<WatchedEpisode, Long> {
    Optional<WatchedEpisode> findByUserIdAndEpisodeId(Long userId, Long episodeId);

    @Query("SELECT we.episode.id FROM WatchedEpisode we WHERE we.user.id = :userId AND we.episode.show.id = :showId")
    Set<Long> findEpisodeIdsByUserIdAndShowId(@Param("userId") Long userId, @Param("showId") Long showId);

    long countByUserIdAndEpisodeShowId(Long userId, Long showId);

    @Query("SELECT we FROM WatchedEpisode we JOIN FETCH we.episode e JOIN FETCH e.show WHERE we.user.id = :userId ORDER BY we.watchedAt DESC")
    Page<WatchedEpisode> findByUserIdOrderByWatchedAtDesc(@Param("userId") Long userId, Pageable pageable);

    boolean existsByUserIdAndEpisodeId(Long userId, Long episodeId);

    @Query("SELECT SUM(COALESCE(we.episode.runtime, 0)) FROM WatchedEpisode we WHERE we.user.id = :userId")
    Long sumRuntimeByUserId(@Param("userId") Long userId);
}
