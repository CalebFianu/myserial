package com.myserial.api.dto.response;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

public record FriendReviewResponse(
        Long ratingId,
        UserResponse friend,
        Long showId,
        String showTitle,
        Long episodeId,
        Integer seasonNumber,
        Integer episodeNumber,
        String episodeName,
        BigDecimal score,
        String review,
        OffsetDateTime ratedAt
) {}
