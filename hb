package com.project.movieproductionsystem.repository;

import com.project.movieproductionsystem.entity.MovieProject;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MovieProjectRepository extends JpaRepository<MovieProject, Long> {
}
