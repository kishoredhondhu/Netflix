-- BudgetCategory table
CREATE TABLE budget_category (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    project_id BIGINT,
    CONSTRAINT fk_budget_project FOREIGN KEY (project_id)
        REFERENCES movie_project(id) ON DELETE CASCADE
);

-- BudgetLineItem table
CREATE TABLE budget_line_item (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    estimated_cost DOUBLE NOT NULL,
    actual_cost DOUBLE NOT NULL,
    category_id BIGINT,
    CONSTRAINT fk_lineitem_category FOREIGN KEY (category_id)
        REFERENCES budget_category(id) ON DELETE CASCADE
);
