package com.myserial.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;

@Entity
@Table(name = "rewatches")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Rewatch {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "show_id", nullable = false)
    private Show show;

    @Column(nullable = false)
    @Builder.Default
    private Integer count = 1;

    @Column(name = "last_rewatched_at", nullable = false)
    private OffsetDateTime lastRewatchedAt;

    @PrePersist
    protected void onCreate() {
        if (lastRewatchedAt == null) {
            lastRewatchedAt = OffsetDateTime.now();
        }
    }
}
