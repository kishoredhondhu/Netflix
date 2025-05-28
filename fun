package com.project.movieproductionsystem.service;

import com.project.movieproductionsystem.dto.CastCrewMemberDTO;
import java.util.List;

public interface CastCrewService {
    CastCrewMemberDTO create(CastCrewMemberDTO dto);
    List<CastCrewMemberDTO> getAll();
    CastCrewMemberDTO getById(Long id);
    CastCrewMemberDTO update(Long id, CastCrewMemberDTO dto);
    void delete(Long id);
}
