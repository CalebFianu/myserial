package com.myserial.api.dto.response;

import java.util.List;

public record PersonResponse(
        Long id,
        Integer tmdbId,
        String name,
        String profilePath,
        String knownForDepartment,
        String biography,
        List<ShowSummaryResponse> knownFor
) {}
