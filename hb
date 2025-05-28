package com.project.movieproductionsystem.controller;

import com.project.movieproductionsystem.dto.MovieProjectDTO;
import com.project.movieproductionsystem.service.MovieProjectService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/projects")
@RequiredArgsConstructor
public class MovieProjectController {

    private final MovieProjectService service;

    @PostMapping
    public ResponseEntity<MovieProjectDTO> create(@RequestBody MovieProjectDTO dto) {
        return ResponseEntity.ok(service.createProject(dto));
    }

    @GetMapping
    public ResponseEntity<List<MovieProjectDTO>> getAll() {
        return ResponseEntity.ok(service.getAllProjects());
    }
}
