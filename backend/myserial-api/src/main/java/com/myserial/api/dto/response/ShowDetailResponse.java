package com.myserial.api.dto.response;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record ShowDetailResponse(
        Long id,
        Integer tmdbId,
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
        List<SeasonResponse> seasons,
        List<CastMemberResponse> castPreview,
        List<CrewMemberResponse> crewPreview,
        List<StreamingProviderResponse> streamingAvailability,
        boolean isInWatchlist,
        long watchedEpisodeCount
) {}
