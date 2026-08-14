package com.myserial.catalog.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record ShowDetail(
        int tmdbId,
        String title,
        String originalTitle,
        String overview,
        String status,
        LocalDate firstAirDate,
        LocalDate lastAirDate,
        String posterPath,
        String backdropPath,
        String genres,
        String network,
        Integer episodeRunTime,
        BigDecimal voteAverage,
        Integer voteCount,
        BigDecimal popularity,
        List<SeasonDetail> seasons,
        List<CastMember> cast,
        List<CrewMember> crew,
        List<WatchProviderInfo> watchProviders
) {}
