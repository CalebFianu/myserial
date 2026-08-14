package com.myserial.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "people")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Person {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "tmdb_id", nullable = false, unique = true)
    private Integer tmdbId;

    @Column(nullable = false, length = 255)
    private String name;

    @Column(name = "profile_path", length = 500)
    private String profilePath;

    @Column(name = "known_for_department", length = 100)
    private String knownForDepartment;

    @Column(columnDefinition = "TEXT")
    private String biography;
}
