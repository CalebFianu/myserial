package com.myserial.api.dto.response;

public record CastMemberResponse(
        Long personId,
        Integer tmdbPersonId,
        String name,
        String characterName,
        String profilePath,
        Integer displayOrder
) {}
