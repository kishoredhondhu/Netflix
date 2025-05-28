USE movieproductionlogin;

INSERT INTO users (username, password, role)
VALUES (
  'admin',
  '$2a$10$0NkkknISnYZzK0jPBNhUw.CZyMdG0T9MrDhQW0sW23G.LvvYRBWiy',  -- this is 'admin123'
  'PRODUCTION_MANAGER'
);
