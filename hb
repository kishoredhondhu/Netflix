package com.project.movieproductionsystem.service;

import com.project.movieproductionsystem.dto.MovieProjectDTO;
import java.util.List;

public interface MovieProjectService {
    MovieProjectDTO createProject(MovieProjectDTO dto);
    List<MovieProjectDTO> getAllProjects();
}
