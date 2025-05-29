package com.project.movieproductionsystem.service;

import com.project.movieproductionsystem.dto.SceneDTO;

import java.util.List;

public interface SceneService {
    SceneDTO createScene(SceneDTO dto);
    List<SceneDTO> getScenesByProjectId(Long projectId);
}
