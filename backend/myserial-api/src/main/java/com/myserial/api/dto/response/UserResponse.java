package com.myserial.api.dto.response;

import java.time.OffsetDateTime;

public record UserResponse(
        Long id,
        String name,
        String email,
        String handle,
        String bio,
        String avatarPath,
        Boolean onboardingCompleted,
        OffsetDateTime createdAt
) {}
