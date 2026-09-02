package com.myserial.api.dto.request;

import jakarta.validation.constraints.NotNull;

public record BulkWatchProgressRequest(
        @NotNull Long showId,
        @NotNull Integer seasonNumber,
        @NotNull Integer episodeNumber
) {}
