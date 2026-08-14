package com.myserial.api.dto.response;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

public record EpisodeRatingResponse(
        Long id,
        Long episodeId,
        Integer seasonNumber,
        Integer episodeNumber,
        String episodeName,
        BigDecimal score,
        String review,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt
) {}
