package com.movieproduction.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScriptVersion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String fileName;

    private int versionNumber;

    private String uploadedBy;

    private LocalDateTime uploadedAt;

    private String storagePath;
}
