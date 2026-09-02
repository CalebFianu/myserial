package com.myserial.api.dto.response;

public record SeedResponse(
        int requestedCount,
        int rosterCount,
        int hydratedCount,
        String message
) {}
