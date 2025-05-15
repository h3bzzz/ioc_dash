-- +goose Up
CREATE TYPE ioc_type AS ENUM ('ip', 'domain', 'url', 'hash', 'email', 'file', 'mutex', 'registry', 'useragent');
CREATE TYPE ioc_status AS ENUM('active', 'expired', 'false_positive', 'retired');
CREATE TYPE src_type AS ENUM('feed', 'api', 'community', 'commercial', 'internal');

CREATE TABLE IF NOT EXISTS sources (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  url VARCHAR(255),
  src_type src_type NOT NULL,
  collection_method VARCHAR(20) NOT NULL DEFAULT 'api',
  api_key VARCHAR(255),
  api_config JSONB,
  rate_limit INTEGER DEFAULT 0,
  enabled BOOLEAN DEFAULT TRUE,
  confidence_level INTEGER DEFAULT 50,
  last_fetched_at TIMESTAMP WITH TIME ZONE,
  collection_frequency INTERVAL DEFAULT '1 HOUR'::INTERVAL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS iocs (
  id SERIAL PRIMARY KEY,
  value VARCHAR(255) NOT NULL,
  type ioc_type NOT NULL,
  first_seen_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  expiration_date TIMESTAMP WITH TIME ZONE,
  confidence_score INTEGER CHECK (confidence_score BETWEEN 0 AND 100),
  malware_family VARCHAR(100),
  campaign VARCHAR(100),
  status ioc_status DEFAULT 'active',
  is_malicious BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(value, type)
);

CREATE TABLE IF NOT EXISTS ioc_metadata (
  id SERIAL PRIMARY KEY,
  ioc_id INTEGER NOT NULL REFERENCES iocs(id) ON DELETE CASCADE,
  key VARCHAR(100) NOT NULL,
  value TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(ioc_id, key)
);

CREATE TABLE IF NOT EXISTS ioc_tags (
  id SERIAL PRIMARY KEY,
  ioc_id INTEGER NOT NULL REFERENCES iocs(id) ON DELETE CASCADE,
  tag VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(ioc_id, tag)
);

CREATE TABLE IF NOT EXISTS src_iocs (
  id SERIAL PRIMARY KEY,
  src_id INTEGER NOT NULL REFERENCES sources(id) ON DELETE CASCADE,
  ioc_id INTEGER NOT NULL REFERENCES iocs(id) ON DELETE CASCADE,
  external_id VARCHAR(255),
  first_seen_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  confidence_score INTEGER,
  raw_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(src_id, ioc_id)
);

CREATE TABLE IF NOT EXISTS ioc_enrichments (
  id SERIAL PRIMARY KEY,
  ioc_id INTEGER NOT NULL REFERENCES iocs(id) ON DELETE CASCADE,
  enrichment_type VARCHAR(50) NOT NULL,
  data JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(ioc_id, enrichment_type)
);

CREATE TABLE IF NOT EXISTS ioc_relations (
  id SERIAL PRIMARY KEY,
  src_ioc_id INTEGER NOT NULL REFERENCES iocs(id) ON DELETE CASCADE,
  target_ioc_id INTEGER NOT NULL REFERENCES iocs(id) ON DELETE CASCADE,
  relationship_type VARCHAR(50) NOT NULL,
  src_id INTEGER REFERENCES sources(id),
  confidence_score INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(src_ioc_id, target_ioc_id, relationship_type)
);

-- Indexes
CREATE INDEX idx_iocs_value ON iocs(value);
CREATE INDEX idx_iocs_type ON iocs(type);
CREATE INDEX idx_iocs_status ON iocs(status);
CREATE INDEX idx_iocs_first_seen ON iocs(first_seen_at);
CREATE INDEX idx_iocs_confidence ON iocs(confidence_score);
CREATE INDEX idx_src_iocs_src_id ON src_iocs(src_id);
CREATE INDEX idx_src_iocs_ioc_id ON src_iocs(ioc_id);
CREATE INDEX idx_ioc_relations_src ON ioc_relations(src_ioc_id);
CREATE INDEX idx_ioc_relations_target ON ioc_relations(target_ioc_id);
CREATE INDEX idx_ioc_tags_ioc_id ON ioc_tags(ioc_id);
CREATE INDEX idx_ioc_tags_tag ON ioc_tags(tag);
CREATE INDEX idx_ioc_metadata_ioc_id ON ioc_metadata(ioc_id);
CREATE INDEX idx_sources_enabled ON sources(enabled);

-- +goose Down
DROP TABLE IF EXISTS ioc_relations;
DROP TABLE IF EXISTS ioc_enrichments;
DROP TABLE IF EXISTS src_iocs;
DROP TABLE IF EXISTS ioc_tags;
DROP TABLE IF EXISTS ioc_metadata;
DROP TABLE IF EXISTS iocs;
DROP TABLE IF EXISTS sources;

DROP TYPE IF EXISTS ioc_type;
DROP TYPE IF EXISTS ioc_status;
DROP TYPE IF EXISTS src_type;
