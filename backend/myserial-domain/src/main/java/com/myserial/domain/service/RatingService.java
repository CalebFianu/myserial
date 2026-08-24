package com.myserial.domain.service;

import com.myserial.domain.entity.Episode;
import com.myserial.domain.entity.EpisodeRating;
import com.myserial.domain.entity.User;
import com.myserial.domain.repository.EpisodeRatingRepository;
import com.myserial.domain.repository.EpisodeRepository;
import com.myserial.domain.repository.FriendshipRepository;
import com.myserial.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final EpisodeRatingRepository ratingRepository;
    private final EpisodeRepository episodeRepository;
    private final UserRepository userRepository;
    private final FriendshipRepository friendshipRepository;

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

    @Transactional(readOnly = true)
    public Page<EpisodeRating> getFriendReviews(Long userId, Pageable pageable) {
        List<Long> friendIds = friendshipRepository.findByUserId(userId).stream()
                .map(f -> f.getFriend().getId())
                .toList();
        if (friendIds.isEmpty()) {
            return Page.empty(pageable);
        }
        List<EpisodeRating> all = new ArrayList<>();
        for (Long friendId : friendIds) {
            all.addAll(ratingRepository.findByUserId(friendId));
        }
        all.sort((a, b) -> b.getUpdatedAt().compareTo(a.getUpdatedAt()));
        int start = (int) pageable.getOffset();
        int end = Math.min(start + pageable.getPageSize(), all.size());
        List<EpisodeRating> pageContent = start >= all.size() ? List.of() : all.subList(start, end);
        return new PageImpl<>(pageContent, pageable, all.size());
    }
}
