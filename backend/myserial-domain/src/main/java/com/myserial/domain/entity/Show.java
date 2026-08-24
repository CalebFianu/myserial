package com.myserial.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "shows")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Show {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "tmdb_id", nullable = false, unique = true)
    private Integer tmdbId;

    @Column(name = "tvmaze_id")
    private Integer tvmazeId;

    @Column(nullable = false, length = 500)
    private String title;

    @Column(name = "original_title", length = 500)
    private String originalTitle;

    @Column(columnDefinition = "TEXT")
    private String overview;

    @Column(length = 50)
    private String status;

    @Column(name = "first_air_date")
    private LocalDate firstAirDate;

    @Column(name = "last_air_date")
    private LocalDate lastAirDate;

    @Column(name = "poster_path", length = 500)
    private String posterPath;

    @Column(name = "backdrop_path", length = 500)
    private String backdropPath;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String genres;

    @Column(length = 255)
    private String network;

    @Column(name = "episode_run_time")
    private Integer episodeRunTime;

    @Column(name = "vote_average", precision = 3, scale = 1)
    private BigDecimal voteAverage;

    @Column(name = "vote_count")
    private Integer voteCount;

    @Column(name = "popularity", precision = 10, scale = 3)
    private BigDecimal popularity;

    @Column(name = "last_synced_at")
    private OffsetDateTime lastSyncedAt;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @OneToMany(mappedBy = "show", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Season> seasons = new ArrayList<>();

    @OneToMany(mappedBy = "show", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Episode> episodes = new ArrayList<>();

    @OneToMany(mappedBy = "show", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Credit> credits = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = OffsetDateTime.now();
        }
    }
}
