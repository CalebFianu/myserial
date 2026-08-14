package com.myserial.api.dto.response;

public record CrewMemberResponse(
        Long personId,
        Integer tmdbPersonId,
        String name,
        String department,
        String job,
        String profilePath
) {}
