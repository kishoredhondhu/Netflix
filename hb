package com.project.movieproductionsystem.dto;

import lombok.*;
import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MovieProjectDTO {
    private Long id;
    private String title;
    private String genre;
    private Double budget;
    private LocalDate startDate;
    private LocalDate endDate;
    private boolean isTemplate;
    private List<String> keyTeamMembers;
}
