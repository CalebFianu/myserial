package com.myserial.api.dto.response;

import java.util.List;

public record CastResponse(
        List<CastMemberResponse> cast,
        List<CrewMemberResponse> crew
) {}
