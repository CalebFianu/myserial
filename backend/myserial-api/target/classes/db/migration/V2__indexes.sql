-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_handle ON users(handle);

-- Shows
CREATE INDEX idx_shows_tmdb_id ON shows(tmdb_id);
CREATE INDEX idx_shows_status ON shows(status);
CREATE INDEX idx_shows_last_synced_at ON shows(last_synced_at);
CREATE INDEX idx_shows_popularity ON shows(popularity DESC);
CREATE INDEX idx_shows_title_trgm ON shows USING GIN (title gin_trgm_ops);

-- Seasons
CREATE INDEX idx_seasons_show_id ON seasons(show_id);

-- Episodes
CREATE INDEX idx_episodes_show_id ON episodes(show_id);
CREATE INDEX idx_episodes_season_id ON episodes(season_id);
CREATE INDEX idx_episodes_show_season ON episodes(show_id, season_number);
CREATE INDEX idx_episodes_air_date ON episodes(air_date);

-- Credits
CREATE INDEX idx_credits_show_id ON credits(show_id);
CREATE INDEX idx_credits_person_id ON credits(person_id);

-- Watched Episodes
CREATE INDEX idx_watched_user_id ON watched_episodes(user_id);
CREATE INDEX idx_watched_episode_id ON watched_episodes(episode_id);
CREATE INDEX idx_watched_user_watched_at ON watched_episodes(user_id, watched_at DESC);

-- Episode Ratings
CREATE INDEX idx_ratings_user_id ON episode_ratings(user_id);
CREATE INDEX idx_ratings_episode_id ON episode_ratings(episode_id);

-- Binge Tracks
CREATE INDEX idx_binge_user_id ON binge_tracks(user_id);
CREATE INDEX idx_binge_show_id ON binge_tracks(show_id);
CREATE INDEX idx_binge_wrapped_alerted ON binge_tracks(wrapped, alerted);

-- Alerts
CREATE INDEX idx_alerts_user_id ON alerts(user_id);
CREATE INDEX idx_alerts_user_created ON alerts(user_id, created_at DESC);

-- Friendships
CREATE INDEX idx_friendships_user_id ON friendships(user_id);
CREATE INDEX idx_friendships_friend_id ON friendships(friend_id);

-- Activity Events
CREATE INDEX idx_activity_user_id ON activity_events(user_id);
CREATE INDEX idx_activity_user_created ON activity_events(user_id, created_at DESC);
CREATE INDEX idx_activity_show_id ON activity_events(show_id);

-- User Lists
CREATE INDEX idx_user_lists_user_id ON user_lists(user_id);

-- User List Items
CREATE INDEX idx_list_items_list_id ON user_list_items(list_id);
CREATE INDEX idx_list_items_show_id ON user_list_items(show_id);

-- Streaming Availability
CREATE INDEX idx_streaming_show_id ON streaming_availability(show_id);
CREATE INDEX idx_streaming_country ON streaming_availability(country_code);

-- Refresh Tokens
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);
