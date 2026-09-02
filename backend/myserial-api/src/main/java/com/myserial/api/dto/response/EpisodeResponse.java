package com.myserial.api.dto.response;

import java.math.BigDecimal;
import java.time.LocalDate;

public record EpisodeResponse(
        Long id,
        Integer tmdbId,
        Integer seasonNumber,
        Integer episodeNumber,
        String name,
        String overview,
        LocalDate airDate,
        String stillPath,
        Integer runtime,
        BigDecimal voteAverage,
        boolean isWatched
) {}
