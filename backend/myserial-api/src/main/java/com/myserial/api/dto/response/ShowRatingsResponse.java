package com.myserial.api.dto.response;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public record ShowRatingsResponse(
        List<EpisodeRatingResponse> episodeRatings,
        Map<Integer, BigDecimal> seasonAverages,
        Map<String, Long> histogram
) {}
