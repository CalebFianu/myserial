package com.myserial.domain.repository;

import com.myserial.domain.entity.Rewatch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RewatchRepository extends JpaRepository<Rewatch, Long> {
    Optional<Rewatch> findByUserIdAndShowId(Long userId, Long showId);
}
