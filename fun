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
public class CastCrewMember {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String role;
    private String contactEmail;
    private String contactPhone;

    @Enumerated(EnumType.STRING)
    private ContractStatus contractStatus;

    @ElementCollection
    private List<LocalDate> availabilityDates;

    private String contractFileName;
}
