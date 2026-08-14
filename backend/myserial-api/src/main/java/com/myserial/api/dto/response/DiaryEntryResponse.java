package com.myserial.api.dto.response;

import java.time.OffsetDateTime;

public record DiaryEntryResponse(
        Long watchedEpisodeId,
        Long showId,
        String showTitle,
        String showPosterPath,
        EpisodeResponse episode,
        OffsetDateTime watchedAt
) {}
