package com.myserial.api.dto.response;

import java.time.OffsetDateTime;

public record AlertResponse(
        Long id,
        Long showId,
        String showTitle,
        String title,
        String body,
        OffsetDateTime createdAt,
        OffsetDateTime readAt
) {}
