package com.myserial.api.dto.response;

import java.time.OffsetDateTime;

public record BingeTrackResponse(
        Long id,
        ShowSummaryResponse show,
        Boolean wrapped,
        Boolean alerted,
        OffsetDateTime createdAt,
        OffsetDateTime wrappedAt
) {}
