-- ════════════════════════════════════════════════════════════════
--  LIFE OS — Complete Supabase Setup
--  Run this entire file once in Supabase SQL Editor.
--  Safe to re-run: everything uses DROP IF EXISTS + CREATE OR REPLACE.
-- ════════════════════════════════════════════════════════════════


-- ── 1. PROFILES TABLE ──────────────────────────────────────────
DROP TABLE IF EXISTS profiles CASCADE;

CREATE TABLE profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email         TEXT,
  full_name     TEXT,
  avatar_url    TEXT,
  gemini_api_key TEXT,
  theme         TEXT DEFAULT 'dark',
  onboarded     BOOLEAN DEFAULT FALSE,
  targets       JSONB DEFAULT '{
    "calories": 2200,
    "water_glasses": 8,
    "sleep_hours": 8,
    "steps": 10000,
    "medications": []
  }'::jsonb,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);


-- ── 2. METRICS TABLE ───────────────────────────────────────────
DROP TABLE IF EXISTS metrics CASCADE;

CREATE TABLE metrics (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category     TEXT NOT NULL,    -- nutrition, hydration, movement, body, mind, health, media, productivity, custom
  subcategory  TEXT,             -- meal, run, walk, sleep, mood, water, screen, medication, floss, ...
  metric       TEXT NOT NULL,    -- calories, protein, carbs, fat, distance_km, duration_hrs, score, glasses, taken, done, ...
  value        NUMERIC NOT NULL,
  unit         TEXT,             -- kcal, g, km, hrs, min, sec, score, count, glasses, steps
  source       TEXT DEFAULT 'ai_chat', -- ai_chat, image_upload, manual, auto_timer, strava, apple_health
  session_id   UUID,             -- groups related metrics logged at once (e.g. full meal: calories + protein + carbs + fat)
  tags         JSONB DEFAULT '{}',   -- flexible: meal_type, food_item, label, notes, pace, etc.
  logged_at    TIMESTAMPTZ DEFAULT NOW(),
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_metrics_user_id       ON metrics(user_id);
CREATE INDEX idx_metrics_user_logged   ON metrics(user_id, logged_at DESC);
CREATE INDEX idx_metrics_user_category ON metrics(user_id, category, logged_at DESC);
CREATE INDEX idx_metrics_user_metric   ON metrics(user_id, metric, logged_at DESC);


-- ── 3. TAG TAXONOMY TABLE ──────────────────────────────────────
DROP TABLE IF EXISTS tag_taxonomy CASCADE;

CREATE TABLE tag_taxonomy (
  id           SERIAL PRIMARY KEY,
  category     TEXT NOT NULL,
  subcategory  TEXT,
  metric       TEXT NOT NULL,
  unit         TEXT,
  display_name TEXT,
  description  TEXT
);


-- ── 4. SEED TAXONOMY DATA ──────────────────────────────────────
INSERT INTO tag_taxonomy (category, subcategory, metric, unit, display_name, description) VALUES
-- Nutrition
('nutrition', 'meal',      'calories',     'kcal',  'Calories',       'Total caloric intake'),
('nutrition', 'meal',      'protein',      'g',     'Protein',        'Protein in grams'),
('nutrition', 'meal',      'carbs',        'g',     'Carbohydrates',  'Carbs in grams'),
('nutrition', 'meal',      'fat',          'g',     'Fat',            'Fat in grams'),
('nutrition', 'meal',      'fiber',        'g',     'Fiber',          'Dietary fiber'),
('nutrition', 'meal',      'sugar',        'g',     'Sugar',          'Total sugar'),
-- Hydration
('hydration', 'water',     'glasses',      'count', 'Water Glasses',  'Number of glasses'),
('hydration', 'water',     'ml',           'ml',    'Water ml',       'Volume in ml'),
('hydration', 'coffee',    'cups',         'count', 'Coffee',         'Cups of coffee'),
-- Movement
('movement',  'run',       'distance_km',  'km',    'Distance',       'Distance run in km'),
('movement',  'run',       'duration_min', 'min',   'Duration',       'Duration in minutes'),
('movement',  'run',       'pace_min_km',  'min/km','Pace',           'Minutes per km'),
('movement',  'run',       'calories_burned','kcal','Calories Burned','Energy burned'),
('movement',  'walk',      'distance_km',  'km',    'Walk Distance',  'Distance walked'),
('movement',  'walk',      'steps',        'count', 'Steps',          'Step count'),
('movement',  'workout',   'duration_min', 'min',   'Workout Time',   'Time spent working out'),
('movement',  'workout',   'calories_burned','kcal','Calories Burned','Energy burned'),
('movement',  'cycling',   'distance_km',  'km',    'Cycle Distance', 'Distance cycled'),
-- Body / Sleep
('body',      'sleep',     'duration_hrs', 'hrs',   'Sleep Duration', 'Hours slept'),
('body',      'sleep',     'quality_score','score', 'Sleep Quality',  '1-5 quality rating'),
('body',      'vitals',    'weight_kg',    'kg',    'Weight',         'Body weight'),
('body',      'vitals',    'bmi',          'score', 'BMI',            'Body mass index'),
-- Mind
('mind',      'mood',      'score',        'score', 'Mood Score',     '1-10 mood rating'),
('mind',      'focus',     'duration_min', 'min',   'Focus Time',     'Focused work in minutes'),
('mind',      'meditation','duration_min', 'min',   'Meditation',     'Meditation in minutes'),
('mind',      'gratitude', 'count',        'count', 'Gratitude',      'Gratitude journal entries'),
-- Health
('health',    'medication','taken',        'count', 'Medication',     'Medication taken'),
('health',    'floss',     'done',         'count', 'Flossing',       'Flossing done'),
('health',    'supplement','taken',        'count', 'Supplement',     'Supplement taken'),
-- Media
('media',     'screen',    'duration_min', 'min',   'Screen Time',    'Total screen time'),
('media',     'reading',   'duration_min', 'min',   'Reading',        'Reading time'),
('media',     'podcast',   'duration_min', 'min',   'Podcast',        'Podcast listening'),
('media',     'tv',        'duration_min', 'min',   'TV / Streaming', 'TV watching time'),
-- Productivity
('productivity','work',    'duration_min', 'min',   'Work Time',      'Productive work time'),
('productivity','break',   'duration_min', 'min',   'Break Time',     'Rest breaks taken');


-- ── 5. ENABLE ROW LEVEL SECURITY ───────────────────────────────
ALTER TABLE profiles    ENABLE ROW LEVEL SECURITY;
ALTER TABLE metrics     ENABLE ROW LEVEL SECURITY;
ALTER TABLE tag_taxonomy ENABLE ROW LEVEL SECURITY;


-- ── 6. RLS POLICIES — PROFILES ─────────────────────────────────
DROP POLICY IF EXISTS "profiles_select" ON profiles;
DROP POLICY IF EXISTS "profiles_insert" ON profiles;
DROP POLICY IF EXISTS "profiles_update" ON profiles;
DROP POLICY IF EXISTS "profiles_delete" ON profiles;
DROP POLICY IF EXISTS "profiles_own"    ON profiles;

CREATE POLICY "profiles_select" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_insert" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update" ON profiles
  FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_delete" ON profiles
  FOR DELETE USING (auth.uid() = id);


-- ── 7. RLS POLICIES — METRICS ──────────────────────────────────
DROP POLICY IF EXISTS "metrics_select" ON metrics;
DROP POLICY IF EXISTS "metrics_insert" ON metrics;
DROP POLICY IF EXISTS "metrics_update" ON metrics;
DROP POLICY IF EXISTS "metrics_delete" ON metrics;
DROP POLICY IF EXISTS "metrics_own"    ON metrics;

CREATE POLICY "metrics_select" ON metrics
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "metrics_insert" ON metrics
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "metrics_update" ON metrics
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "metrics_delete" ON metrics
  FOR DELETE USING (auth.uid() = user_id);


-- ── 8. RLS POLICIES — TAG TAXONOMY (public read) ───────────────
DROP POLICY IF EXISTS "taxonomy_read" ON tag_taxonomy;

CREATE POLICY "taxonomy_read" ON tag_taxonomy
  FOR SELECT USING (true);


-- ── 9. AUTO-UPDATE updated_at ON PROFILES ──────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS profiles_updated_at ON profiles;
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ── 10. AUTO-CREATE PROFILE ON SIGNUP ──────────────────────────
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Never block signup even if profile insert fails
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();


-- ── 11. ENABLE REALTIME ────────────────────────────────────────
-- Run this to allow the app's realtime sync to work
ALTER PUBLICATION supabase_realtime ADD TABLE metrics;


-- ── 12. MANUAL PROFILE FIX ─────────────────────────────────────
-- If your profile row doesn't exist (run this if you see "no rows returned"):
INSERT INTO profiles (id, email, full_name, avatar_url, onboarded, theme, targets)
SELECT
  id,
  email,
  COALESCE(raw_user_meta_data->>'full_name', split_part(email, '@', 1)),
  raw_user_meta_data->>'avatar_url',
  false,
  'dark',
  '{"calories":2200,"water_glasses":8,"sleep_hours":8,"steps":10000,"medications":[]}'::jsonb
FROM auth.users
WHERE id NOT IN (SELECT id FROM profiles);


-- ════════════════════════════════════════════════════════════════
--  DONE. Verify with:
--    SELECT id, email, onboarded, gemini_api_key IS NOT NULL as has_key FROM profiles;
--    SELECT count(*) FROM metrics;
-- ════════════════════════════════════════════════════════════════
