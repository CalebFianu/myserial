ALTER TABLE users ADD COLUMN onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE;

-- Existing users have already been using the app, mark them as onboarded
UPDATE users SET onboarding_completed = TRUE;
