package com.myserial.api.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateListRequest(
        @NotBlank @Size(max = 255) String name,
        String note
) {}
