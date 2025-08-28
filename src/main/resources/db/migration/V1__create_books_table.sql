-- src/main/resources/db/migration/V1__create_books_table.sql
CREATE TABLE IF NOT EXISTS books (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title  VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    price  DECIMAL(10,2) NOT NULL
    );
