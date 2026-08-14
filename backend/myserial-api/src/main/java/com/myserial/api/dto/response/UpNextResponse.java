package com.myserial.api.dto.response;

public record UpNextResponse(
        ShowSummaryResponse show,
        EpisodeResponse nextEpisode
) {}
