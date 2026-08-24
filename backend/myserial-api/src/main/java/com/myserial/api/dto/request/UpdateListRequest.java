package com.myserial.api.dto.request;

import jakarta.validation.constraints.Size;

public record UpdateListRequest(
        @Size(max = 255) String name,
        String note
) {}
