package com.project.movieproductionsystem.dto;

import lombok.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MovieProjectDTO {
    private Long id;
    private String title;
    @JsonDeserialize(as=ArrayList.class)
    private List<String> genre;
    private Double budget;
    private LocalDate startDate;
    private LocalDate endDate;
    @JsonProperty("isTemplate")
    private boolean isTemplate;
    private List<String> keyTeamMembers;
}
Genres null
--- DTO Received in createProject: MovieProjectDTO(id=null, title=Default Sci-Fi Adventure, genre=null, budget=7500000.0, startDate=2025-08-01, endDate=2026-02-15, isTemplate=true, keyTeamMembers=[Kishore Kumar, Alia Shane])
--- Entity MANUALLY MAPPED (Before Save): MovieProject(id=null, title=Default Sci-Fi Adventure, budget=7500000.0, startDate=2025-08-01, endDate=2026-02-15, isTemplate=true, keyTeamMembers=[Kishore Kumar, Alia Shane], genre=[])
Hibernate: insert into movie_project (budget,end_date,is_template,start_date,title) values (?,?,?,?,?)
Hibernate: insert into movie_project_key_team_members (movie_project_id,key_team_members) values (?,?)
Hibernate: insert into movie_project_key_team_members (movie_project_id,key_team_members) values (?,?)
--- Entity SAVED: MovieProject(id=23, title=Default Sci-Fi Adventure, budget=7500000.0, startDate=2025-08-01, endDate=2026-02-15, isTemplate=true, keyTeamMembers=[Kishore Kumar, Alia Shane], genre=[])
--- Fetching all projects ---
Hibernate: select mp1_0.id,mp1_0.budget,mp1_0.end_date,mp1_0.is_template,mp1_0.start_date,mp1_0.title from movie_project mp1_0
--- Projects found in DB: 19


but if i enter the data through postman instead of angular this is the result


Genres [Sci-Fi, Thriller]
--- DTO Received in createProject: MovieProjectDTO(id=null, title=My  Test Project, genre=[Sci-Fi, Thriller], budget=1.25000005E7, startDate=2025-09-15, endDate=2026-04-20, isTemplate=true, keyTeamMembers=[Lead Coder, QA Lead, UX Designer])
--- Entity MANUALLY MAPPED (Before Save): MovieProject(id=null, title=My  Test Project, budget=1.25000005E7, startDate=2025-09-15, endDate=2026-04-20, isTemplate=true, keyTeamMembers=[Lead Coder, QA Lead, UX Designer], genre=[Sci-Fi, Thriller])
Hibernate: insert into movie_project (budget,end_date,is_template,start_date,title) values (?,?,?,?,?)
Hibernate: insert into movie_project_genre (movie_project_id,genre) values (?,?)
Hibernate: insert into movie_project_genre (movie_project_id,genre) values (?,?)
Hibernate: insert into movie_project_key_team_members (movie_project_id,key_team_members) values (?,?)
Hibernate: insert into movie_project_key_team_members (movie_project_id,key_team_members) values (?,?)
Hibernate: insert into movie_project_key_team_members (movie_project_id,key_team_members) values (?,?)
--- Entity SAVED: MovieProject(id=24, title=My  Test Project, budget=1.25000005E7, startDate=2025-09-15, endDate=2026-04-20, isTemplate=true, keyTeamMembers=[Lead Coder, QA Lead, UX Designer], genre=[Sci-Fi, Thriller])
--- Fetching all projects ---
Hibernate: select mp1_0.id,mp1_0.budget,mp1_0.end_date,mp1_0.is_template,mp1_0.start_date,mp1_0.title from movie_project mp1_0
--- Projects found in DB: 20
