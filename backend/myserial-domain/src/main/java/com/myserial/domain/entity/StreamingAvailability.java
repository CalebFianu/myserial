package com.myserial.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;

@Entity
@Table(name = "streaming_availability")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StreamingAvailability {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "show_id", nullable = false)
    private Show show;

    @Column(name = "provider_id", nullable = false)
    private Integer providerId;

    @Column(name = "provider_name", nullable = false, length = 255)
    private String providerName;

    @Column(name = "provider_logo_path", length = 500)
    private String providerLogoPath;

    @Column(name = "country_code", nullable = false, length = 10)
    private String countryCode;

    @Column(name = "offer_type", length = 50)
    private String offerType;

    @Column(length = 1000)
    private String link;

    @Column(name = "last_synced_at")
    private OffsetDateTime lastSyncedAt;
}
