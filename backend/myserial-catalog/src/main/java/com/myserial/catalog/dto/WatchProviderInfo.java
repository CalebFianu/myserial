package com.myserial.catalog.dto;

public record WatchProviderInfo(
        int providerId,
        String providerName,
        String logoPath,
        String offerType,
        String countryCode,
        String link
) {}
