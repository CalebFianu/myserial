package com.myserial.api.dto.response;

import java.time.OffsetDateTime;

public record ActivityEventResponse(
        Long id,
        Long userId,
        String userHandle,
        String eventType,
        Long showId,
        String showTitle,
        Long episodeId,
        Integer seasonNumber,
        Integer episodeNumber,
        Long listId,
        String metadata,
        OffsetDateTime createdAt
) {}
