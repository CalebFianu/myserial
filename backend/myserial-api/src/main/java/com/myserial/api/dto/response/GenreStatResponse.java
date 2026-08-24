package com.myserial.api.dto.response;

public record GenreStatResponse(
        String genre,
        int count,
        double percentage
) {}
