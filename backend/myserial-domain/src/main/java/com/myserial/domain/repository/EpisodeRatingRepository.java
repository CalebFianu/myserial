package com.myserial.domain.repository;

import com.myserial.domain.entity.EpisodeRating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Repository
public interface EpisodeRatingRepository extends JpaRepository<EpisodeRating, Long> {

    @Query("SELECT er FROM EpisodeRating er JOIN FETCH er.episode e WHERE er.user.id = :userId AND er.episode.id = :episodeId")
    Optional<EpisodeRating> findByUserIdAndEpisodeId(@Param("userId") Long userId, @Param("episodeId") Long episodeId);

    @Query("SELECT er FROM EpisodeRating er JOIN FETCH er.episode e WHERE er.user.id = :userId AND er.episode.show.id = :showId")
    List<EpisodeRating> findByUserIdAndEpisodeShowId(@Param("userId") Long userId, @Param("showId") Long showId);

    @Query("SELECT er FROM EpisodeRating er JOIN FETCH er.episode e JOIN FETCH er.user WHERE er.user.id = :userId")
    List<EpisodeRating> findByUserId(@Param("userId") Long userId);

    @Transactional
    void deleteByUserIdAndEpisodeId(Long userId, Long episodeId);
}
