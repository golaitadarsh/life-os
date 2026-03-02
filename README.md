[README-1.md](https://github.com/user-attachments/files/25676613/README-1.md)[Uploading README-1# 🧠 Life OS — Personal AI Life Tracker

> A voice-first, browser-based personal AI assistant that tracks everything about your day — food, calories, water flossing, media consumption, and medications — all through natural language. No forms. No manual entry. Just talk.

![Life OS](https://img.shields.io/badge/Status-Active-brightgreen) ![License](https://img.shields.io/badge/License-MIT-blue) ![Cost](https://img.shields.io/badge/Hosting_Cost-Free-success) ![AI](https://img.shields.io/badge/Powered_by-Claude_AI-orange)

---

## 📸 What It Looks Like

A clean, warm-toned dashboard with:
- A **floating widget** in the bottom-right corner — click it to activate voice input
- A **live dashboard** showing today's stats, timeline, habit tracker, and AI insights
- A **chat interface** where you talk to the AI naturally
- A **weekly report** generated on demand with AI analysis

---

## ✨ Features

### 🎙️ Voice-First, Natural Language Input
Just say things like:
- `"I had two eggs and toast for breakfast"` → logs meal + auto-calculates calories
- `"Start water flossing"` → starts a timer
- `"Stop"` → logs the flossing duration
- `"I'm watching Taarak Mehta on YouTube"` → starts media tracking
- `"Took my Vitamin D"` → confirms medication

No specific format required. The AI understands casual, conversational language.

### 🔒 Security-First Listening
The floating widget shows a **green pulsing dot** when actively listening. It **only listens when you activate it** — never passively in the background. This is intentional by design, so you can safely use your laptop in meetings, calls, or shared spaces.

### 📊 Live Dashboard
- **Today's activity timeline** — everything logged with timestamps
- **Calorie breakdown** by meal type with visual bars
- **Streak tracker** — consecutive days of habits
- **Medication status** — what's taken, what's pending
- **AI-generated day score** with live insight

### 🤖 How the AI Thinks
Every message you send goes to Claude (Anthropic's AI) with:
1. Your full context (name, calorie target, medications configured)
2. Today's logs so far
3. Any active timers
4. The current time

Claude then:
1. **Understands your intent** (is this food? a timer? a medication?)
2. **Extracts structured data** (food name, estimated calories, macros)
3. **Returns a JSON action block** embedded in its reply
4. The app parses this action and updates the dashboard in real time

This means you don't need to use any specific keywords or commands. The AI handles ambiguity — if you say "I had pasta", it'll ask what kind and how much.

### ⏱️ Smart Timers
- Start/stop timers via voice or button
- Active timer shows as a bar at the top of the dashboard
- Timer type (floss vs media) is detected automatically from context
- Duration is logged precisely when you say stop

### 📋 Habit Tracking
- 7-day grid showing done/missed/today for each habit
- Streak counter per habit
- Habits tracked: water flossing, meal logging, medications

### 💊 Medication Tracker
- Configure meds in Settings (name, dose, schedule)
- Confirm via voice or button
- Dashboard shows taken vs pending status

### 📈 Weekly Report
- AI-generated narrative report
- Covers: avg calories, flossing adherence, media consumption, medication adherence
- Highlights: what you improved, what needs work, 3 specific actionable recommendations

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│                  Browser (You)                   │
│                                                  │
│  ┌──────────┐    ┌──────────┐    ┌───────────┐  │
│  │  Voice   │    │  Chat    │    │ Dashboard │  │
│  │  Input   │    │Interface │    │  (Live)   │  │
│  └────┬─────┘    └────┬─────┘    └─────▲─────┘  │
│       │               │                │         │
│       └───────┬────────┘                │         │
│               │                        │         │
│         User Message                   │         │
│               │                        │         │
│               ▼                        │         │
│  ┌────────────────────────┐            │         │
│  │   System Prompt Builder│            │         │
│  │  - Your name & config  │            │         │
│  │  - Today's logs        │            │         │
│  │  - Active timers       │            │         │
│  │  - Medication schedule │            │         │
│  └────────────┬───────────┘            │         │
│               │                        │         │
└───────────────┼────────────────────────┼─────────┘
                │                        │
                ▼                        │
    ┌───────────────────────┐            │
    │    Anthropic API      │            │
    │  claude-sonnet-4-6    │            │
    │                       │            │
    │  Input: Your message  │            │
    │  + full context       │            │
    │                       │            │
    │  Output: Reply text   │            │
    │  + <action> JSON      │            │
    └───────────┬───────────┘            │
                │                        │
                ▼                        │
    ┌───────────────────────┐            │
    │   Action Processor    │────────────┘
    │                       │
    │  Parses action type:  │   Updates:
    │  food / floss_start / │ → Timeline
    │  floss_stop /         │ → Stats cards
    │  media_start /        │ → Calorie bars
    │  media_stop /         │ → Habit grid
    │  medication / note    │ → Insight box
    └───────────┬───────────┘
                │
                ▼
    ┌───────────────────────┐
    │    localStorage       │
    │  (Browser Storage)    │
    │                       │
    │  - config (settings)  │
    │  - logs[] (all data)  │
    └───────────────────────┘
```

### Why Single HTML File?
The entire app is one `index.html` file with inline CSS and JS. This was a deliberate choice:
- **Zero build step** — no npm, no webpack, no bundler
- **Instant deployment** — drag and drop anywhere
- **Easy to understand** — everything in one place
- **Easy to fork** — anyone can copy-paste and customize

---

## 🚀 Deployment Guide

### Option 1: GitHub + Vercel (Recommended)

**Step 1 — Create a GitHub repository**
```bash
git init life-os
cd life-os
# Copy index.html into this folder
git add .
git commit -m "Initial commit — Life OS"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/life-os.git
git push -u origin main
```

**Step 2 — Deploy to Vercel**
1. Go to [vercel.com](https://vercel.com) → Sign in with GitHub
2. Click **"Add New Project"**
3. Import your `life-os` repository
4. Vercel auto-detects it's a static site — click **Deploy**
5. Done! You get a URL like `life-os.vercel.app`

**Step 3 — Custom domain (optional)**
In Vercel dashboard → Settings → Domains → Add your domain

Every time you `git push`, Vercel auto-redeploys. ✨

---

### Option 2: GitHub Pages (Also free)

```bash
# In your repo settings → Pages → Source: Deploy from branch → main → / (root)
# Your site will be at: https://YOUR_USERNAME.github.io/life-os
```

Rename `life-os.html` to `index.html` first.

---

### Option 3: Netlify Drop (Quickest)
Go to [netlify.com/drop](https://netlify.com/drop), drag the file, done.

---

## ⚙️ Setup & Configuration

### Getting Your Claude API Key
1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Sign up / log in
3. Go to **API Keys** → **Create Key**
4. Copy the key (starts with `sk-ant-...`)
5. Paste it into Life OS on first launch

**Cost:** Anthropic gives free credits on signup. After that, Claude Sonnet costs roughly $0.003 per conversation turn. For daily life tracking (~20 messages/day), expect **under ₹50/month**.

### First Launch
When you open the app for the first time, you'll see a setup screen asking for:
- **Your name** — used for personalized greetings and AI context
- **Claude API Key** — stored only in your browser's localStorage, never sent anywhere except directly to Anthropic
- **Daily calorie target** — used for progress tracking (default: 2200)

After setup, go to **Settings** to configure medications.

### Medication Setup
In Settings → Medications, add one per line in this format:
```
Vitamin D, 2000IU, 9:00 AM
Omega-3, 1000mg, 8:00 PM
Metformin, 500mg, 8:00 AM
```

---

## 💬 Voice Commands Reference

The AI understands natural language, but here are examples to get you started:

| What you say | What happens |
|---|---|
| `"I had oats with banana for breakfast"` | Logs breakfast, estimates calories |
| `"Just ate 2 chapatis and dal for lunch"` | Logs lunch with macros |
| `"Start water flossing"` | Starts floss timer |
| `"Done flossing"` / `"Stop"` | Stops timer, logs duration |
| `"I'm watching Taarak Mehta"` | Starts media timer |
| `"Stopped watching"` | Logs media session |
| `"Took my Vitamin D"` | Confirms medication |
| `"What did I eat today?"` | AI summarizes today's food log |
| `"How are my calories looking?"` | AI gives calorie status |
| `"Generate my weekly report"` | Triggers weekly AI analysis |

---

## 🗂️ Data & Privacy

### Where Is My Data?
All your data (logs, config, settings) is stored in **your browser's localStorage**. It never leaves your device except when:
1. You send a message → the message + your today's logs are sent to Anthropic's API
2. Anthropic processes it and returns a response
3. Anthropic's [privacy policy](https://www.anthropic.com/privacy) applies to this

### Data Persistence
- Data persists across browser sessions on the same browser/device
- Clearing browser data / localStorage will erase your logs
- Opening on a different browser or device starts fresh

### Multi-Device Sync (Planned)
Currently not supported. Planned future upgrade: Supabase backend with user accounts for cross-device sync.

---

## 🛠️ Tech Stack

| Layer | Technology | Why |
|---|---|---|
| Frontend | Vanilla HTML/CSS/JS | Zero dependencies, instant load |
| AI Brain | Claude Sonnet (Anthropic API) | Best-in-class NLU, structured output |
| Voice Input | Web Speech API (browser native) | Free, no API needed |
| Storage | localStorage | Private, offline-capable |
| Fonts | Google Fonts (Clash Display + Cabinet Grotesk) | Free, beautiful |
| Hosting | Vercel / GitHub Pages | Free forever for static sites |

**Total recurring cost: ~₹0–50/month** (only the Claude API calls)

---

## 🔮 Planned Upgrades

- [ ] **Supabase backend** — sync across all your devices (iPhone, iPad, Mac, Windows)
- [ ] **PWA support** — install as an app on any device, works offline
- [ ] **Medication reminders** — browser notifications at scheduled times
- [ ] **Smart timer recovery** — if you forget to say "stop", AI predicts typical duration from history
- [ ] **Export** — download your data as CSV or PDF report
- [ ] **Custom wake word** — say "Hey Life OS" to activate without clicking
- [ ] **iPhone Shortcuts integration** — log from iPhone via Siri Shortcuts that call this app's API

---

## 🤝 Contributing / Forking

This is a personal project but feel free to fork and adapt for your own use. If you build something cool on top of this, drop a star ⭐

---

## 📄 License

MIT — do whatever you want with it.

---

*Built with ❤️ and a lot of chai ☕*
.md…]()


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
