package com.myserial.catalog.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record ShowSummary(
        int tmdbId,
        String title,
        String originalTitle,
        String overview,
        String posterPath,
        String backdropPath,
        LocalDate firstAirDate,
        BigDecimal voteAverage,
        BigDecimal popularity,
        String status
) {}
