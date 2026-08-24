CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Users
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    handle VARCHAR(100) NOT NULL UNIQUE,
    bio TEXT,
    avatar_path VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Catalog
CREATE TABLE shows (
    id BIGSERIAL PRIMARY KEY,
    tmdb_id INTEGER NOT NULL UNIQUE,
    tvmaze_id INTEGER,
    title VARCHAR(500) NOT NULL,
    original_title VARCHAR(500),
    overview TEXT,
    status VARCHAR(50),
    first_air_date DATE,
    last_air_date DATE,
    poster_path VARCHAR(500),
    backdrop_path VARCHAR(500),
    genres JSONB,
    network VARCHAR(255),
    episode_run_time INTEGER,
    vote_average NUMERIC(3,1),
    vote_count INTEGER,
    popularity NUMERIC(10,3),
    last_synced_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE seasons (
    id BIGSERIAL PRIMARY KEY,
    tmdb_id INTEGER NOT NULL UNIQUE,
    show_id BIGINT NOT NULL REFERENCES shows(id) ON DELETE CASCADE,
    season_number INTEGER NOT NULL,
    name VARCHAR(255),
    overview TEXT,
    poster_path VARCHAR(500),
    air_date DATE,
    episode_count INTEGER,
    UNIQUE(show_id, season_number)
);

CREATE TABLE episodes (
    id BIGSERIAL PRIMARY KEY,
    tmdb_id INTEGER NOT NULL UNIQUE,
    show_id BIGINT NOT NULL REFERENCES shows(id) ON DELETE CASCADE,
    season_id BIGINT REFERENCES seasons(id) ON DELETE CASCADE,
    season_number INTEGER NOT NULL,
    episode_number INTEGER NOT NULL,
    name VARCHAR(500),
    overview TEXT,
    air_date DATE,
    still_path VARCHAR(500),
    runtime INTEGER,
    vote_average NUMERIC(3,1),
    UNIQUE(show_id, season_number, episode_number)
);

CREATE TABLE people (
    id BIGSERIAL PRIMARY KEY,
    tmdb_id INTEGER NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    profile_path VARCHAR(500),
    known_for_department VARCHAR(100),
    biography TEXT
);

CREATE TABLE credits (
    id BIGSERIAL PRIMARY KEY,
    person_id BIGINT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    show_id BIGINT NOT NULL REFERENCES shows(id) ON DELETE CASCADE,
    character_name VARCHAR(500),
    credit_type VARCHAR(20) NOT NULL,
    department VARCHAR(100),
    job VARCHAR(100),
    display_order INTEGER
);

CREATE TABLE streaming_availability (
    id BIGSERIAL PRIMARY KEY,
    show_id BIGINT NOT NULL REFERENCES shows(id) ON DELETE CASCADE,
    provider_id INTEGER NOT NULL,
    provider_name VARCHAR(255) NOT NULL,
    provider_logo_path VARCHAR(500),
    country_code VARCHAR(10) NOT NULL,
    offer_type VARCHAR(50),
    link VARCHAR(1000),
    last_synced_at TIMESTAMPTZ,
    UNIQUE(show_id, provider_id, country_code, offer_type)
);

-- User-owned data
CREATE TABLE watched_episodes (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    episode_id BIGINT NOT NULL REFERENCES episodes(id) ON DELETE CASCADE,
    watched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, episode_id)
);

CREATE TABLE episode_ratings (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    episode_id BIGINT NOT NULL REFERENCES episodes(id) ON DELETE CASCADE,
    score NUMERIC(3,1) NOT NULL CHECK (score >= 0.5 AND score <= 5.0),
    review TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, episode_id)
);

CREATE TABLE rewatches (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    show_id BIGINT NOT NULL REFERENCES shows(id) ON DELETE CASCADE,
    count INTEGER NOT NULL DEFAULT 1,
    last_rewatched_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, show_id)
);

CREATE TABLE user_lists (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    note TEXT,
    is_watchlist BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_list_items (
    id BIGSERIAL PRIMARY KEY,
    list_id BIGINT NOT NULL REFERENCES user_lists(id) ON DELETE CASCADE,
    show_id BIGINT NOT NULL REFERENCES shows(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(list_id, show_id)
);

CREATE TABLE list_collaborators (
    id BIGSERIAL PRIMARY KEY,
    list_id BIGINT NOT NULL REFERENCES user_lists(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(list_id, user_id)
);

CREATE TABLE binge_tracks (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    show_id BIGINT NOT NULL REFERENCES shows(id) ON DELETE CASCADE,
    wrapped BOOLEAN NOT NULL DEFAULT FALSE,
    alerted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    wrapped_at TIMESTAMPTZ,
    UNIQUE(user_id, show_id)
);

CREATE TABLE alerts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    show_id BIGINT REFERENCES shows(id) ON DELETE SET NULL,
    title VARCHAR(500) NOT NULL,
    body TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    read_at TIMESTAMPTZ
);

CREATE TABLE friendships (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    friend_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, friend_id),
    CHECK (user_id != friend_id)
);

CREATE TABLE activity_events (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL,
    show_id BIGINT REFERENCES shows(id) ON DELETE SET NULL,
    episode_id BIGINT REFERENCES episodes(id) ON DELETE SET NULL,
    list_id BIGINT REFERENCES user_lists(id) ON DELETE SET NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
