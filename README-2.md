# Life OS

Your intelligent personal activity tracker. Log anything — food, runs, sleep, mood — just by talking. AI understands it all.

**Live demo:** [life-os-orpin-eight.vercel.app](https://life-os-orpin-eight.vercel.app)

---

## What it does

- **Chat to log** — "Had dal chawal for lunch", "Ran 5k this morning", "Slept 7.5 hours" → everything saved
- **Upload screenshots** — Strava, fitness app screenshots parsed automatically
- **Voice logging** — tap the mic, speak, done
- **Dashboard** — live calories, water, sleep, mood with day score
- **Habit tracker** — 7-day streak view for all habits
- **Analytics** — 7/30/90 day trends for every metric
- **Wrapped** — AI-generated daily/weekly health reports
- **Full data persistence** — everything lives in your own Supabase. You own your data forever.

---

## Stack

| Layer | Tech |
|-------|------|
| Frontend | Single-file HTML/CSS/JS (no build step) |
| Database | Supabase (Postgres + RLS + Realtime) |
| Auth | Google OAuth via Supabase |
| AI | Google Gemini 2.0 Flash |
| Hosting | Vercel (or any static host) |

---

## Setup (15 minutes)

### Step 1 — Supabase project

1. Go to [supabase.com](https://supabase.com) → New project
2. Open **SQL Editor** → paste the entire contents of `supabase_setup.sql` → Run
3. Go to **Authentication → Providers → Google** → Enable it
4. Add your Google OAuth credentials (Client ID + Secret from Google Cloud Console)
5. In **Authentication → URL Configuration** set:
   - Site URL: `https://your-domain.vercel.app`
   - Redirect URLs: `https://your-domain.vercel.app/**`
6. In **Project Settings → API** copy your:
   - Project URL (looks like `https://xxxx.supabase.co`)
   - Anon/Public key (starts with `eyJ...`)

### Step 2 — Google OAuth credentials

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a project → Enable **Google+ API** and **People API**
3. **Credentials → Create OAuth 2.0 Client ID** → Web application
4. Add authorized redirect URI: `https://xxxx.supabase.co/auth/v1/callback`
5. Copy Client ID and Client Secret into Supabase → Auth → Google provider

### Step 3 — Deploy

**Option A: Vercel**
```bash
# Just drag and drop index.html to vercel.com/new
# Or use CLI:
npx vercel --prod
```

**Option B: GitHub Pages**
```
Settings → Pages → Source: main branch → / (root)
```

**Option C: Any static host**
Upload `index.html` anywhere. No server needed.

### Step 4 — First login

1. Open the app
2. Enter your Supabase URL and anon key (one-time setup, saved to localStorage)
3. Click **Continue with Google**
4. Complete onboarding — set targets and paste your Gemini API key

**Get a free Gemini API key:** [aistudio.google.com](https://aistudio.google.com) → Get API Key

---

## Data model

All health data uses a single **long-table** design:

```
metrics
├── user_id     → links to auth.users
├── category    → nutrition | hydration | movement | body | mind | health | media
├── subcategory → meal | run | sleep | mood | water | ...
├── metric      → calories | protein | distance_km | duration_hrs | score | glasses | ...
├── value       → numeric
├── unit        → kcal | g | km | hrs | min | score | count
├── source      → ai_chat | image_upload | manual | auto_timer
├── session_id  → groups related rows (e.g. one meal = calories + protein + carbs + fat)
├── tags        → jsonb (meal_type, food_item, label, notes, pace, ...)
└── logged_at   → timestamp
```

This lets you add any new metric type without schema changes. Your data never gets lost.

---

## Troubleshooting

**"No Gemini API key" in chat**
→ Go to Settings, paste your key, click Save Settings. Key is saved both to Supabase and localStorage.

**Stays on login after Google sign-in**
→ Check your Supabase Redirect URLs include `https://your-domain/**`
→ Check Google Cloud Console redirect URI is `https://xxxx.supabase.co/auth/v1/callback`

**Profile row missing**
→ Run the manual profile fix at the bottom of `supabase_setup.sql`

**Data not showing after re-login**
→ All data is in Supabase — it will always be there. The app reads from Supabase on every load.

**Supabase project paused**
→ Free tier projects pause after 7 days of inactivity. Go to supabase.com and click Restore.

---

## File structure

```
/
├── index.html          ← entire app (HTML + CSS + JS, no build needed)
├── supabase_setup.sql  ← run once in Supabase SQL Editor
└── README.md
```

---

## Session persistence

Your login session is stored in `localStorage` under the key `los_session`. This means:
- ✅ Closing the browser and reopening → still logged in
- ✅ Page refresh → still logged in  
- ✅ Tokens refresh silently every hour in the background
- ✅ All data is in Supabase and never lost on sign-out

Sign out explicitly if you want to switch accounts.

---

## License

MIT — use freely, modify freely.
