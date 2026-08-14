package com.myserial.domain.repository;

import com.myserial.domain.entity.StreamingAvailability;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StreamingAvailabilityRepository extends JpaRepository<StreamingAvailability, Long> {
    List<StreamingAvailability> findByShowIdAndCountryCode(Long showId, String countryCode);
    List<StreamingAvailability> findByShowId(Long showId);
    @org.springframework.transaction.annotation.Transactional
    void deleteByShowId(Long showId);
}
