# MySerial

Track every episode, rate as you go, never get spoiled.

**Stack:** Flutter (iOS + Android) · Spring Boot 3 / Java 21 · PostgreSQL · TMDB API

---

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| Java | 21 | [Adoptium](https://adoptium.net/) |
| Maven | 3.9+ | [maven.apache.org](https://maven.apache.org/) |
| Flutter | 3.19+ / Dart 3+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Docker Desktop | latest | [docker.com](https://www.docker.com/products/docker-desktop/) |
| TMDB account | — | [themoviedb.org/settings/api](https://www.themoviedb.org/settings/api) |

---

## Local Setup

### 1. Clone and configure environment

```bash
git clone https://github.com/CalebFianu/myserial.git
cd myserial

# Copy and fill in the env file
cp .env.example .env
# Edit .env — set TMDB_API_KEY and JWT_SECRET at minimum
```

Get your TMDB **API Read Access Token** (the long Bearer token, not the short API key) from
[https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api).

Generate a JWT secret:
```bash
openssl rand -base64 64
```

### 2. Start infrastructure

```bash
docker compose up -d
# Postgres will be available at localhost:5432
# Redis at localhost:6379
```

Wait for the health checks to pass:
```bash
docker compose ps   # both should show "healthy"
```

### 3. Run the backend

```bash
cd backend

# Source the env file (bash/zsh)
export $(grep -v '^#' ../.env | xargs)

mvn spring-boot:run -pl myserial-api
```

The API will be available at **http://localhost:8080**.

- Swagger UI: [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
- OpenAPI JSON: [http://localhost:8080/api-docs](http://localhost:8080/api-docs)

Flyway runs automatically on startup and applies all migrations from
`myserial-api/src/main/resources/db/migration/`.

### 4. Run the Flutter app

```bash
cd frontend

flutter pub get
flutter run
```

For Android emulator the API base URL defaults to `http://10.0.2.2:8080/api/v1` (host machine's
localhost). For iOS simulator use `http://localhost:8080/api/v1`.

To target a specific device:
```bash
flutter devices          # list connected devices
flutter run -d <device>  # run on specific device
```

---

## Project Structure

```
myserial/
├── backend/
│   ├── pom.xml                  # Maven parent POM
│   ├── myserial-api/            # Main Spring Boot app (controllers, security, DTOs)
│   ├── myserial-domain/         # JPA entities, repositories, services
│   ├── myserial-catalog/        # CatalogProvider + TMDB integration
│   └── myserial-batch/          # Scheduled sync + binge-alert jobs
├── frontend/
│   ├── lib/
│   │   ├── design/              # Design token layer (colors, type, spacing, motion)
│   │   ├── shared/widgets/      # Reusable UI components
│   │   ├── core/                # API client, Drift DB, providers
│   │   ├── routing/             # go_router config
│   │   └── features/            # Feature-first folder (home, show, search, …)
│   └── pubspec.yaml
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## Backend Modules

| Module | Role |
|---|---|
| `myserial-domain` | JPA entities, Spring Data repositories, domain services |
| `myserial-catalog` | `CatalogProvider` interface + TMDB implementation; Caffeine cache |
| `myserial-batch` | Daily delta-sync job (TMDB), binge-alert emission job |
| `myserial-api` | REST controllers (`/api/v1/*`), Spring Security JWT, OpenAPI docs |

### API endpoints overview

| Group | Prefix |
|---|---|
| Auth | `POST /api/v1/auth/{register,login,refresh,logout}` |
| Catalog | `GET /api/v1/shows/{search,{id},{id}/seasons/{n},{id}/cast}` |
| Watch progress | `POST/DELETE /api/v1/watch/{episodeId}`, `POST /api/v1/watch/season` |
| Diary / Up next | `GET /api/v1/watch/{diary,up-next}` |
| Ratings | `PUT/DELETE /api/v1/ratings/{episodeId}` |
| Lists | `GET/POST /api/v1/lists`, `POST/DELETE /api/v1/lists/{id}/items` |
| Binge tracking | `GET/POST/DELETE /api/v1/binge/{showId}` |
| Alerts | `GET /api/v1/alerts`, `POST /api/v1/alerts/{id}/read` |
| Friends | `GET/POST /api/v1/friends`, `GET /api/v1/friends/reviews` |
| Activity | `GET /api/v1/activity` |
| Stats | `GET /api/v1/stats` |
| People | `GET /api/v1/people/{id}` |

---

## Running Tests

```bash
cd backend
mvn test                        # all tests (Testcontainers spins up Postgres)
mvn test -pl myserial-domain    # domain tests only
```

Testcontainers pulls a Postgres Docker image automatically — Docker must be running.

---

## Data Sources & Attribution

- Show metadata, images, cast/crew: **TMDB** — *This product uses the TMDB API but is not endorsed or certified by TMDB.*
- Streaming provider availability: **TMDB watch providers** (data from JustWatch) — *JustWatch attribution displayed in the app.*
- Delta-sync signal: **TVmaze** `/updates/shows` endpoint

---

## Environment Variables Reference

| Variable | Description | Required |
|---|---|---|
| `DATABASE_URL` | JDBC connection URL | Yes |
| `DATABASE_USER` | Postgres username | Yes |
| `DATABASE_PASSWORD` | Postgres password | Yes |
| `JWT_SECRET` | HS256 signing secret (min 64 chars) | Yes |
| `TMDB_API_KEY` | TMDB API Read Access Token (Bearer) | Yes |
| `PORT` | HTTP server port (default 8080) | No |
