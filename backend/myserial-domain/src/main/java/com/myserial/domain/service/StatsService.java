package com.myserial.domain.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.myserial.domain.entity.EpisodeRating;
import com.myserial.domain.entity.WatchedEpisode;
import com.myserial.domain.repository.WatchedEpisodeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class StatsService {

    private final WatchedEpisodeRepository watchedEpisodeRepository;
    private final RatingService ratingService;
    private final ObjectMapper objectMapper;

    @Transactional(readOnly = true)
    public Stats getStats(Long userId) {
        long totalCount = watchedEpisodeRepository.countByUserId(userId);
        var watchedPage = watchedEpisodeRepository.findByUserIdOrderByWatchedAtDesc(userId, Pageable.unpaged());
        Long totalMinutesRaw = watchedEpisodeRepository.sumRuntimeByUserId(userId);
        long totalMinutes = totalMinutesRaw != null ? totalMinutesRaw : 0L;

        List<EpisodeRating> ratings = ratingService.getAllRatings(userId);
        Map<String, Long> histogram = buildHistogram(ratings);

        // Genre breakdown — deduplicate by show, then count genres
        Map<Long, String> showGenres = new LinkedHashMap<>();
        for (WatchedEpisode we : watchedPage.getContent()) {
            Long showId = we.getEpisode().getShow().getId();
            if (!showGenres.containsKey(showId)) {
                showGenres.put(showId, we.getEpisode().getShow().getGenres());
            }
        }
        Map<String, Integer> genreCounts = new LinkedHashMap<>();
        for (String genreJson : showGenres.values()) {
            if (genreJson == null || genreJson.isBlank()) continue;
            try {
                List<Map<String, Object>> genreList = objectMapper.readValue(genreJson, new TypeReference<>() {});
                for (Map<String, Object> g : genreList) {
                    String name = (String) g.get("name");
                    if (name != null) genreCounts.merge(name, 1, Integer::sum);
                }
            } catch (Exception e) {
                log.debug("Could not parse genres: {}", genreJson);
            }
        }
        int totalShows = showGenres.size();
        List<GenreStat> genreBreakdown = genreCounts.entrySet().stream()
                .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
                .limit(8)
                .map(e -> new GenreStat(e.getKey(), e.getValue(),
                        totalShows > 0 ? (double) e.getValue() / totalShows : 0.0))
                .toList();

        return new Stats(totalCount, totalMinutes, histogram, genreBreakdown);
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

    public record Stats(long episodesWatched, long totalMinutes, Map<String, Long> ratingsHistogram,
                        List<GenreStat> genreBreakdown) {}
    public record GenreStat(String genre, int count, double percentage) {}
}
