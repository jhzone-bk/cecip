-- CECIP Database Schema - MySQL 8.0

CREATE TABLE IF NOT EXISTS brands (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uuid CHAR(36) NOT NULL UNIQUE,
    name_cn VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    logo VARCHAR(500),
    country VARCHAR(100) DEFAULT 'China',
    description TEXT,
    website VARCHAR(500),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_slug (slug),
    INDEX idx_name_en (name_en),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    brand_id INT NOT NULL,
    name_cn VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    vehicle_type VARCHAR(50),
    price_range VARCHAR(100),
    launch_date DATE,
    battery_supplier VARCHAR(100),
    segment VARCHAR(50),
    status ENUM('active', 'inactive') DEFAULT 'active',
    cover_image VARCHAR(500),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE RESTRICT,
    INDEX idx_brand_id (brand_id),
    INDEX idx_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sources (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type ENUM('forum', 'social_media', 'news', 'official', 'other') DEFAULT 'other',
    homepage VARCHAR(500),
    crawler_plugin VARCHAR(100),
    status ENUM('active', 'inactive', 'error') DEFAULT 'active',
    rate_limit INT DEFAULT 1,
    crawl_interval INT DEFAULT 3600,
    last_crawl_time TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS raw_contents (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_id INT,
    vehicle_id INT,
    brand_id INT,
    url VARCHAR(1000) NOT NULL,
    title VARCHAR(500),
    author VARCHAR(200),
    publish_time TIMESTAMP NULL,
    content LONGTEXT,
    raw_json JSON,
    language VARCHAR(10) DEFAULT 'zh',
    hash VARCHAR(64) NOT NULL UNIQUE,
    crawl_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'processed', 'failed') DEFAULT 'pending',
    INDEX idx_hash (hash),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_publish_time (publish_time),
    FULLTEXT INDEX ft_content (content)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ai_tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    task_type VARCHAR(50) NOT NULL,
    target_type VARCHAR(50),
    target_id INT,
    model VARCHAR(100),
    status ENUM('pending', 'running', 'success', 'failed') DEFAULT 'pending',
    token_input INT DEFAULT 0,
    token_output INT DEFAULT 0,
    duration DECIMAL(10,2),
    retry_count INT DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP NULL,
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS insights (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT,
    content_id BIGINT,
    summary TEXT,
    positive_points JSON,
    negative_points JSON,
    complaints JSON,
    advantages JSON,
    confidence_score DECIMAL(5,2),
    trend_score DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_confidence_score (confidence_score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS evidence (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    insight_id BIGINT,
    content_id BIGINT,
    quote TEXT,
    source_url VARCHAR(1000),
    weight DECIMAL(5,2),
    confidence DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_insight_id (insight_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS articles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT,
    brand_id INT,
    title VARCHAR(500) NOT NULL,
    slug VARCHAR(500) NOT NULL UNIQUE,
    summary TEXT,
    content_md LONGTEXT,
    content_html LONGTEXT,
    seo_title VARCHAR(500),
    meta_description TEXT,
    status ENUM('draft', 'ai_review', 'human_review', 'published', 'archived') DEFAULT 'draft',
    published_at TIMESTAMP NULL,
    author_type ENUM('ai', 'human') DEFAULT 'ai',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_slug (slug),
    INDEX idx_status (status),
    INDEX idx_vehicle_id (vehicle_id),
    INDEX idx_published_at (published_at),
    FULLTEXT INDEX ft_content (content_md)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS article_versions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    article_id INT NOT NULL,
    version INT NOT NULL,
    content_md LONGTEXT,
    editor VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE,
    UNIQUE KEY uk_article_version (article_id, version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS review_tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    article_id INT NOT NULL,
    reviewer VARCHAR(100),
    status ENUM('pending', 'approved', 'rejected', 'revision') DEFAULT 'pending',
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP NULL,
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS publish_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    article_id INT NOT NULL,
    channel VARCHAR(50) DEFAULT 'website',
    status ENUM('success', 'failed') DEFAULT 'success',
    publish_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    error_message TEXT,
    INDEX idx_article_id (article_id),
    INDEX idx_publish_time (publish_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(200) NOT NULL UNIQUE,
    password_hash VARCHAR(200) NOT NULL,
    role_id INT DEFAULT 2,
    status ENUM('active', 'inactive') DEFAULT 'active',
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    permission VARCHAR(100) NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS system_configs (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS system_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    module VARCHAR(50) NOT NULL,
    operator VARCHAR(100),
    action VARCHAR(200),
    status ENUM('success', 'warning', 'error') DEFAULT 'success',
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_module (module),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Default roles
INSERT IGNORE INTO roles (id, role_name, description) VALUES
(1, 'admin', 'System Administrator'),
(2, 'editor', 'Editor'),
(3, 'viewer', 'Read-only User');

-- Default admin (password: admin123, hash to be updated)
INSERT IGNORE INTO users (username, email, password_hash, role_id) VALUES
('admin', 'admin@cecip.com', 'pbkdf2:sha256:600000$xxx', 1);