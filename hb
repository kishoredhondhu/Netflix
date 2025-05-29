package com.movieproduction.repository;

import com.movieproduction.entity.ScriptVersion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ScriptVersionRepository extends JpaRepository<ScriptVersion, Long> {
    int countByFileName(String fileName);
}
