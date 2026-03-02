[README.md](https://github.com/user-attachments/files/25676588/README.md)
# Life OS — Personal Activity Tracking Framework

A robust, extensible personal data platform. Every metric stored in a single long-table schema. Powered by Gemini AI with image understanding.

---

## Architecture

```
Browser (Single HTML)
  ↓ Natural language / Voice / Images (Strava, food photos, etc.)
Gemini 2.0 Flash (AI parsing layer)
  ↓ Structured metric rows
Supabase (PostgreSQL)
  ├── profiles          → user config, targets (jsonb)
  ├── metrics           → ALL data points (long table)
  └── tag_taxonomy      → shared standard metric definitions
  ↓ Realtime subscriptions
Dashboard (auto-updates live)
```

### Why a Long Table?

Instead of separate tables for food, sleep, exercise — everything is one row per metric:

```
category    subcategory  metric        value  unit   tags
──────────────────────────────────────────────────────────
nutrition   meal         calories      450    kcal   {meal_type:"lunch", food_item:"dal chawal"}
nutrition   meal         protein       18     g      {meal_type:"lunch"}
movement    run          distance_km   5.2    km     {source:"strava", screenshot_url:"..."}
body        sleep        duration_hrs  7.5    hrs    {quality:4}
mind        mood         score         8      score  {emoji:"😊"}
hydration   water        glasses       3      count  {}
```

Benefits:
- **Unknown habits = no problem** — just start logging anything
- **All analytics identical** — one query pattern for every metric
- **AI pattern detection** — "your mood is higher on days with 7h+ sleep"
- **New users, new habits** — schema never changes

---

## Setup (15 minutes)

### Step 1 — Supabase Project

1. Go to [supabase.com](https://supabase.com) → New Project
2. Note your **Project URL** and **Anon Key** (Settings → API)
3. Go to **SQL Editor** → paste entire `schema.sql` → Run

### Step 2 — Enable Google OAuth

1. Supabase Dashboard → Authentication → Providers → Google
2. Enable it → copy the **Callback URL** shown
3. Go to [console.cloud.google.com](https://console.cloud.google.com)
4. Create project → APIs & Services → Credentials → OAuth 2.0 Client
5. Authorized redirect URI = paste the Callback URL from Supabase
6. Copy **Client ID** and **Client Secret** back into Supabase Google provider

### Step 3 — Deploy

**GitHub + Vercel (recommended):**
```bash
# Upload index.html to GitHub repo
# Connect repo to Vercel → Deploy
```

**Or just open index.html directly in Chrome** — works locally too.

### Step 4 — Configure App

1. Open your deployed URL
2. Enter Supabase URL + Anon Key in the setup form
3. Sign in with Google
4. Complete onboarding (targets, Gemini key, theme)

### Step 5 — Gemini API Key

1. Go to [aistudio.google.com](https://aistudio.google.com)
2. Get API Key → free, no credit card
3. Paste in onboarding or Settings

---

## Data Schema

### `profiles`
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Supabase auth user ID |
| targets | jsonb | `{calories, water_glasses, sleep_hours, steps, medications}` |
| gemini_api_key | text | Stored per user, never exposed |
| theme | text | dark / light |

### `metrics` (everything)
| Column | Type | Description |
|--------|------|-------------|
| category | text | nutrition, movement, body, mind, health, hydration, media, productivity, custom |
| subcategory | text | meal, run, sleep, mood, water, screen, medication, ... |
| metric | text | calories, protein, distance_km, duration_hrs, score, glasses, ... |
| value | numeric | **The number that gets analysed** |
| unit | text | kcal, g, km, hrs, min, sec, score, count, glasses |
| source | text | ai_chat, image_upload, manual, strava, auto_timer, import |
| tags | jsonb | Human context — meal_type, food_item, label, notes, etc. |
| session_id | uuid | Groups related rows (e.g. all macros from one meal) |
| logged_at | timestamptz | When it happened |

### `tag_taxonomy` (shared)
Standard metric definitions shared across all users. Enables cross-user analytics later. 40+ pre-seeded standard metrics covering all categories.

---

## Input Methods

| Method | How |
|--------|-----|
| Natural language | "Had dal chawal for lunch" → calories + macros logged |
| Voice | Click mic widget → speak |
| Image upload | 📷 button → Strava screenshot, food photo, sleep app screenshot |
| Quick buttons | Tap water glasses, mood selector, medication confirm |
| Timer | "Start flossing" → timer starts → "done" → duration logged |

---

## Standard Sources

Every metric row has a `source` tag:
- `ai_chat` — typed or spoken to AI
- `image_upload` — extracted from uploaded image/screenshot
- `manual` — tapped button (water, mood, meds)
- `auto_timer` — duration tracked by built-in timer
- `strava` — from Strava screenshot (extracted by AI)
- `apple_health`, `garmin`, `whoop` — future integrations

---

## Analytics Views (built into schema)

```sql
-- Daily totals per metric
select * from daily_summary where user_id = '...' and metric = 'calories';

-- Weekly averages
select * from weekly_summary where user_id = '...';

-- Active streaks
select * from metric_streaks where user_id = '...' and is_active = true;
```

---

## Roadmap

- [ ] Multi-device sync (works already via Supabase)
- [ ] Per-user Supabase option (privacy-first mode)
- [ ] Apple Health / Google Fit import
- [ ] Strava OAuth direct sync
- [ ] AI-detected habit suggestions ("you seem to log runs — want to track it as a habit?")
- [ ] Export CSV / PDF reports
- [ ] PWA (installable, offline)
- [ ] Medication reminders (browser notifications)

---

## Cost

| Service | Cost |
|---------|------|
| Supabase | Free (500MB, unlimited API) |
| Vercel hosting | Free |
| Gemini API | Free tier — ~1500 requests/day |
| **Total** | **₹0/month** |

---

*One long table. Infinite flexibility.*
