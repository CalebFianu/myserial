package com.myserial.catalog.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record EpisodeDetail(
        int tmdbId,
        int seasonNumber,
        int episodeNumber,
        String name,
        String overview,
        LocalDate airDate,
        String stillPath,
        Integer runtime,
        BigDecimal voteAverage
) {}
