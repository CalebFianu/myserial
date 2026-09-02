package com.myserial.domain.repository;

import com.myserial.domain.entity.Show;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ShowRepository extends JpaRepository<Show, Long> {
    Optional<Show> findByTmdbId(Integer tmdbId);
    List<Show> findByStatusAndLastSyncedAtBefore(String status, OffsetDateTime threshold);
    List<Show> findByStatus(String status);

    @Query("SELECT s FROM Show s ORDER BY s.popularity DESC")
    List<Show> findTopByOrderByPopularityDesc(Pageable pageable);

    @Query("SELECT s.tmdbId FROM Show s")
    List<Integer> findAllTmdbIds();

    @Query("SELECT s FROM Show s WHERE s.lastSyncedAt IS NULL ORDER BY s.popularity DESC NULLS LAST")
    List<Show> findUnhydrated(Pageable pageable);

    @Query("SELECT s FROM Show s WHERE s.lastSyncedAt IS NOT NULL AND s.lastSyncedAt < :cutoff ORDER BY s.popularity DESC NULLS LAST")
    List<Show> findHydratedOlderThan(@Param("cutoff") OffsetDateTime cutoff, Pageable pageable);

    @Query("SELECT s FROM Show s WHERE LOWER(s.title) LIKE LOWER(CONCAT('%', :q, '%')) ORDER BY CASE WHEN s.lastSyncedAt IS NULL THEN 1 ELSE 0 END, s.popularity DESC NULLS LAST")
    List<Show> searchByTitle(@Param("q") String q, Pageable pageable);
}
