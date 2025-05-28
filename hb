package com.project.movieproductionsystem.service;

import com.project.movieproductionsystem.dto.MovieProjectDTO;
import com.project.movieproductionsystem.entity.MovieProject;
import com.project.movieproductionsystem.repository.MovieProjectRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MovieProjectServiceImpl implements MovieProjectService {

    private final MovieProjectRepository repository;
    private final ModelMapper mapper;

    @Override
    public MovieProjectDTO createProject(MovieProjectDTO dto) {
        MovieProject project = mapper.map(dto, MovieProject.class);
        return mapper.map(repository.save(project), MovieProjectDTO.class);
    }

    @Override
    public List<MovieProjectDTO> getAllProjects() {
        return repository.findAll()
                .stream()
                .map(p -> mapper.map(p, MovieProjectDTO.class))
                .collect(Collectors.toList());
    }
}
