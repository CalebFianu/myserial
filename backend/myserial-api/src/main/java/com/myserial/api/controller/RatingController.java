package com.myserial.api.controller;

import com.myserial.api.dto.request.RatingRequest;
import com.myserial.api.dto.response.EpisodeRatingResponse;
import com.myserial.api.dto.response.ShowRatingsResponse;
import com.myserial.domain.entity.EpisodeRating;
import com.myserial.domain.service.ActivityService;
import com.myserial.domain.service.RatingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/ratings")
@RequiredArgsConstructor
public class RatingController extends BaseController {

    private final RatingService ratingService;
    private final ActivityService activityService;

    @PutMapping("/{episodeId}")
    public ResponseEntity<EpisodeRatingResponse> upsertRating(
            @PathVariable Long episodeId,
            @Valid @RequestBody RatingRequest req) {
        Long userId = currentUserId();
        EpisodeRating rating = ratingService.upsertRating(userId, episodeId, req.score(), req.review());
        activityService.log(userId, "EPISODE_RATED",
                rating.getEpisode().getShow().getId(), episodeId, null,
                "{\"score\":" + req.score() + "}");
        return ResponseEntity.ok(DtoMapper.toEpisodeRatingResponse(rating));
    }

    @DeleteMapping("/{episodeId}")
    public ResponseEntity<Void> deleteRating(@PathVariable Long episodeId) {
        ratingService.deleteRating(currentUserId(), episodeId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/show/{showId}")
    public ResponseEntity<ShowRatingsResponse> getShowRatings(@PathVariable Long showId) {
        Long userId = currentUserId();
        List<EpisodeRating> ratings = ratingService.getShowRatings(userId, showId);
        List<EpisodeRatingResponse> episodeRatings = ratings.stream()
                .map(DtoMapper::toEpisodeRatingResponse).toList();

        Map<Integer, BigDecimal> seasonAverages = ratings.stream()
                .collect(Collectors.groupingBy(
                        r -> r.getEpisode().getSeasonNumber(),
                        Collectors.collectingAndThen(
                                Collectors.averagingDouble(r -> r.getScore().doubleValue()),
                                avg -> BigDecimal.valueOf(avg).setScale(2, RoundingMode.HALF_UP)
                        )
                ));

        Map<String, Long> histogram = new TreeMap<>();
        for (int i = 1; i <= 10; i++) {
            histogram.put(String.valueOf(i * 0.5), 0L);
        }
        for (EpisodeRating r : ratings) {
            String key = r.getScore().stripTrailingZeros().toPlainString();
            histogram.merge(key, 1L, Long::sum);
        }

        return ResponseEntity.ok(new ShowRatingsResponse(episodeRatings, seasonAverages, histogram));
    }
}
