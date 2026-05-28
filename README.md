# Gig Manager

A full-stack mobile app built for working musicians to manage the operational side of their career — gigs, clients, income, setlists, gear, and to-dos — all in one place.

The backend is a secured REST API (Spring Boot + PostgreSQL) with JWT authentication supporting Apple, Google, and email sign-in. The iOS client is built in SwiftUI with a clean 4-tab layout. Stripe handles payment tracking via webhooks, and Vertex AI powers smart features like drafting client messages and parsing gig details from natural language. All backend AI calls are routed through Spring — the iOS client only displays results.

Built as a solo end-to-end project covering API design, database migrations, iOS development, cloud deployment, and third-party integrations.

## Tech Stack

| Layer    | Choice                                                                   |
| -------- | ------------------------------------------------------------------------ |
| Backend  | Java / Spring Boot                                                       |
| Database | PostgreSQL (local) → Google Cloud SQL (prod)                             |
| iOS      | SwiftUI + custom JWT auth (Apple, Google, Email+Password)                |
| Deploy   | Google Cloud Run (containerized)                                         |
| Payments | Stripe — Payment Links per gig; webhook flips payment status             |
| AI       | Vertex AI / Gemini (`gemini-2.5-pro` drafts, `gemini-2.5-flash` parsing) |
| Weather  | Apple WeatherKit — iOS native only                                       |

## Repo Structure

```
backend/    # Spring Boot API
mobile/     # Xcode / SwiftUI iOS app
docs/       # Personal scratch space (gitignored)
```

## MVP Status

**Backend**

- [x] Project setup
- [x] Flyway + schema migrations
- [x] User profile endpoint
- [x] Gig CRUD
- [x] Client CRUD
- [ ] Setlist + song CRUD
- [ ] Gear inventory CRUD
- [ ] Gig checklist + templates
- [ ] Standalone to-dos
- [ ] Stripe: Payment Link generation + webhook
- [ ] Finance summary
- [ ] Vertex AI foundation
- [ ] AI draft-message endpoint
- [ ] AI parse-gig + analyze-gear endpoints

**iOS**

- [x] Xcode project + auth
- [x] APIClient + models
- [ ] TabView + Profile tab
- [ ] Schedule tab (calendar + new gig + paste-from-message)
- [ ] Gig Detail (map + checklists + draft message)
- [ ] Home tab (next gig + finance + outstanding + weather)
- [ ] To-Do tab
- [ ] Voice-input button
- [ ] Photo-to-gear flow

**Deploy**

- [ ] Cloud Run + Cloud SQL + Stripe secrets + Vertex AI service account

---

See `CLAUDE.md` for branching, commit, and PR workflow.
