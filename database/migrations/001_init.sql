-- CECIP Database Schema - PostgreSQL 16
-- Converted from MySQL to PostgreSQL syntax

CREATE TABLE IF NOT EXISTS brands (
    id SERIAL PRIMARY KEY,
    uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    name_cn VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    logo VARCHAR(500),
    country VARCHAR(100) DEFAULT 'China',
    description TEXT,
    website VARCHAR(500),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_brands_slug ON brands(slug);
CREATE INDEX IF NOT EXISTS idx_brands_name_en ON brands(name_en);
CREATE INDEX IF NOT EXISTS idx_brands_status ON brands(status);

CREATE TABLE IF NOT EXISTS vehicles (
    id SERIAL PRIMARY KEY,
    brand_id INT NOT NULL REFERENCES brands(id) ON DELETE RESTRICT,
    name_cn VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    vehicle_type VARCHAR(50),
    price_range VARCHAR(100),
    launch_date DATE,
    battery_supplier VARCHAR(100),
    segment VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    cover_image VARCHAR(500),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_vehicles_brand_id ON vehicles(brand_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_slug ON vehicles(slug);

CREATE TABLE IF NOT EXISTS sources (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) DEFAULT 'other' CHECK (type IN ('forum', 'social_media', 'news', 'official', 'other')),
    homepage VARCHAR(500),
    crawler_plugin VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'error')),
    rate_limit INT DEFAULT 1,
    crawl_interval INT DEFAULT 3600,
    last_crawl_time TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_sources_status ON sources(status);
CREATE INDEX IF NOT EXISTS idx_sources_type ON sources(type);

CREATE TABLE IF NOT EXISTS raw_contents (
    id BIGSERIAL PRIMARY KEY,
    source_id INT REFERENCES sources(id),
    vehicle_id INT REFERENCES vehicles(id),
    brand_id INT REFERENCES brands(id),
    url VARCHAR(1000) NOT NULL,
    title VARCHAR(500),
    author VARCHAR(200),
    publish_time TIMESTAMPTZ,
    content TEXT,
    raw_json JSONB,
    language VARCHAR(10) DEFAULT 'zh',
    hash VARCHAR(64) NOT NULL UNIQUE,
    crawl_time TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processed', 'failed'))
);
CREATE INDEX IF NOT EXISTS idx_raw_contents_hash ON raw_contents(hash);
CREATE INDEX IF NOT EXISTS idx_raw_contents_vehicle_id ON raw_contents(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_raw_contents_publish_time ON raw_contents(publish_time);

CREATE TABLE IF NOT EXISTS ai_tasks (
    id BIGSERIAL PRIMARY KEY,
    task_type VARCHAR(50) NOT NULL,
    target_type VARCHAR(50),
    target_id INT,
    model VARCHAR(100),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'success', 'failed')),
    token_input INT DEFAULT 0,
    token_output INT DEFAULT 0,
    duration NUMERIC(10,2),
    retry_count INT DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    finished_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_ai_tasks_status ON ai_tasks(status);
CREATE INDEX IF NOT EXISTS idx_ai_tasks_created_at ON ai_tasks(created_at);

CREATE TABLE IF NOT EXISTS insights (
    id BIGSERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES vehicles(id),
    content_id BIGINT REFERENCES raw_contents(id),
    summary TEXT,
    positive_points JSONB,
    negative_points JSONB,
    complaints JSONB,
    advantages JSONB,
    confidence_score NUMERIC(5,2),
    trend_score NUMERIC(5,2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_insights_vehicle_id ON insights(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_insights_confidence_score ON insights(confidence_score);
CREATE INDEX IF NOT EXISTS idx_insights_created_at ON insights(created_at);

CREATE TABLE IF NOT EXISTS evidence (
    id BIGSERIAL PRIMARY KEY,
    insight_id BIGINT REFERENCES insights(id),
    content_id BIGINT REFERENCES raw_contents(id),
    quote TEXT,
    source_url VARCHAR(1000),
    weight NUMERIC(5,2),
    confidence NUMERIC(5,2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_evidence_insight_id ON evidence(insight_id);
CREATE INDEX IF NOT EXISTS idx_evidence_confidence ON evidence(confidence);

CREATE TABLE IF NOT EXISTS articles (
    id SERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES vehicles(id),
    brand_id INT REFERENCES brands(id),
    title VARCHAR(500) NOT NULL,
    slug VARCHAR(500) NOT NULL UNIQUE,
    summary TEXT,
    content_md TEXT,
    content_html TEXT,
    seo_title VARCHAR(500),
    meta_description TEXT,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'ai_review', 'human_review', 'published', 'archived')),
    published_at TIMESTAMPTZ,
    author_type VARCHAR(10) DEFAULT 'ai' CHECK (author_type IN ('ai', 'human')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_articles_slug ON articles(slug);
CREATE INDEX IF NOT EXISTS idx_articles_status ON articles(status);
CREATE INDEX IF NOT EXISTS idx_articles_vehicle_id ON articles(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_articles_published_at ON articles(published_at);

CREATE TABLE IF NOT EXISTS article_versions (
    id SERIAL PRIMARY KEY,
    article_id INT NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    version INT NOT NULL,
    content_md TEXT,
    editor VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(article_id, version)
);
CREATE INDEX IF NOT EXISTS idx_article_versions_article_id ON article_versions(article_id);

CREATE TABLE IF NOT EXISTS review_tasks (
    id SERIAL PRIMARY KEY,
    article_id INT NOT NULL REFERENCES articles(id),
    reviewer VARCHAR(100),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'revision')),
    comments TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    finished_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_review_tasks_status ON review_tasks(status);

CREATE TABLE IF NOT EXISTS publish_logs (
    id SERIAL PRIMARY KEY,
    article_id INT NOT NULL REFERENCES articles(id),
    channel VARCHAR(50) DEFAULT 'website',
    status VARCHAR(10) DEFAULT 'success' CHECK (status IN ('success', 'failed')),
    publish_time TIMESTAMPTZ DEFAULT NOW(),
    error_message TEXT
);
CREATE INDEX IF NOT EXISTS idx_publish_logs_article_id ON publish_logs(article_id);
CREATE INDEX IF NOT EXISTS idx_publish_logs_publish_time ON publish_logs(publish_time);

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(200) NOT NULL UNIQUE,
    password_hash VARCHAR(200) NOT NULL,
    role_id INT DEFAULT 2,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS permissions (
    id SERIAL PRIMARY KEY,
    role_id INT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS system_configs (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS system_logs (
    id BIGSERIAL PRIMARY KEY,
    module VARCHAR(50) NOT NULL,
    operator VARCHAR(100),
    action VARCHAR(200),
    status VARCHAR(20) DEFAULT 'success' CHECK (status IN ('success', 'warning', 'error')),
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_system_logs_module ON system_logs(module);
CREATE INDEX IF NOT EXISTS idx_system_logs_created_at ON system_logs(created_at);

-- Default roles
INSERT INTO roles (id, role_name, description) VALUES
(1, 'admin', 'System Administrator'),
(2, 'editor', 'Editor'),
(3, 'viewer', 'Read-only User')
ON CONFLICT (id) DO NOTHING;

-- Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_brands_updated_at') THEN
        CREATE TRIGGER update_brands_updated_at BEFORE UPDATE ON brands FOR EACH ROW EXECUTE FUNCTION update_updated_at();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_vehicles_updated_at') THEN
        CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON vehicles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_articles_updated_at') THEN
        CREATE TRIGGER update_articles_updated_at BEFORE UPDATE ON articles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
    END IF;
END $$;