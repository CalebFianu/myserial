package com.myserial.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;

@Entity
@Table(name = "watched_episodes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WatchedEpisode {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "episode_id", nullable = false)
    private Episode episode;

    @Column(name = "watched_at", nullable = false)
    private OffsetDateTime watchedAt;

    @PrePersist
    protected void onCreate() {
        if (watchedAt == null) {
            watchedAt = OffsetDateTime.now();
        }
    }
}
