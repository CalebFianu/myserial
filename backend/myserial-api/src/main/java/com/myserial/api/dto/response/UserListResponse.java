package com.myserial.api.dto.response;

import java.time.OffsetDateTime;
import java.util.List;

public record UserListResponse(
        Long id,
        String name,
        String note,
        Boolean isWatchlist,
        OffsetDateTime createdAt,
        List<ShowSummaryResponse> shows
) {}
