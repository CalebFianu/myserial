package com.myserial.domain.service;

import com.myserial.domain.entity.EpisodeRating;
import com.myserial.domain.repository.WatchedEpisodeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.TreeMap;

@Service
@RequiredArgsConstructor
public class StatsService {

    private final WatchedEpisodeRepository watchedEpisodeRepository;
    private final RatingService ratingService;

    @Transactional(readOnly = true)
    public Stats getStats(Long userId) {
        long totalCount = watchedEpisodeRepository
                .findByUserIdOrderByWatchedAtDesc(userId, Pageable.unpaged())
                .getTotalElements();
        Long totalMinutesRaw = watchedEpisodeRepository.sumRuntimeByUserId(userId);
        long totalMinutes = totalMinutesRaw != null ? totalMinutesRaw : 0L;

        List<EpisodeRating> ratings = ratingService.getAllRatings(userId);
        Map<String, Long> histogram = buildHistogram(ratings);

        return new Stats(totalCount, totalMinutes, histogram);
    }

    private Map<String, Long> buildHistogram(List<EpisodeRating> ratings) {
        Map<String, Long> histogram = new TreeMap<>();
        for (int i = 1; i <= 10; i++) {
            histogram.put(String.valueOf(i * 0.5), 0L);
        }
        for (EpisodeRating r : ratings) {
            String key = r.getScore().stripTrailingZeros().toPlainString();
            histogram.merge(key, 1L, Long::sum);
        }
        return histogram;
    }

    public record Stats(long episodesWatched, long totalMinutes, Map<String, Long> ratingsHistogram) {}
}
