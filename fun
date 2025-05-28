Genres [Action, Comedy, Sci-Fi]
--- DTO Received in createProject: MovieProjectDTO(id=null, title=Default Sci-Fi Adventure, genres=[Action, Comedy, Sci-Fi], budget=7500000.0, startDate=2025-08-01, endDate=2026-02-15, isTemplate=true, keyTeamMembers=[Kishore Kumar, Alia Shane])
--- Entity MANUALLY MAPPED (Before Save): MovieProject(id=null, title=Default Sci-Fi Adventure, budget=7500000.0, startDate=2025-08-01, endDate=2026-02-15, isTemplate=true, keyTeamMembers=[Kishore Kumar, Alia Shane], genres=[Action, Comedy, Sci-Fi])
Hibernate: insert into movie_project (budget,end_date,is_template,start_date,title) values (?,?,?,?,?)
Hibernate: insert into movie_project_genres (movie_project_id,genres) values (?,?)
Hibernate: insert into movie_project_genres (movie_project_id,genres) values (?,?)
Hibernate: insert into movie_project_genres (movie_project_id,genres) values (?,?)
Hibernate: insert into movie_project_key_team_members (movie_project_id,key_team_members) values (?,?)
Hibernate: insert into movie_project_key_team_members (movie_project_id,key_team_members) values (?,?)
--- Entity SAVED: MovieProject(id=29, title=Default Sci-Fi Adventure, budget=7500000.0, startDate=2025-08-01, endDate=2026-02-15, isTemplate=true, keyTeamMembers=[Kishore Kumar, Alia Shane], genres=[Action, Comedy, Sci-Fi])
--- Fetching all projects ---
Hibernate: select mp1_0.id,mp1_0.budget,mp1_0.end_date,mp1_0.is_template,mp1_0.start_date,mp1_0.title from movie_project mp1_0
--- Projects found in DB: 25
