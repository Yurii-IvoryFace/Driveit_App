# Phase 2 – Vehicle Data Source Integration

## Goals
- Replace the in-memory vehicle storage with a real persistence layer powered by your local server (REST/gRPC) or direct SQLite access.
- Maintain the existing `VehicleRepository` interface so presentation code remains untouched.
- Support offline-friendly reads once SQLite is wired up.

## Data Requirements
- **Vehicle fields**: `id`, `displayName`, `make`, `model`, `year`, `vin?`, `licensePlate?`, `photoUrl?`, `isPrimary`.
- **Relationships**: each record belongs to the authenticated user (add `ownerId` once auth appears).
- **Constraints**:
  - `id` unique per vehicle (keep UUID on client until server generates IDs).
  - Only one `isPrimary == true` per user; server should enforce uniqueness.
  - `year` within reasonable bounds (e.g., 1950 ≤ year ≤ currentYear + 1).

## API Contract (proposed REST)
| Method | Path | Description |
| --- | --- | --- |
| `GET /api/vehicles` | Return `List<VehicleDto>` for current user. |
| `POST /api/vehicles` | Create or replace by `id`; body is `VehicleDto`. |
| `DELETE /api/vehicles/{id}` | Remove vehicle. |
| `POST /api/vehicles/{id}/primary` | Mark vehicle as primary and clear previous primary. |

Responses should be JSON using the same shape as `VehicleDto`. For combined SQLite + API, expose equivalent repository methods locally.

## Synchronization Strategy
1. **SQLite-first**: persist vehicles locally; run sync job to POST to server when online.
2. **Server-first**: fetch list on app launch; cache in SQLite for offline reads.
3. Use `updatedAt` timestamps (add to DTO when backend ready) to resolve conflicts.

## Next Development Steps
1. Implement a concrete `VehicleLocalDataSource` (e.g., `HttpVehicleDataSource`) that calls the local server using `http` package.
2. Optionally add `SQLiteVehicleDataSource` using `sqflite`/`drift` when schema is defined.
3. Update DI in `main.dart` to switch between in-memory, HTTP, and SQLite data sources via flavor/env config (see `AppConfig` usage).
4. Extend widget/integration tests with fake server responses.

Keep this document updated as soon as the backend contract stabilises.
