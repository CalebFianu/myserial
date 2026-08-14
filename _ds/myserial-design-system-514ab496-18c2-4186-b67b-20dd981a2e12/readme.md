# MySerial Design System

MySerial is a cross-platform mobile app for tracking TV shows — what you're watching, what's next, what you thought of it. Think diary + watchlist + episode progress, built for people who treat television seriously.

**Source material:** a Figma file, "MySerial Design Inspo.fig" (attached to this project), containing 7 inspiration screenshots — no components, tokens, text styles, or brand assets. Every token, component, and screen here was authored from scratch, guided by that inspiration set:

- **Letterboxd** (film grid, diary, title page) → dark cinematic base, poster-first layouts, diary rows with date blocks, star ratings, rating histograms
- **MasterClass** (browse) → editorial dark hero cards, uppercase overlines, big confident type
- **Substack chat + light social app + Craft menu** → soft pill shapes, floating glass bottom nav, rounded cards, airy light mode

**No logo exists in the source.** The wordmark renders in type (`MySerial` set in Archivo Bold, tight tracking, with a coral period: `MySerial.`). Do not draw a logo mark.

## Content fundamentals

- **Voice:** enthusiast-to-enthusiast, warm but efficient. Second person ("Your shows", "Up next for you"). Never corporate ("Content library"), never breathless marketing.
- **Casing:** sentence case everywhere — buttons ("Mark watched"), titles ("Popular this week"), empty states. UPPERCASE reserved for overlines/metadata (SEASON 2 · EPISODE 4) and micro-badges (NEW, FINALE).
- **Episode grammar:** `S02E04` in mono; "3 episodes left"; dates as "Fri, 8 Nov"; runtimes as "52 min".
- **Numbers are content:** ratings (4.4), episode counts, streaks — display them big in Archivo, never bury them.
- **Emoji:** not used in UI chrome. Fine inside user-generated review text.
- **Empty states:** short, encouraging, one action ("Nothing airing tonight. Find something new →").

## Visual foundations

- **Dark-first.** `--bg-app` near-black slate `#0C1014`; light theme (`[data-theme="light"]`) is warm off-white `#F4F3F0`, used for reading-heavy surfaces. One theme per screen, never mixed.
- **Color:** brand coral `--signal #FF5C38` for primary actions and identity; amber `--star` for ratings; mint `--track` for watched/progress; blue `--info` for links. Poster artwork supplies most color — chrome stays neutral.
- **Type:** Archivo (display, titles, big numerals; -.02em tracking), Figtree (UI copy), JetBrains Mono (episode codes). Google Fonts stand-ins — see Caveats.
- **Surfaces & depth:** dark mode steps surfaces (`ink-0 → ink-1 → ink-2 → ink-3`) instead of shadows; hairline borders `--border-hairline` optional on cards. Light mode uses soft diffuse shadows (`--shadow-light-card`).
- **Corners:** posters 10px, controls 12px, cards 16px, sheets 24px, chips/nav/search full pill.
- **Imagery:** poster/still art is the hero; full-bleed heroes get a bottom protection gradient `--scrim-poster` (never a capsule). Artwork is shown untreated — no duotones or tints.
- **Glass:** floating bottom nav and sticky headers use `--nav-glass` + `--blur-glass`. Blur is reserved for chrome over scrolling content, nothing else.
- **Motion:** fast and physical. `--ease-out` for entrances/fades (240ms), `--ease-spring` for check/like pops. Press = scale to .97; hover (pointer devices) = step surface color up. No parallax, no bounce-on-scroll.
- **Layout:** 20px page gutters, 12px stack gap, horizontal poster rails that bleed off the right edge, floating pill bottom nav ~16px above home indicator. Hit targets ≥44px.

## Iconography

No icon set ships in the source. **Lucide** (via CDN, stroke 2px, 24px grid) is the substituted system — it matches the inspiration's thin outlined icons (home, search, bell, plus, zap). Filled states (active nav, filled star) use the same glyph with fill. No emoji-as-icons, no hand-rolled SVGs. Flagged as a substitution: replace if MySerial adopts a proprietary set.

Poster imagery: **no real artwork ships here** (inspiration screenshots contain copyrighted posters). Components render a `PosterPlaceholder` (deep gradient + title in type). Supply real key art in production.

## Index

- `styles.css` → imports `tokens/` (colors, typography, spacing, effects, fonts)
- `components/core/` — Button, IconButton, Chip, Badge, Avatar
- `components/forms/` — Input, SearchField, Switch, Checkbox, SegmentedControl
- `components/media/` — PosterCard, EpisodeRow, ProgressBar, ProgressRing, RatingStars, RatingHistogram
- `components/navigation/` — BottomNav, TopBar
- `components/feedback/` — Sheet, Toast
- `guidelines/` — foundation specimen cards (Design System tab)
- `ui_kits/myserial-app/` — mobile app UI kit: Home, Show detail, Search, Diary, Profile (interactive `index.html`)
- `assets/` — (empty of brand marks by design; see logo note)
- `SKILL.md` — agent skill entry point

## Intentional additions

- `PosterPlaceholder` (inside media components) — stands in for copyrighted key art; reason: source screenshots' artwork can't ship.

## Caveats

- Fonts are Google-Fonts substitutions (Archivo/Figtree/JetBrains Mono), chosen to match the grotesque + friendly-sans feel of the inspiration. Provide licensed brand fonts to replace.
- Source defined 0 component families and 0 text styles; the inventory here is authored, sized to a TV-tracking app.
