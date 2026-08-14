package com.myserial.catalog.dto;

public record CastMember(
        int tmdbId,
        String name,
        String characterName,
        String profilePath,
        int order
) {}
