package com.myserial.domain.repository;

import com.myserial.domain.entity.Show;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ShowRepository extends JpaRepository<Show, Long> {
    Optional<Show> findByTmdbId(Integer tmdbId);
    List<Show> findByStatusAndLastSyncedAtBefore(String status, OffsetDateTime threshold);
    List<Show> findByStatus(String status);
}
