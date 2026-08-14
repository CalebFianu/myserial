
Build **MySerial**, a cross-platform TV-tracking app: a Flutter client (iOS + Android, phone-first) with a Spring Boot backend built with Maven. I have an HTML prototype of the full UI and a design system; treat the spec below as the source of truth for product behaviour and visual design.

## 0. Before you write code — research and propose

Do this first and report back with a short recommendation before implementing:

1. **Show metadata API.** Compare the realistic options for episode-level TV data — TMDB, TVmaze, Trakt, TheTVDB, and Watchmode/JustWatch for streaming availability. For each: auth model, rate limits, licensing/attribution terms for a commercial app, whether it exposes per-episode records, air dates, season structure, cast + crew with character names, images, and "still airing vs ended vs cancelled" status, and whether it has streaming-provider availability by region. Recommend one primary source plus a fallback/enrichment source, and say what each is used for.
2. **Storage and retrieval strategy.** Propose the shape of it: what we mirror into our own Postgres (shows, seasons, episodes, people, credits) versus what we proxy live; how we key our rows against the provider's ids; how we refresh (on-demand lazy hydration on first request for a show, plus a scheduled delta sync for airing shows); a cache layer (Redis or Caffeine) for search and hot show payloads with sensible TTLs; how full-text search works (Postgres `pg_trgm`/tsvector versus the provider's own search endpoint); and how we keep the client fast offline (local SQLite/Drift mirror of the user's own tracked data, with the catalog cached per-show). Include the migration approach (Flyway) and the indexes that matter.
3. Confirm the module layout you intend to use before generating files and suggest whether or not backend and frontend should be in one repository or not.
4. create and push a .gitignore file that includes all claude files and files specific to flutter and spring that shouldnt be pushed to the repository

## 1. Architecture

- **Backend:** Java 21, Spring Boot 3, **Maven** (multi-module: `myserial-api`, `myserial-domain`, `myserial-catalog` for provider integration, optional `myserial-batch` for sync jobs). Spring Web, Spring Data JPA, Spring Security (JWT), Validation, Flyway, Postgres, Testcontainers for integration tests. REST with a versioned `/api/v1` prefix. OpenAPI via springdoc.
- **Client:** Flutter, Dart 3, one codebase for iOS/Android. Riverpod for state, `go_router` for navigation, `dio` + generated models for the API, Drift (SQLite) for the offline mirror, `cached_network_image` for poster art. Feature-first folder structure (`lib/features/home`, `/show`, `/search`, `/activity`, `/profile`, `lib/design/` for the token layer).
- Auth: email + password to start (register / login / refresh), tokens stored in secure storage. Design the user model so social sign-in can be added later.
- Every user-owned entity (progress, ratings, lists, alerts, activity) is scoped to the authenticated user and is ours, not the provider's.
- Use env files where necessary for storing env variables

## 2. Design system — implement this as a Dart token layer, not ad-hoc styling

Create `lib/design/` with `colors.dart`, `typography.dart`, `spacing.dart`, `radii.dart`, `motion.dart` and a `MySerialTheme` exposing light and dark `ThemeData`. No hard-coded colors or font sizes anywhere in feature code.

**Colour.** Dark-first. App background near-black slate `#0C1014`. Dark surfaces step up rather than using shadows: `ink-0 #0C1014` → `ink-1 #12181D` → `ink-2 #182027` → `ink-3 #1F2933` (card / raised / pressed map onto these). Light theme is a warm off-white `#F4F3F0` with soft diffuse card shadows instead of surface steps. Hairline borders at ~9% white in dark, ~10% black in light — and cards support a **borderless mode** (a single flag that drops all card hairlines app-wide for a more minimal look).
Accents: brand coral **`#FF5C38`** for primary actions and identity; amber for star ratings; mint for watched/progress; blue for links. Poster artwork supplies the colour — chrome stays neutral. Never mix light and dark within one screen.
Also support a "pitch black" variant of the dark theme (pure `#000` background and darker surfaces) as a togglable option.

**Type.** Archivo for display, titles and big numerals (tracking −0.02em); Figtree for UI copy; JetBrains Mono for episode codes (`S02E04`). Scale: hero ~30px/700, title ~22px/700, heading ~15–16px/600, body 14px, caption 13px, micro 11px (uppercase overlines get +0.08em tracking). Minimum tap target 44px.

**Shape and depth.** Posters 10px radius, controls 12px, cards 16px, sheets 24px, chips/nav/search fully rounded. Bottom nav and sticky headers are frosted glass (blur + translucent fill); blur is reserved for chrome over scrolling content and nothing else.

**Motion.** Fast and physical: 240ms ease-out for entrances and fades, a spring curve for check/like pops and for the sliding nav indicator, press = scale to 0.97. No parallax, no bounce-on-scroll.

**Layout.** 20px page gutters, 12px stack gap, horizontal poster rails that bleed off the right edge, floating pill bottom nav ~16px above the home indicator, screen content bottom-padded ~120px so the nav never covers it.

**Imagery.** Poster/key art is the hero. Where art is missing, render a `PosterPlaceholder` — deep gradient card with the title set in type. Full-bleed heroes get a bottom protection gradient. Never tint or duotone artwork.

**Icons.** Lucide, 2px stroke, 24px grid. Filled variants for active nav and filled stars. No emoji in UI chrome.

**Voice.** Enthusiast-to-enthusiast, warm and efficient, second person ("Your shows", "Up next for you"). Sentence case everywhere including buttons ("Mark watched"); UPPERCASE only for overlines and micro-badges (`SEASON 2 · EPISODE 4`, `NEW`, `FINALE`). Episode codes as `S02E04`; dates as "Fri, 8 Nov"; runtimes as "52 min". Numbers are content — show ratings and counts big in Archivo. Empty states are short, encouraging, one action.

## 3. Navigation

Bottom pill nav, five slots, with a sliding indicator that animates between positions:

**Home · Search · + (Add) · Activity · Profile**

The `+` is not a tab — it opens the Add-show flow as a modal over whatever screen you're on. The Activity slot uses a pulse/activity icon.

## 4. Screens and behaviour

**Onboarding.** Welcome → signup/login sheet → a four-card tour (episode tracking, spoiler-free recaps, binge alerts, friends) → "Add your first shows" picker (search + poster grid, pick at least three) → Home.

**Home.** `MySerial.` wordmark (coral period) with a bell icon (badged) for binge alerts; tagline "Track it. Rate it. Binge it."; a three-up stat/shortcut grid; Continue watching card with progress; poster rails; **Binge-ready** section; "Popular with friends" rail.

**Binge-ready section.** Lists shows that have wrapped and are ready to watch in one go, as plain rows — title, one-line body, no badge and no per-card button. The section header has a **plus icon button at its far right** that opens the "Track a show" pop-up. When the section is empty, show an empty-state card: "Nothing left to binge" + "You've cleared the list. Want to track another show and wait for it to wrap?" + a "Track a show" button that opens the same pop-up.

**Track a show pop-up.** A bottom sheet with a search field over the catalog. Each result shows poster, title, and `years · status`. **Only shows that are still airing can be tracked** — they get a "Track" button, which adds the show to the watchlist, adds a Binge-ready card for it ("Tracking — we'll tell you the day it wraps"), logs an activity entry, and toasts. Shows that have **ended or been cancelled cannot be tracked**: instead of a button, they show a quiet note — "No longer airing — nothing left to wait for" (miniseries: "Miniseries — already complete"). No matching results shows "No shows match that. Try another title."

**Search.** Pill search field, segmented control for Shows / Cast & crew, grid-or-list result view toggle, result count.

**Show detail.** Full-bleed hero with poster and scrim, title, `years · network · status`, genre, synopsis, primary actions row. Add-to-watchlist is a button until the show is in the watchlist, then it becomes a quiet text-only label: "Already in your watchlist" — no icon, not tappable. Seasons and episodes list with per-episode watched toggles and ratings; season rating histogram built from the user's own ratings; season average. **Cast & crew** shows the first 4 cast and 3 crew with a "See all" link to a searchable Cast & crew screen. **Where to watch** lists streaming services with a "leaving soon" warning. **Rewatch tracking**: a counter that increments on tap and raises a toast with an **Undo** action for 4 seconds (toast auto-sizes to its text). No "binge-ready" banner on this screen.

**Season screen.** Episode rows with code, title, air date, watched state, and star rating; mark-all-watched.

**Episode rating sheet.** Half-star rating plus optional review text.

**Story so far (recap).** Spoiler-safe chapter recaps that stop at the user's last watched episode — never summarise past it.

**Cast graph.** Character relationship graph limited to characters the user has already met, with a selectable node.

**Person detail.** Photo/placeholder, role, known-for credits, tappable through to shows.

**Up next.** The next unwatched episode per tracked show, ordered.

**Diary.** Month-grouped log of what was watched, with date blocks and ratings.

**Stats.** Episodes watched, total watch time, a ratings histogram, and top genres.

**Lists.** Watchlist plus custom lists, each with a note, poster row, and optional collaborators (shared lists).

**Activity (nav slot).** Titled "Activity" with a segmented toggle at the top: **Activity | Friends** (Activity is the default).
- *Activity*: your own recent activity feed — a show you just started watching, a show you added to Binge-ready, a show you added to a list, an episode logged as watched. Each row is one line of copy plus a relative timestamp ("Just now", "2h ago"). Entries are written server-side as the user performs those actions.
- *Friends*: the friends list (avatar, "Watching *show* · S02E07", relative time), an "Add friend" button, and a "Reviews from friends" feed of reviews with avatar, episode code, stars, review text and time, tappable through to the show.

**Profile.** Avatar, name, handle, bio, edit-profile sheet, watchlist card, custom lists, entry points to Up next / Diary / Stats, and a **sun/moon icon button in the top right that toggles light and dark mode**.

**Binge alerts.** Reached from the Home bell. A feed of alert cards ("House of the Dragon S2 wrapped", "Dark has ended") with badge, body and time. This page has **no "Your alerts" section** — no search field and no per-alert toggle rows.

**Add show modal (the `+`).** If the user is on a show detail page, first ask "Log *[show]*?" with "Yes, log it" (pre-selects that show) and "No, something else". Then the add sheet: search and pick a show, choose a mode via segmented control — **Watching** (set current season/episode, seeds prior episodes as watched), **Watched** (marks the whole show watched, with a date and Today/Yesterday/Last week shortcuts), or **Add to list** (multi-select list rows) — then save, which toasts and writes an activity entry.

**Toasts.** Single bottom toast, auto-sized to its text, 4s, optional inline Undo action.

## 5. Backend surface

Model at minimum: `User`, `Show`, `Season`, `Episode`, `Person`, `Credit`, `WatchedEpisode`, `EpisodeRating` (score + optional review), `Watchlist`/`UserList` + `UserListItem` + `ListCollaborator`, `Rewatch`, `BingeTrack` (a tracked airing show, with its wrapped/alerted state), `Alert`, `Friendship`, `ActivityEvent`, `StreamingAvailability`.

Endpoints should cover: auth; catalog search; show/season/episode/person reads; progress writes (watch/unwatch, bulk season); ratings and reviews; lists and collaborators; binge tracking (create/remove, and a scheduled job that flips a tracked show to "wrapped" when its final episode airs and emits an alert); friends and their current-episode feed; activity feed; stats aggregation; where-to-watch. Every mutation that maps to a visible activity row also writes an `ActivityEvent`.

Include: Flyway migrations, DTOs separate from entities, `@RestControllerAdvice` error handling with a consistent error body, integration tests with Testcontainers for the repository and controller layers, and a provider-integration layer behind an interface (`CatalogProvider`) so the metadata source can be swapped, with a recorded-fixture test so we don't hit the live API in CI.

## 6. Deliverables and order

1. The research write-up from §0 with your recommendation.
2. Backend skeleton: Maven modules, Flyway schema, domain + repositories, the `CatalogProvider` integration with the chosen API, auth, then feature endpoints.
3. Flutter design token layer and shared components (`PosterPlaceholder`, poster rail, episode row, rating stars, rating histogram, progress bar/ring, chip, badge, avatar, segmented control, glass bottom nav with sliding indicator, sheet, toast with undo).
4. Screens in this order: onboarding → Home → Show detail → Season/episode → Search → Add flow → Activity → Lists → Profile → Up next / Diary / Stats → Binge alerts → Recap / Cast graph / Person.
5. README covering local setup (Postgres + Redis via docker-compose, provider API key config, `mvn spring-boot:run`, `flutter run`).

Ask me before making product decisions the spec doesn't cover. Keep commits small and grouped by feature.
