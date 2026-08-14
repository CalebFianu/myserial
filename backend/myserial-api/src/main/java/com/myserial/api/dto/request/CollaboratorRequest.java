package com.myserial.api.dto.request;

import jakarta.validation.constraints.NotNull;

public record CollaboratorRequest(
        @NotNull Long userId
) {}
