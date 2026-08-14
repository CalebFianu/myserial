package com.myserial.api.dto.request;

import jakarta.validation.constraints.NotNull;

public record AddItemRequest(
        @NotNull Long showId
) {}
