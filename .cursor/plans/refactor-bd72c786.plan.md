<!-- bd72c786-da05-4f6c-81a6-2369b1cc5276 e9b17c59-e6aa-44bd-94f7-1b8fd4e4f1f1 -->
# План розробки DriveIt Refactored

## Поточний стан нової аплікації

**Що вже реалізовано:**

- Базова архітектура проекту (Clean Architecture: domain, data, presentation)
- Dependency injection з GetIt
- BLoC state management для vehicles
- Drift ORM database schema (Vehicles, Transactions, Attachments tables)
- Простий in-memory repository для Vehicle
- Базовий HomeScreen з Vehicle BLoC
- Theme setup (AppTheme, AppColors)
- Use cases для Vehicle operations

**Що потрібно мігрувати зі старої аплікації:**

- Vehicles: CRUD, photo album, documents, statistics, detail page, forms
- Events: unified event system (odometer, notes, income, service, expense, refuel)
- Refueling: tracking, calculations, fuel consumption analytics
- Expenses: categories, tracking, filtering
- Reports: fuel tab, costs tab, odometer tab, ownership tab with charts
- Settings: preferences, units, notifications
- UI Shell: navigation, drawer, quick actions
- Shared widgets: cards, headers, chips, forms, etc.

## Phase 1: Core Infrastructure & Database

### 1.1 Drift Database Implementation

**Файли для створення:**

- `lib/data/datasources/local/daos/vehicle_dao.dart` - Vehicle DAO для Drift
- `lib/data/datasources/local/daos/transaction_dao.dart` - Transaction DAO
- `lib/data/datasources/local/daos/attachment_dao.dart` - Attachment DAO

**Задачі:**

- Створити DAO класи з методами CRUD для кожної таблиці
- Реалізувати складні запити (watchVehicles, getVehicleWithStats, etc.)
- Додати методи для фільтрації та сортування
- Налаштувати relationships між таблицями

### 1.2 Repository Implementations

**Файли для створення:**

- `lib/data/repositories/vehicle_repository_impl.dart` - реалізація з Drift
- `lib/data/repositories/transaction_repository_impl.dart`
- `lib/data/repositories/attachment_repository_impl.dart`

**Задачі:**

- Мігрувати інтерфейси repository зі старої аплікації
- Реалізувати repositories використовуючи Drift DAOs
- Додати Stream-based методи для reactive UI
- Налаштувати converters між Drift models та domain entities

### 1.3 Domain Layer

**Файли для оновлення/створення:**

- `lib/domain/entities/vehicle.dart` - розширити поля (додати stats, photos, documents)
- `lib/domain/entities/transaction.dart` - додати всі типи events
- `lib/domain/entities/attachment.dart` - створити entity
- `lib/domain/entities/vehicle_stat.dart` - статистика авто
- `lib/domain/repositories/*.dart` - оновити інтерфейси

**Задачі:**

- Мігрувати всі domain entities зі старої аплікації
- Розширити Vehicle entity (photos, documents, stats lists)
- Створити enum для типів транзакцій та палива
- Додати value objects для складних типів

### 1.4 Dependency Injection Setup

**Файл для оновлення:**

- `lib/core/di/injection_container.dart`

**Задачі:**

- Видалити SimpleVehicleRepository
- Зареєструвати AppDatabase як singleton
- Зареєструвати всі DAOs
- Зареєструвати repository implementations
- Зареєструвати use cases для всіх features

## Phase 2: Vehicle Management (повна міграція)

### 2.1 Vehicle BLoC & Use Cases

**Файли для створення:**

- `lib/domain/usecases/vehicle_usecases.dart` - розширити (add/update/delete photos, documents, stats)
- `lib/presentation/bloc/vehicle/vehicle_event.dart` - додати events для photos/docs/stats
- `lib/presentation/bloc/vehicle/vehicle_state.dart` - розширити states

**Задачі:**

- Додати use cases для фото альбому
- Додати use cases для документів
- Додати use cases для статистики
- Оновити VehicleBloc для підтримки всіх операцій

### 2.2 Vehicle Screens

**Файли для створення:**

- `lib/presentation/screens/vehicles/vehicles_list_screen.dart`
- `lib/presentation/screens/vehicles/vehicle_detail_screen.dart`
- `lib/presentation/screens/vehicles/vehicle_form_screen.dart`
- `lib/presentation/screens/vehicles/vehicle_photo_album_screen.dart`
- `lib/presentation/screens/vehicles/vehicle_stat_form_screen.dart`

**Задачі:**

- Мігрувати VehiclesListPage з grid/list view
- Мігрувати VehicleDetailsPage з hero banner, stats cards, photo gallery
- Мігрувати VehicleFormPage з brand selector, всіма полями
- Реалізувати photo picker та управління альбомом
- Додати інтерактивні stat cards

### 2.3 Vehicle Widgets

**Файли для створення:**

- `lib/presentation/widgets/vehicle/vehicle_card.dart`
- `lib/presentation/widgets/vehicle/brand_selector_field.dart`
- `lib/presentation/widgets/vehicle/interactive_stat_card.dart`
- `lib/presentation/widgets/vehicle/vehicle_stats_section.dart`

## Phase 3: Events & Transactions System

### 3.1 Transaction BLoC

**Файли для створення:**

- `lib/presentation/bloc/transaction/transaction_bloc.dart`
- `lib/presentation/bloc/transaction/transaction_event.dart`
- `lib/presentation/bloc/transaction/transaction_state.dart`
- `lib/domain/usecases/transaction_usecases.dart`

**Задачі:**

- Реалізувати BLoC для управління транзакціями
- Додати фільтрацію по типу, даті, vehicle
- Підтримка всіх типів: refuel, service, expense, income, note, odometer

### 3.2 Transaction Screens

**Файли для створення:**

- `lib/presentation/screens/transactions/transaction_form_screen.dart`
- `lib/presentation/screens/transactions/transaction_detail_screen.dart`

**Задачі:**

- Універсальна форма для всіх типів транзакцій
- Conditional fields в залежності від типу
- Підтримка attachments (фото чеків, документів)
- Detail view з можливістю редагування/видалення

## Phase 4: Home Screen & Quick Actions

### 4.1 Home Screen Redesign

**Файли для створення:**

- `lib/presentation/screens/home/home_screen.dart` - оновити
- `lib/presentation/widgets/home/hero_banner.dart`
- `lib/presentation/widgets/home/timeline_card.dart`
- `lib/presentation/widgets/home/quick_action_menu.dart`

**Задачі:**

- Hero banner з primary vehicle
- Stats slider (odometer, service dates, insurance)
- Timeline з останніми events
- Quick action FAB з menu

### 4.2 Home BLoC

**Файли для створення:**

- `lib/presentation/bloc/home/home_bloc.dart`
- `lib/presentation/bloc/home/home_event.dart`
- `lib/presentation/bloc/home/home_state.dart`

**Задачі:**

- Комбінувати дані з Vehicle та Transaction BLoCs
- Завантаження primary vehicle
- Завантаження останніх events
- Real-time updates через streams

## Phase 5: Refueling Feature

### 5.1 Refueling Domain

**Файли для створення:**

- `lib/domain/entities/refueling_entry.dart`
- `lib/domain/entities/fuel_type.dart`
- `lib/domain/entities/refueling_summary.dart`
- `lib/domain/usecases/refueling_usecases.dart` (calculate consumption, get statistics)

### 5.2 Refueling BLoC & Screens

**Файли для створення:**

- `lib/presentation/bloc/refueling/refueling_bloc.dart`
- `lib/presentation/screens/refueling/refueling_list_screen.dart`
- `lib/presentation/screens/refueling/refueling_form_screen.dart`

**Задачі:**

- Форма заправки з auto-calculations
- Історія заправок
- Розрахунок витрати палива (л/100км)
- Fuel efficiency analytics

## Phase 6: Reports & Analytics

### 6.1 Charts & Analytics Utils

**Файли для створення:**

- `lib/core/utils/chart_data_utils.dart`
- `lib/presentation/widgets/charts/line_chart_widget.dart`
- `lib/presentation/widgets/charts/bar_chart_widget.dart`
- `lib/presentation/widgets/charts/pie_chart_widget.dart`

### 6.2 Reports Screens

**Файли для створення:**

- `lib/presentation/screens/reports/reports_screen.dart`
- `lib/presentation/screens/reports/tabs/overview_tab.dart`
- `lib/presentation/screens/reports/tabs/fuel_tab.dart`
- `lib/presentation/screens/reports/tabs/costs_tab.dart`
- `lib/presentation/screens/reports/tabs/odometer_tab.dart`
- `lib/presentation/screens/reports/tabs/ownership_tab.dart`

**Задачі:**

- TabBar з 5 вкладками
- Графіки використовуючи fl_chart
- Фільтри по датах, vehicle
- Статистичні cards

### 6.3 Reports BLoC

**Файли для створення:**

- `lib/presentation/bloc/reports/reports_bloc.dart`

**Задачі:**

- Агрегація даних по періодах
- Розрахунки для графіків
- Caching computed values

## Phase 7: UI Shell & Navigation

### 7.1 App Shell

**Файли для створення:**

- `lib/presentation/screens/shell/app_shell.dart`
- `lib/presentation/widgets/shell/app_drawer.dart`
- `lib/presentation/widgets/shell/bottom_nav_bar.dart`

**Задачі:**

- Bottom navigation з 4 табами
- Drawer menu
- Shell header з датою та sync button
- Page switching з animations

### 7.2 Navigation Setup

**Файл для створення:**

- `lib/core/navigation/app_router.dart`

**Задачі:**

- Налаштувати go_router
- Named routes для всіх screens
- Deep linking підготовка
- Navigation guards

## Phase 8: Shared Widgets Library

**Файли для створення в `lib/presentation/widgets/shared/`:**

- `drive_card.dart`
- `drive_section_header.dart`
- `drive_stat_tile.dart`
- `drive_action_chip.dart`
- `drive_empty_state.dart`
- `date_picker_chip.dart`
- `fuel_cost_inputs.dart`
- `attachment_chip.dart`
- `notes_field.dart`

**Задачі:**

- Мігрувати всі shared widgets зі старої аплікації
- Unified styling з theme
- Reusable form components

## Phase 9: Settings & Preferences

### 9.1 Settings Screen

**Файли для створення:**

- `lib/presentation/screens/settings/settings_screen.dart`
- `lib/core/preferences/app_preferences.dart`

**Задачі:**

- Theme preferences
- Units (km/miles, liters/gallons)
- Currency
- Notifications setup (placeholder)
- Cloud sync (placeholder для Phase 10+)

## Phase 10: Polish & Testing

### 10.1 Error Handling

**Задачі:**

- Додати proper error handling у всіх BLoCs
- User-friendly error messages
- Retry mechanisms
- Offline handling

### 10.2 Testing

**Файли для створення:**

- Unit tests для use cases
- Widget tests для screens
- BLoC tests

### 10.3 Performance

**Задачі:**

- Lazy loading для списків
- Image caching та compression
- Database query optimization
- Build performance check

## Важливі міграційні деталі

**З Provider на BLoC:**

- Замінити `Provider.of<>` на `context.read<Bloc>()`
- Замінити `Consumer` на `BlocBuilder`
- Замінити `ChangeNotifier` на `Bloc/Cubit`

**З SQLite DAO на Drift:**

- Використовувати generated code (build_runner)
- Type-safe queries
- Drift streams замість manual StreamController

**Архітектурні зміни:**

- Strict separation: domain ← data → presentation
- No Flutter imports in domain layer
- Entities замість models у domain
- DTOs/Models у data layer для serialization

**Data flow:**

```
UI (Widget) → BLoC Event → Use Case → Repository → DAO → Drift → SQLite
SQLite → Drift → DAO → Repository → BLoC State → UI Update
```

### To-dos

- [x] Phase 1: Core Infrastructure - Setup Drift DAOs, Repository implementations, Domain entities, DI configuration
- [x] Phase 2: Vehicle Management - Migrate all vehicle screens, BLoC, use cases, widgets (list, detail, form, photos, stats)
- [x] Phase 3: Events & Transactions - Create unified transaction system with BLoC, forms, and detail views
- [x] Phase 4: Home Screen - Rebuild home with hero banner, timeline, stats slider, quick actions
- [x] Phase 5: Refueling - Implement fuel tracking with consumption calculations and analytics
- [x] Phase 6: Reports & Analytics - Create 5 report tabs with charts (fl_chart) and statistics
- [x] Phase 7: UI Shell & Navigation - Build app shell with bottom nav, drawer, routing (go_router)
- [x] Phase 8: Shared Widgets - Migrate all reusable widgets from old app with unified theming
- [x] Phase 9: Settings - Implement preferences screen with units, currency, theme options
- [ ] Phase 10: Polish & Testing - Error handling, tests, performance optimization, final refinements