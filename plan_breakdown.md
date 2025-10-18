# Detailed plan

## Phase 0. Preparation and setup

- Technology selection: Flutter, Firebase, SQLite/Firestore, Google API.
- Environment setup: IDE, Git, Firebase, Google Cloud.
- Architecture design: MVVM/Clean, ER diagram, wireframes, data models.

## Phase 1. Basic functionality (Vehicle management)

- 1.1 CRUD for vehicles, selection of active vehicle, avatar, gallery.
  - Reused unified vehicle create/edit form across list and details pages (Manage > Edit) to keep UX consistent.
- 1.3 Home dashboard timeline hooked to vehicle quick actions with unified event storage (odometer, notes, refuel, service, etc.).
  - Bottom sheet quick actions wired to the Home FAB and scoped to the active (primary) vehicle; new entries appear instantly in the timeline.
  - Event timeline cards open a detail view with edit/delete actions and reuse the unified event form.
- 1.2 Photo album (integration with camera, categories, full-screen, compression).

## Phase 2. Fuel tracking

- 2.1 Refueling module: forms, validation, history, photo receipts.
- 2.2 Consumption calculation (l/100 km, trends, comparison, cache).
- 2.3 Fuel types: gasoline/diesel/electric/hybrid/LPG.

## Phase 3. Expenses and service

- 3.1 Expenses module: categories, filters, sorting, documents.
- 3.2 Maintenance module: service history, service station contacts, integration with expenses.

## Phase 4. Statistics and analytics

- 4.1 Basic statistics: total expenses, categories, averages.
- 4.2 Charts: fuel consumption trends, diagrams, chart library.

## Phase 5. Events/Reminders

- 5.1 Reminders: maintenance, insurance, registration, additional events.

## Phase 6. Trip Log

- 6.1 Trip tracking: routes, categories, business expenses.
- 6.2 Integration with Google Calendar.

## Phase 7. Cloud synchronization

- 7.1 Firebase Auth, storage in Firestore.
- 7.2 Backup to Google Drive.

## Phase 8. Google integrations

- 8.1 Google Sign-In.
- 8.2 Google Drive (files, backups).
- 8.3 Google Photos (album synchronization).
- 8.4 Google Calendar (reminders).
- 8.5 Google Maps (routes).
- 8.6 Google Places (service stations).
- 8.7 Google Sheets (export).

## Phase 9. Notifications and automation

- Push notifications, cron jobs, server functions.

## Phase 10. Monetization

- Freemium, subscription, payment analytics, paywall.

## Phase 11. UI/UX polishing

- Themes, animations, localization, accessibility, brand kit.

## Phase 12. Testing and QA

- Unit/widget/integration tests, manual, beta testing.

## Phase 13. Publication

- Preparation for release, deployment in stores, support.

## Phase 14. Support and roadmap 2.0

- Monitoring, features 2.0 (AI, communities, marketplace, OBD2, voice, wearables, CarPlay/Android Auto).

---

# Completed phases

- **Phase 0**  project created, environment configured, basic architecture defined.
- **Phase 1.1**  car management (CRUD, primary selection) and base UI implemented.
- **Phase 1.2 (partial)**  photo album UI with category filters, full-screen viewer, and add/delete flows via URL entry.

---

# Next steps

1. Finalize remaining **Phase 1.2** items: native camera capture support and image compression once backend/storage constraints are clarified.
2. Extend **Phase 3/4** scope by wiring non-fuel expense sources into the reports cost analytics and expose navigation hooks for deeper drill-ins (vehicle details, expense editor).
3. Add targeted widget tests for the new report tabs/shared components to grow automated coverage.
4. Prepare real storage for cars (HTTP/SQLite) in accordance with **Phase 7** after completion of the basic modules.

---

## Progress log (2025-10-14)

- Implemented the vehicle photo album overhaul: category chips, full-screen viewer, and add/delete flows storing metadata in the repository stubs.
- Updated tests to cover the new photo workflow and keep regression coverage on vehicle CRUD flows.
- Seeded richer demo data and refreshed plan to call out pending camera/compression work for Phase 1.2.
- Promoted the vehicle detail view to the primary interaction when tapping tiles, adding quick stat cards, expanded specs, and document attachments aligned with the vehicle_info mocks.
- Delivered document management UX (attach, list, remove) with repository support plus widget coverage to guard the new flows.
- Rolled the refreshed glassmorphism-inspired aesthetic across the shell, home, quick actions, drawers, and placeholder screens.



2025-10-14 (UI polish, remove glassmorphism)
- Removed frosted/blurred styling across the app; switched to flat surfaces and solid borders (see AppTheme changes).
- Restyled bottom navigation within a simple surface container; constrained width to content and fixed spacing to avoid overflow.
- Simplified Quick Actions overlay: no background box, right-aligned icons, consistent padding/spacing; FAB offset to avoid nav overlap.
- Aligned Home cards and stats tiles for uniform sizes; removed redundant quick actions row.
- Standardized snackbars to avoid collisions with nav/FAB; all widget tests remain green.

2025-10-14 (Vehicle cover photo)
- Added the ability to set the main vehicle photo directly from the album grid via the more menu ("Set as main photo").
- Persist cover update by saving `photoUrl` on the selected vehicle and show confirmation toast.

2025-10-14 (Media picking prototype)
- Added device photo picking on the Add Photo sheet:
  - Web/Desktop via file_picker (reads bytes, stores as data URL),
  - Mobile via image_picker (gallery). No backend required.
- Kept URL entry as an alternative; saved images render via the same URL field (supports data URIs).
- Tests remain green; follow-ups: compression and camera capture.

2025-10-15 (Document & photo picker enhancements)
- Replaced document URL field with a file picker-driven flow that captures selected files as data URIs, updates card styling to match design/vehicle_info_02.png, and refreshes snack copy.
- Overhauled the photo attach sheet to support multi-select from gallery/files, show removable previews, and deliver accurate success messaging; added widget test coverage for the new workflow.
- Follow-up fix: moved the sheet state into its own widget so selections persist when tapping whitespace or adjusting focus.
- Fine-tuned the selection tray: refreshed empty-state styling, limited gallery launching to the empty area, and added tap-through previews for already chosen photos.

2025-10-15 (Phase 2 kickoff)
- Documented outstanding work for Phase 1.2 (device camera capture + image compression once storage constraints are clear).
- Began planning Phase 2 scope: refueling form UX, consumption analytics, and fuel type metadata.

   
- Implemented refueling dashboard UI: vehicle selector, summary cards, fill-up history, and add/edit sheet bound to in-memory data. (refueling_page, and reports_page are not finished, need to rewrite them)

## Progress log (2025-10-16)

- Split the reports experience into dedicated tabs: fuel, costs, odometer, and ownership each live in their own module with shared tab components for metric cards, selectors, and placeholders.
- Expanded the analytics surface: costs tab now aggregates spending metrics/monthly totals, odometer tab charts recent mileage snapshots and service cadence, ownership tab surfaces document counts and renewal reminders.
- Cleaned up analyzer warnings and deprecated API usage (withValues, vehicle dialog refactors), keeping `flutter analyze` green after the restructuring.
