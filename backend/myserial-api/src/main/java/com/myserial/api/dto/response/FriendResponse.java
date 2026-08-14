package com.myserial.api.dto.response;

import java.time.OffsetDateTime;

public record FriendResponse(
        Long id,
        String name,
        String handle,
        String avatarPath,
        OffsetDateTime friendSince,
        EpisodeResponse currentEpisode,
        ShowSummaryResponse currentShow
) {}
