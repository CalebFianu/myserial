package com.myserial.api.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record BulkWatchEpisodesRequest(
        @NotNull Long showId,
        @NotEmpty List<Long> episodeIds
) {}
