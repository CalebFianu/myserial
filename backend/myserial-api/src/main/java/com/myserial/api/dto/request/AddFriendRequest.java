package com.myserial.api.dto.request;

import jakarta.validation.constraints.NotBlank;

public record AddFriendRequest(
        @NotBlank String handle
) {}
