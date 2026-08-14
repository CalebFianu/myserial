package com.myserial.api.dto.request;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record RatingRequest(
        @NotNull @DecimalMin("0.5") @DecimalMax("5.0") BigDecimal score,
        String review
) {}
