package com.project.movieproductionsystem.controller;

import com.project.movieproductionsystem.dto.CastCrewMemberDTO;
import com.project.movieproductionsystem.service.CastCrewService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cast-crew")
@RequiredArgsConstructor
@CrossOrigin
public class CastCrewController {

    private final CastCrewService service;

    @PostMapping
    public CastCrewMemberDTO create(@RequestBody CastCrewMemberDTO dto) {
        return service.create(dto);
    }

    @GetMapping
    public List<CastCrewMemberDTO> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public CastCrewMemberDTO getById(@PathVariable Long id) {
        return service.getById(id);
    }

    @PutMapping("/{id}")
    public CastCrewMemberDTO update(@PathVariable Long id, @RequestBody CastCrewMemberDTO dto) {
        return service.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
