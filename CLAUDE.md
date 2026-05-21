# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Portfolio app for a working DJ/violinist to manage gigs, clients, income, setlists, and gear. Single-user for now; public release is the long-term goal. The backend is the active development target — the iOS client is not yet scaffolded.

## Tech Stack

| Layer    | Choice                                                                              |
| -------- | ----------------------------------------------------------------------------------- |
| Backend  | Java / Spring Boot                                                                  |
| Database | PostgreSQL (local dev) → Google Cloud SQL (prod)                                    |
| iOS      | SwiftUI + Firebase Auth (Apple, Google, Email+Password)                             |
| Deploy   | Google Cloud Run (containerized)                                                    |
| Payments | Stripe — Payment Links per gig; webhook flips `payment_status`                      |
| AI       | Vertex AI / Gemini — `gemini-2.5-pro` (drafts), `gemini-2.5-flash` (parsing/vision) |
| Weather  | Apple WeatherKit — iOS native only, no backend involvement                          |

## Architecture

- All REST routes live under `/api/v1/`.
- `JwtAuthFilter` (`security/JwtAuthFilter.java`) intercepts every `/api/**` request: reads the `Authorization: Bearer <token>` header, validates the JWT, sets the user UUID as principal, and rejects with 401 if missing or invalid.
- `SecurityConfig` (`config/SecurityConfig.java`): stateless, no CSRF, all `/api/**` requires auth, auth endpoints (`/api/v1/auth/**`) are public. The Stripe webhook endpoint is excluded from the auth filter.
- Every query must be scoped to the user UUID from the security context. User A must never see User B's data.
- JPA `ddl-auto: validate` — Hibernate never creates or alters tables. All schema changes require a Flyway migration.
- Finance data is derived via aggregate queries on the `gigs` table — there is no separate payments/income table. The Stripe webhook updates `gigs.payment_status` directly.
- All AI calls are routed through Spring — never called directly from iOS.

**Package structure** (`config/` and `security/` exist; rest to be built):

```
com.jvilledaapps.gig_manager/
  config/       # SecurityConfig
  security/     # JwtAuthFilter
  controller/
  service/
  repository/
  model/
```

**MVP scope:**

Backend (B1–B15):

1. Project setup — done
2. Flyway + schema migrations
3. User profile endpoint
4. Gig CRUD
5. Client CRUD
6. Setlist + song CRUD
7. Gear inventory CRUD
8. Gig checklist + templates
9. Standalone to-dos
10. Stripe — Payment Link generation + webhook
11. Finance summary
12. Vertex AI foundation
13. AI draft-message endpoint
14. AI parse-gig + analyze-gear endpoints

iOS (I1–I9):

1. Xcode project + Firebase Auth
2. APIClient + models
3. TabView + Profile tab
4. Schedule tab (calendar + new gig + paste-from-message)
5. Gig Detail (map + checklists + draft message)
6. Home tab (next gig + finance + outstanding + weather)
7. To-Do tab
8. Voice-input button
9. Photo-to-gear flow

Deploy (D1): Cloud Run + Cloud SQL + Stripe secrets + Vertex AI service account

## Coding Conventions

- Every file requires a header comment explaining its purpose.
- Controllers are thin — delegate all logic to services.
- DRY: extract repeated logic into reusable methods.
- KISS: prefer the straightforward solution over the clever one.
- Comments only where the intent is non-obvious.

## UI & System Design

- iOS uses a 4-tab structure: **Home**, **Schedule**, **To-Do**, **Profile**. Gig Detail is a pushed view reached from Home or Schedule, not its own tab.
- Dark mode throughout.
- Voice input uses iOS-native `SFSpeechRecognizer` only — no backend call, no LLM cost.

## Content Guidelines

- Event type is a freeform string on gigs (e.g. "wedding", "grad party"). Suggestions are sourced from the user's own history only via `GET /api/v1/gigs/event-type-suggestions` — no seed list, no separate table.
- Finance totals are always derived — never stored as redundant fields.
- AI-generated content (draft messages, parsed gig details) originates from Spring endpoints. iOS only displays the result.

## Testing & Quality

- Manually verify all acceptance criteria before marking a card In Review.
- Write a unit test for logic-heavy code (services, calculations).
- Integration tests must hit a real database — do not mock the DB layer.

## File and Component Placement

- Backend: feature packages under `com.jvilledaapps.gig_manager/` — controller, service, repository, model, config, security.
- iOS: organize files by feature/tab, not by file type.
- Flyway migrations: `backend/src/main/resources/db/migration/`, named `V{n}__{description}.sql`.

## Safe-Change Rules

- `JwtAuthFilter` and `SecurityConfig` are security-critical. Any change requires a manual re-test of the full auth flow.
- Never modify the schema without a corresponding Flyway migration. Never change `ddl-auto`.
- The Stripe webhook endpoint must remain excluded from the auth filter.
- All `/api/**` routes must require authentication — do not add public exceptions without explicit approval.

## Commands

All commands run from the `backend/` directory.

```bash
# Start dev server (requires PostgreSQL running locally)
./mvnw spring-boot:run

# Build a JAR
./mvnw package

# Run all tests
./mvnw test

# Run a single test class
./mvnw test -Dtest=ClassName

# Run a single test method
./mvnw test -Dtest=ClassName#methodName
```

**Prerequisites**: PostgreSQL at `localhost:5432` with a `gigmanager` database and `postgres/postgres` credentials.
