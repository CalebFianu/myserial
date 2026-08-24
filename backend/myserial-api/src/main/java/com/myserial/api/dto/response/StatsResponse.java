package com.myserial.api.dto.response;

import java.util.List;
import java.util.Map;

public record StatsResponse(
        long episodesWatched,
        long totalMinutes,
        Map<String, Long> ratingsHistogram,
        List<GenreStatResponse> genreBreakdown
) {}
