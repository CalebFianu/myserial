package com.myserial.domain.repository;

import com.myserial.domain.entity.BingeTrack;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BingeTrackRepository extends JpaRepository<BingeTrack, Long> {

    @Query("SELECT bt FROM BingeTrack bt JOIN FETCH bt.show WHERE bt.user.id = :userId")
    List<BingeTrack> findByUserId(@Param("userId") Long userId);

    Optional<BingeTrack> findByUserIdAndShowId(Long userId, Long showId);
    List<BingeTrack> findByWrappedFalse();

    @Query("SELECT bt FROM BingeTrack bt JOIN FETCH bt.show JOIN FETCH bt.user WHERE bt.wrapped = true AND bt.alerted = false")
    List<BingeTrack> findByWrappedTrueAndAlertedFalse();

    boolean existsByUserIdAndShowId(Long userId, Long showId);
}
