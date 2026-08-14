package com.myserial.api.dto.response;

public record TokenResponse(
        String accessToken,
        String refreshToken,
        UserResponse user
) {}
