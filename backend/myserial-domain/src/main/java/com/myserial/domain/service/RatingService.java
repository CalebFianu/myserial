package com.myserial.domain.service;

import com.myserial.domain.entity.Episode;
import com.myserial.domain.entity.EpisodeRating;
import com.myserial.domain.entity.User;
import com.myserial.domain.repository.EpisodeRatingRepository;
import com.myserial.domain.repository.EpisodeRepository;
import com.myserial.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final EpisodeRatingRepository ratingRepository;
    private final EpisodeRepository episodeRepository;
    private final UserRepository userRepository;

    @Transactional
    public EpisodeRating upsertRating(Long userId, Long episodeId, BigDecimal score, String review) {
        Optional<EpisodeRating> existing = ratingRepository.findByUserIdAndEpisodeId(userId, episodeId);
        if (existing.isPresent()) {
            EpisodeRating rating = existing.get();
            rating.setScore(score);
            rating.setReview(review);
            return ratingRepository.save(rating);
        }
        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
        Episode episode = episodeRepository.findById(episodeId).orElseThrow(() -> new IllegalArgumentException("Episode not found"));
        EpisodeRating rating = EpisodeRating.builder()
                .user(user)
                .episode(episode)
                .score(score)
                .review(review)
                .build();
        return ratingRepository.save(rating);
    }

    @Transactional
    public void deleteRating(Long userId, Long episodeId) {
        ratingRepository.deleteByUserIdAndEpisodeId(userId, episodeId);
    }

    @Transactional(readOnly = true)
    public Optional<EpisodeRating> getEpisodeRating(Long userId, Long episodeId) {
        return ratingRepository.findByUserIdAndEpisodeId(userId, episodeId);
    }

    @Transactional(readOnly = true)
    public List<EpisodeRating> getShowRatings(Long userId, Long showId) {
        return ratingRepository.findByUserIdAndEpisodeShowId(userId, showId);
    }

    @Transactional(readOnly = true)
    public List<EpisodeRating> getAllRatings(Long userId) {
        return ratingRepository.findByUserId(userId);
    }
}
