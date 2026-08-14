package com.myserial.catalog.dto;

public record CrewMember(
        int tmdbId,
        String name,
        String department,
        String job,
        String profilePath
) {}
