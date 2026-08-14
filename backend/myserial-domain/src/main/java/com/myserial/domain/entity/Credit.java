package com.myserial.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "credits")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Credit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "person_id", nullable = false)
    private Person person;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "show_id", nullable = false)
    private Show show;

    @Column(name = "character_name", length = 500)
    private String characterName;

    @Column(name = "credit_type", nullable = false, length = 20)
    private String creditType;

    @Column(length = 100)
    private String department;

    @Column(length = 100)
    private String job;

    @Column(name = "display_order")
    private Integer displayOrder;
}
