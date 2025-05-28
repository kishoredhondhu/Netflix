CREATE TABLE cast_crew_member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    role VARCHAR(100),
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    contract_status VARCHAR(20),
    contract_file_name VARCHAR(255)
);

CREATE TABLE cast_crew_member_availability_dates (
    cast_crew_member_id BIGINT,
    availability_dates DATE,
    FOREIGN KEY (cast_crew_member_id) REFERENCES cast_crew_member(id)
);
