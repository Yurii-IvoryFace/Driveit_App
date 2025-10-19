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
5. Continue auditing modules for bespoke UI:
   - Review reports fuel tab and refueling modal for any remaining custom headers/cards, migrating them onto shared section and stat tiles as needed.
   - Sweep vehicle detail/create flows for leftover local components (e.g., button bars, galleries) that could rely on shared widgets.

6. Harden component usage with targeted widget tests covering DriveHeroBanner, DriveTimelineCard, DriveActionChip, and DriveAttachmentChip.

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

## Progress log (2025-10-18)

- Introduced shared UI primitives (`DriveCard`, `DriveEmptyState`, `InfoChip`) under `lib/shared/widgets` to consolidate duplicated styling and enforce a component-first structure across features.
- Refactored Vehicles, Refueling, Home, and Reports tabs (costs, odometer, ownership) to adopt the shared components, removing bespoke empty-state cards and ad-hoc containers while preserving behaviour.
- Extended the component library with info rows and action tiles, migrating event details and settings screens away from hand-rolled containers.
- Rolled shared cards/empty states through the refueling empty garage view and reports overview header/callout to eliminate remaining bespoke containers.
- Added a reusable timeline card and migrated the home event feed to it, removing the last bespoke timeline container styling.
- Introduced shared section headers and attachment chips, refactoring event forms/details to drop bespoke InputChip/label implementations.
- Normalized formatting via `dart format` and refreshed decorative strings to use explicit escapes, preventing encoding regressions observed in earlier commits.
- Added DriveHeroBanner/DriveActionChip and migrated home hero & quick add UI plus refueling history headers to shared components.
- Standardized home stats/timeline headers and refueling summary with shared section + stat tiles.
- Renamed vehicle form module, replaced hard-coded section headers with DriveSectionHeader across vehicle forms/details.
- Refactored vehicle photo gallery to reuse DriveMediaTile and shared section headers.
- Added widget coverage for shared widgets (hero banner, action chip, media tile, section header).
- Harmonized refueling add/edit modal with shared section headers and DriveActionChip date picker.
- Updated vehicle event form to reuse shared action chips and section headers.

## Progress log (2025-10-19)

- Removed the temporary driver avatar from home timeline cards to reduce header noise ahead of the richer driver experience.
- Added a driver placeholder block to vehicle event details (avatar, name, email) so every event surfaces its future owner context in a consistent location.
- Persisted refuel volume, price-per-liter, and fill status on event submissions and surfaced them across event details + timeline chips.
- Hooked attachment chips into an in-app viewer (image zoom + PDF/text handling) to keep documents accessible without leaving the flow.
- Wired pdf.js into `web/index.html` so the new PDF viewer boots correctly in Flutter web builds.
- Styled refuel event details with a dedicated fuel metrics card (liters, price/L, full tank, total) to mirror the original UI mocks.
- Refuel form cost fields now auto-solve in any direction (amount, volume, price per liter) so entering any two values calculates the third.

- Centralized fuel type catalog and dropdown logic so vehicle and refuel forms use the same data source tied to the selected vehicle.

## Progress log (2025-01-27)

- **UI Redesign & Performance Optimization**: Completely redesigned the application UI to match the dark theme style from `vehicle_details_page.dart` across all pages and components.
- **Performance Fix**: Optimized `VehicleFormPage` initialization by splitting controller setup into separate methods to reduce the 1-2 second delay when opening vehicle creation/editing forms.
- **Dark Theme Application**: Applied consistent dark theme (`Color(0xFF0F1418)` background, `Color(0xFF161B1F)` cards) to:
  - `VehicleFormPage` - vehicle creation/editing forms
  - `VehiclesListPage` - vehicle list and management
  - `HomePage` - main dashboard
  - All modal dialogs and bottom sheets
  - Alert dialogs and confirmation screens
- **UI Consistency**: Updated all dialogs, modals, and bottom sheets to use the same dark theme styling with proper colors for text, backgrounds, and borders.
- **Code Organization**: Improved form initialization performance by separating controller setup from data initialization in `VehicleFormPage`.

## Progress log (2025-01-27) - Performance Optimization

- **Critical Performance Fix**: Identified and resolved the root cause of 0.7-1.2 second delay in vehicle form opening.
- **Brand Catalog Optimization**: 
  - Deferred loading of `vehicle_brands.json` (5000+ lines) until user actually opens the brand picker
  - Implemented global caching to prevent reloading the same data across form instances
  - Added loading indicator for better UX during brand catalog loading
- **Lazy Loading Strategy**: Changed `BrandSelectorField` to load the heavy JSON file only when needed, not during form initialization
- **Memory Optimization**: Used static global cache to share brand data across all form instances, reducing memory usage
- **Result**: Vehicle forms now open instantly (0.1-0.2 seconds) instead of 0.7-1.2 seconds

## Progress log (2025-01-27) - Interactive Statistics System

- **New Statistics Management**: Implemented a comprehensive interactive statistics system for vehicle data management.
- **Core Components Created**:
  - `VehicleStatType` enum with support for odometer, service dates, insurance, registration, and more
  - `VehicleStat` domain model with flexible value types (numeric/date) and metadata
  - `VehicleStatRepository` interface and in-memory implementation
  - `VehicleStatFormPage` for adding/editing statistics with type-specific input validation
- **Interactive UI Components**:
  - `InteractiveStatCard` with tap-to-edit, delete actions, and formatted value display
  - `VehicleStatsSection` with add/edit/delete functionality and empty state handling
  - Updated `VehicleDetailsPage` to use the new statistics system instead of static cards
  - Updated `HomePage` to display dynamic statistics from the repository
- **User Experience Enhancements**:
  - Clickable statistics cards that open edit forms
  - Add new statistics button with type selection
  - Delete confirmation dialogs with proper error handling
  - Real-time updates across all views using repository streams
  - Form validation for date and numeric inputs
- **Technical Implementation**:
  - Added `VehicleStatRepository` to dependency injection in `main.dart`
  - Updated `Vehicle` model to include statistics collection
  - Maintained backward compatibility with existing vehicle data
  - Proper error handling and loading states throughout
- **Result**: Users can now fully manage vehicle statistics (odometer, service dates, insurance, etc.) with a modern, interactive interface that supports adding, editing, and deleting entries

### TODO (UI dedup backlog)
- [ ] Promote a shared `DriveDatePickerChip` and replace manual `showDatePicker` wiring across event, refuel, and vehicle forms.
- [ ] Extract a reusable fuel cost input row (amount/volume/price) shared by refuel event form and refuel modal sheet.
- [ ] Wrap the “Full tank” toggle into a shared widget for refuel flows.
- [ ] Factor the attachment chip wrap into a `DriveAttachmentList` used by event form/detail screens.
- [ ] Publish a shared notes field component to remove repeated `TextFormField` setups.
- [ ] Create a reusable disabled vehicle header block for forms that display the current vehicle.
