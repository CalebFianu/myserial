package com.myserial.api.dto.response;

import java.time.LocalDate;
import java.util.List;

public record SeasonResponse(
        Long id,
        Integer tmdbId,
        Integer seasonNumber,
        String name,
        String overview,
        String posterPath,
        LocalDate airDate,
        Integer episodeCount,
        List<EpisodeResponse> episodes
) {}
