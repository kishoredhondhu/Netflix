package com.movieproduction.dto;

import lombok.*;
import org.springframework.web.multipart.MultipartFile;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
public class ScriptUploadRequestDTO {
    private MultipartFile file;
    private String uploadedBy;
}


package com.movieproduction.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScriptVersionResponseDTO {
    private Long id;
    private String fileName;
    private int versionNumber;
    private String uploadedBy;
    private LocalDateTime uploadedAt;
}
