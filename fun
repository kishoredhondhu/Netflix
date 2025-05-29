package com.project.movieproductionsystem.repository;

import com.project.movieproductionsystem.entity.Scene;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SceneRepository extends JpaRepository<Scene, Long> {
    List<Scene> findByProjectId(Long projectId);
}



package com.project.movieproductionsystem.repository;

import com.project.movieproductionsystem.entity.ShootingDay;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ShootingDayRepository extends JpaRepository<ShootingDay, Long> {
    List<ShootingDay> findByProjectId(Long projectId);
}
