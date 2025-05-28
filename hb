package com.project.movieproductionsystem.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MovieProject {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String genre;
    private Double budget;
    private LocalDate startDate;
    private LocalDate endDate;
    private boolean isTemplate;

    @ElementCollection
    private List<String> keyTeamMembers;
}
