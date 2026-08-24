package com.myserial.api.dto.request;

import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
        @Size(max = 255) String name,
        @Size(max = 500) String bio,
        @Size(max = 500) String avatarPath
) {}
