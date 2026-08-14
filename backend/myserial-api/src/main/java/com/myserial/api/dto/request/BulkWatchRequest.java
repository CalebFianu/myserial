package com.myserial.api.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record BulkWatchRequest(
        @NotNull Long showId,
        @NotNull @Min(1) Integer seasonNumber
) {}
