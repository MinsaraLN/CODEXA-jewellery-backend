SET NAMES utf8mb4;  -- tells MySQL to use the utf8mb4 character set for the current connection
-- Why use it:
--
-- utf8mb4 supports full Unicode, including emojis and rare symbols.
-- It’s better than older utf8, which only supports up to 3 bytes (and misses some characters).
-- Ensures consistent encoding between your app and database—especially important for multilingual content or customer names.

SET FOREIGN_KEY_CHECKS = 0;   -- Meaning: Temporarily disables foreign key constraint checks.
-- Why use it:

-- Allows you to create tables in any order, even if they reference each other.
-- Useful during schema setup, data import, or bulk operations.
-- You should re-enable it after setup

CREATE DATABASE IF NOT EXISTS jewellery
CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE jewellery;
-- Meaning:
--
-- Creates a database named jewellery only if it doesn’t already exist.
-- Sets its default character encoding to utf8mb4.
-- Uses collation utf8mb4_0900_ai_ci.



CREATE TABLE role (
    role_id   INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB; -- In MySQL, every table is backed by a storage engine. InnoDB is the most powerful and widely used one.
-- You're telling MySQL to use InnoDB’s features to manage how data is stored, indexed, and retrieved.
-- InnoDB is ideal for:
--
-- Relational models with foreign keys
-- Apps needing transactional safety
-- High-concurrency environments (e.g., multi-user systems)
-- Scalable web apps (Spring Boot + Flyway setup)



CREATE TABLE user (
    user_id      INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_fname   VARCHAR(100) NOT NULL,
    user_lname   VARCHAR(100) NOT NULL,
    email        VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id      INT UNSIGNED  NOT NULL,
    branch_id    INT UNSIGNED  NULL,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_role   FOREIGN KEY (role_id)   REFERENCES role(role_id)   ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_user_branch FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ON DELETE SET NULL  ON UPDATE CASCADE
) ENGINE=InnoDB;





CREATE TABLE branch (
    branch_id        INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    branch_name      VARCHAR(100) NOT NULL,
    branch_code      VARCHAR(50)  NOT NULL,
    branch_address   VARCHAR(255) NOT NULL,
    branch_telephone VARCHAR(20)  NOT NULL,
    branch_hours     VARCHAR(100) NOT NULL,
    UNIQUE KEY uq_branch_code (branch_code)
) ENGINE=InnoDB;





CREATE TABLE category (
    category_id   INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    KEY idx_category_name (category_name)
) ENGINE=InnoDB;



CREATE TABLE metal (
    metal_id     INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    metal_type   ENUM('GOLD','SILVER','ROSE_GOLD') NOT NULL,
    metal_purity VARCHAR(20) NOT NULL,
    UNIQUE KEY uq_metal_type_purity (metal_type, metal_purity),
    KEY idx_metal_type   (metal_type),
    KEY idx_metal_purity (metal_purity)
) ENGINE=InnoDB;





CREATE TABLE product (
    product_id              INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    category_id             INT UNSIGNED NOT NULL,
    metal_id                INT UNSIGNED NOT NULL,
    name                    VARCHAR(150) NOT NULL,
    size                    VARCHAR(50)  NULL,             -- size is optional
    weight                  DECIMAL(8,2) NOT NULL,         -- grams
    has_gemstone            BOOLEAN NOT NULL DEFAULT FALSE,
    initial_production_cost DECIMAL(12,2) NOT NULL,
    quantity                INT NOT NULL DEFAULT 0,
    product_description     TEXT NOT NULL,
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_product_metal    FOREIGN KEY (metal_id)    REFERENCES metal(metal_id)       ON DELETE RESTRICT ON UPDATE CASCADE,
    KEY idx_product_category (category_id),
    KEY idx_product_metal    (metal_id),
    KEY idx_product_gemstone   (has_gemstone),
    KEY idx_product_size       (size),
    KEY idx_product_weight     (weight),
    KEY idx_product_name       (name),
    KEY idx_prod_filter        (category_id, metal_id, has_gemstone)
) ENGINE=InnoDB;

-- Reason :
-- * Category -> Product = 1:N (product.category_id NOT NULL).
-- * Metal->Product = 1:N (product.metal_id NOT NULL).
-- * No price column: price is not displayed at this stage.

CREATE TABLE product_image (
    image_id   INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    product_id INT UNSIGNED NOT NULL,
    gem_id     INT UNSIGNED NULL,
    url        VARCHAR(255) NOT NULL UNIQUE,
    alt_text   VARCHAR(255) NULL,
    CONSTRAINT fk_image_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_image_gem FOREIGN KEY (gem_id) REFERENCES gem(gem_id) ON DELETE CASCADE ON UPDATE CASCADE,
    KEY idx_image_product (product_id),
    KEY idx_image_gem     (gem_id)
) ENGINE=InnoDB;

-- Reason :
-- * Product->Image = 1:N (image.product_id NOT NULL).
-- * CASCADE deletes images when a product is removed (dependent rows).

-- Optional site tab: Gems (public info), linked to products (not images).
CREATE TABLE gem (
    gem_id     INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    gem_name   VARCHAR(100) NOT NULL,
    karat_rate DECIMAL(12,2) NULL,
    KEY idx_gem_name (gem_name)
) ENGINE=InnoDB;

-- M:N for Product <-> Gem
CREATE TABLE product_gem (
    product_id INT UNSIGNED NOT NULL,
    gem_id     INT UNSIGNED NOT NULL,
    PRIMARY KEY (product_id, gem_id),
    CONSTRAINT fk_pg_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pg_gem     FOREIGN KEY (gem_id)     REFERENCES gem(gem_id)     ON DELETE RESTRICT ON UPDATE CASCADE,
    KEY idx_pg_product       (product_id),
    KEY idx_pg_gem           (gem_id),
    KEY idx_pg_gem_prod      (gem_id, product_id)
) ENGINE=InnoDB;

-- Reasoning:
-- * PDF linked Gem to product_image; that couples gem info to images.
-- * Use Product <-> Gem instead so filters like “has ruby” work cleanly.





CREATE TABLE material_rate (
    rate_id       INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    metal_id      INT UNSIGNED NOT NULL,
    rate_per_gram DECIMAL(12,2) NOT NULL,
    updated_date  DATE NOT NULL,
    updated_by    INT UNSIGNED NULL,
    CONSTRAINT fk_rate_metal FOREIGN KEY (metal_id)   REFERENCES metal(metal_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rate_user  FOREIGN KEY (updated_by) REFERENCES user(user_id)   ON DELETE SET NULL  ON UPDATE CASCADE,
    UNIQUE KEY uq_rate_metal_date (metal_id, updated_date),
    KEY idx_rate_metal      (metal_id),
    KEY idx_rate_updated_by (updated_by)
) ENGINE=InnoDB;

-- Reasoning:
-- - “Exactly one rate per metal per day”: UNIQUE(metal_id, updated_date) and updated_date NOT NULL.
--   (Your PDF had the unique note but omitted NOT NULL.)
-- - updated_by is optional: public logic doesn’t require it (bot/manual).

-- =========================
--  Services & custom designs
-- =========================

CREATE TABLE service_ticket (
    service_id        INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    branch_id         INT UNSIGNED NULL,            -- optional: ticket can be general
    assigned_user_id  INT UNSIGNED NULL,            -- optional: staff assignment
    type              ENUM('CLEANING','REPAIR') NOT NULL,
    customer_fname    VARCHAR(100) NOT NULL,
    customer_lname    VARCHAR(100) NOT NULL,
    contact_number    VARCHAR(20)  NOT NULL,
    email             VARCHAR(150) NOT NULL,
    preferred_date    DATE NULL,
    ticket_date       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note              TEXT NULL,
    status            ENUM('NEW','IN_PROGRESS','DONE','CANCELLED') NOT NULL DEFAULT 'NEW',
    CONSTRAINT fk_ticket_branch FOREIGN KEY (branch_id)        REFERENCES branch(branch_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_user   FOREIGN KEY (assigned_user_id) REFERENCES user(user_id)    ON DELETE SET NULL ON UPDATE CASCADE,
    KEY idx_ticket_branch (branch_id),
    KEY idx_ticket_status (status)
) ENGINE=InnoDB;

-- Reasoning:
-- - Branch↔Ticket = 0..N / 0..1 (optional linkage).
-- - Public can submit tickets; assignment to a staff user is optional (your PDF had user_id NOT NULL — changed).
-- - WhatsApp status check uses service_id; no extra storage needed.

CREATE TABLE custom_design (
    design_id         INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    assigned_user_id  INT UNSIGNED NULL,            -- optional staff handler
    customer_fname    VARCHAR(100) NOT NULL,
    customer_lname    VARCHAR(100) NOT NULL,
    email             VARCHAR(150) NOT NULL,
    contact_number    VARCHAR(20)  NOT NULL,
    budget            DECIMAL(12,2) NULL,
    image             VARCHAR(255) NOT NULL,        -- URL; use another table for multiple images
    ticket_date       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status            ENUM('NEW','REVIEWED','IN_PROGRESS','QUOTED','CLOSED') NOT NULL DEFAULT 'NEW',
    preferred_metal_id INT UNSIGNED NULL,           -- 0..1 preferred metal
    CONSTRAINT fk_design_user  FOREIGN KEY (assigned_user_id)   REFERENCES user(user_id)  ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_design_metal FOREIGN KEY (preferred_metal_id) REFERENCES metal(metal_id) ON DELETE SET NULL ON UPDATE CASCADE,
    KEY idx_design_status (status),
    KEY idx_design_pref_metal (preferred_metal_id)
) ENGINE=InnoDB;

-- Reasoning:
-- - Public can submit designs; assignment optional (PDF had user_id NOT NULL — changed).
-- - preferred_metal is optional (0..1).

-- =========================
--  Reviews (curated Google reviews)
-- =========================

CREATE TABLE review (
    review_id                      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    google_review_id               VARCHAR(255) NULL UNIQUE,
    reviewer_name                  VARCHAR(255) NOT NULL,
    reviewer_profile_photo_url     VARCHAR(500) NULL,
    rating                         TINYINT UNSIGNED NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text                    TEXT NOT NULL,
    review_date                    TIMESTAMP NOT NULL,
    is_active                      BOOLEAN NOT NULL DEFAULT TRUE,       -- use to “select” for homepage
    display_order                  INT NOT NULL DEFAULT 0,               -- manual ordering on site
    selected_by_user_id            INT UNSIGNED NULL,                    -- staff who curated it
    selected_date                  TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    business_location              VARCHAR(255) NOT NULL,
    review_source                  VARCHAR(50) NOT NULL DEFAULT 'Google',
    created_at                     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_selected_by FOREIGN KEY (selected_by_user_id) REFERENCES user(user_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Reasoning:
-- - Keep google_review_id UNIQUE for dedupe (from your PDF). But do NOT force one review per staff:
--   replace user_id UNIQUE with selected_by_user_id NULL (curator).

-- =========================
--  Seasonal offers (frontend content + DB links)
-- =========================

CREATE TABLE seasonal_offer (
    offer_id   INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    slug       VARCHAR(80) NOT NULL UNIQUE,  -- reference for your hard-coded content
    title      VARCHAR(150) NOT NULL,
    start_date DATE NULL,
    end_date   DATE NULL,
    is_active  BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- Junction: many Products can belong to many Offers
CREATE TABLE product_offer (
    product_id INT UNSIGNED NOT NULL,
    offer_id   INT UNSIGNED NOT NULL,
    PRIMARY KEY (product_id, offer_id),
    CONSTRAINT fk_po_product FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_po_offer   FOREIGN KEY (offer_id)   REFERENCES seasonal_offer(offer_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Reasoning:
-- * PDF used product.offer_id NOT NULL (single offer per product). Replace with M:N via product_offer so
--   you can attach multiple products to a seasonal offer without rewriting product rows. :

SET FOREIGN_KEY_CHECKS = 1;
