CREATE TABLE movie_project (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    genre VARCHAR(255),
    budget DOUBLE,
    start_date DATE,
    end_date DATE,
    is_template BOOLEAN
);

CREATE TABLE movie_project_key_team_members (
    movie_project_id BIGINT,
    key_team_members VARCHAR(255)
);
