<!-- BEGIN:rails-agent-rules -->

# This is NOT the Rails you know

This repo is a Rails 8 API-only backend, not a full-stack Rails app. It uses JWT auth, PostgreSQL, Solid Queue/Cache/Cable, and Cloudinary-backed uploads with metadata stored in `uploaded_files`.

Before writing code, read the existing controllers, concerns, and services that already define the project patterns. Prefer extending those patterns over introducing new abstractions or parallel implementations.

<!-- END:rails-agent-rules -->

# Agent Guide

## Key Structure

```text
app/
  controllers/api/v1/        # API endpoints
  controllers/concerns/      # auth, authorization, response helpers
  models/                    # AR models
  services/                  # JWT, payload builders, uploads
config/
  routes.rb                  # note singular `resource :me`
  locales/                   # vi/en API messages
  database.yml               # primary + cache/queue/cable DBs
docs/
  routes/*.jsonc             # API request/response contract examples by module
db/
  migrate/
  seeds/
bin/
  setup, dev, rails, rubocop, brakeman
```

## Core Rules

- API-only app: do not add view/template-oriented patterns unless really needed.
- Response envelope is standardized: always return `{ success, message, data, errors }` via `ApiResponse`.
- API controllers should usually inherit from `Api::V1::BaseController`.
- Auth goes through `authenticate_user!`; permission checks go through `authorize_permission!("resource.action")`.
- Use I18n for API messages.
- Prefer extending existing services/concerns over creating parallel abstractions.

## How To Read The Repo

- Routes live under `/api/v1`.
- `resource :me` is singular and must stay mapped with `controller: :me`; do not let Rails infer `MesController`.
- Read in this order before editing: `config/routes.rb` -> target controller -> related concern/service -> relevant model.
- For API changes, inspect response helpers and locale files before changing payloads or messages.
- For upload-related changes, inspect the upload services and related model/controller together.
- For user-facing payload changes, inspect the payload builder and all controllers that return it.

## Editing Rules

- Keep changes aligned with existing patterns; avoid introducing parallel flows for the same concern.
- Keep JSON payload keys stable unless the task explicitly changes the API contract.
- Implement related layers together when needed: route, controller, params, service, model, response, locale, and the affected files in `docs/routes/*.jsonc`.
- Reuse existing concerns/services/builders before adding new ones.
- Keep seed updates idempotent.
- When adding a new message key, update both Vietnamese and English locale files unless there is a strong reason not to.
- If you change any API route, request params, response payload, auth behavior, or permission requirement, update the affected files in `docs/routes/*.jsonc` in the same change.

## Env Rules

- Required Cloudinary: `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`.
- Common auth/env: `JWT_SECRET`, `CORS_ORIGINS`, `RAILS_MASTER_KEY`.
- DB is PostgreSQL; production also uses cache/queue/cable databases and `:solid_queue`.

## Verification

- Setup/check: `bin/setup`, `bin/dev`, `bin/rubocop`, `bin/brakeman`.
- When changing routes, verify with `bin/rails routes`.
- When changing upload/auth behavior, verify both success and failure paths.

## Safe Defaults

- Avoid silent breaking changes to auth payloads, user payloads, or upload payloads; frontend-facing structures likely depend on them.
- If adding a new protected endpoint, implement authentication, permission check, strong params, and standardized response format together.
- Prefer small, localized edits over broad refactors unless the task explicitly asks for restructuring.
