package com.project.movieproductionsystem.service.impl;

import com.project.movieproductionsystem.dto.CastCrewMemberDTO;
import com.project.movieproductionsystem.entity.CastCrewMember;
import com.project.movieproductionsystem.entity.ContractStatus;
import com.project.movieproductionsystem.repository.CastCrewRepository;
import com.project.movieproductionsystem.service.CastCrewService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CastCrewServiceImpl implements CastCrewService {

    private final CastCrewRepository repo;
    private final ModelMapper mapper;

    @Override
    public CastCrewMemberDTO create(CastCrewMemberDTO dto) {
        CastCrewMember entity = mapper.map(dto, CastCrewMember.class);
        entity.setContractStatus(ContractStatus.valueOf(dto.getContractStatus()));
        return mapper.map(repo.save(entity), CastCrewMemberDTO.class);
    }

    @Override
    public List<CastCrewMemberDTO> getAll() {
        return repo.findAll().stream()
                .map(member -> mapper.map(member, CastCrewMemberDTO.class))
                .collect(Collectors.toList());
    }

    @Override
    public CastCrewMemberDTO getById(Long id) {
        return repo.findById(id)
                .map(member -> mapper.map(member, CastCrewMemberDTO.class))
                .orElseThrow(() -> new RuntimeException("Cast/Crew not found"));
    }

    @Override
    public CastCrewMemberDTO update(Long id, CastCrewMemberDTO dto) {
        CastCrewMember existing = repo.findById(id).orElseThrow();
        existing.setName(dto.getName());
        existing.setRole(dto.getRole());
        existing.setContactEmail(dto.getContactEmail());
        existing.setContactPhone(dto.getContactPhone());
        existing.setContractStatus(ContractStatus.valueOf(dto.getContractStatus()));
        existing.setAvailabilityDates(dto.getAvailabilityDates());
        existing.setContractFileName(dto.getContractFileName());
        return mapper.map(repo.save(existing), CastCrewMemberDTO.class);
    }

    @Override
    public void delete(Long id) {
        repo.deleteById(id);
    }
}
