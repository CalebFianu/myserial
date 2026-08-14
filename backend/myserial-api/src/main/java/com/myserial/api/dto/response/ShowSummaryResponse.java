package com.myserial.api.dto.response;

import java.math.BigDecimal;
import java.time.LocalDate;

public record ShowSummaryResponse(
        Long id,
        Integer tmdbId,
        String title,
        String originalTitle,
        String overview,
        String posterPath,
        String backdropPath,
        LocalDate firstAirDate,
        BigDecimal voteAverage,
        BigDecimal popularity,
        String status,
        String network
) {}
