package com.myserial.catalog.dto;

import java.time.LocalDate;
import java.util.List;

public record SeasonDetail(
        int tmdbId,
        int seasonNumber,
        String name,
        String overview,
        String posterPath,
        LocalDate airDate,
        List<EpisodeDetail> episodes
) {}
