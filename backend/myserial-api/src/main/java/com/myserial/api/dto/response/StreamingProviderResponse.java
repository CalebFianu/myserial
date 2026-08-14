package com.myserial.api.dto.response;

public record StreamingProviderResponse(
        Integer providerId,
        String providerName,
        String providerLogoPath,
        String offerType,
        String countryCode,
        String link
) {}
