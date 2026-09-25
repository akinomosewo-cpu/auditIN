# Band A Audit ⚡

A Flutter app that silently tracks AEDC power supply hours on your phone and automatically generates formal complaint letters when your Band A feeder underdelivers.

---

## How It Works

- Detects power on/off by monitoring whether your phone is charging (connected to grid) or on battery
- Logs every change with a timestamp — no manual input needed
- Computes daily supply hours and compares them to your band's promise (Band A = 20+ hrs/day)
- When your 30-day average falls below the threshold, generates a ready-to-send complaint to AEDC or NERC
- Feeder data is anonymised and shared to build an Abuja-wide supply reliability map

---

## Architecture

Clean Architecture with BLoC state management:

```
lib/
├── core/
│   ├── constants/        # App constants, enums (bands, tariffs)
│   └── theme/            # Colors, typography, component styles
├── data/
│   ├── datasources/      # Hive local storage, battery monitoring
│   ├── models/           # Hive-annotated data models
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Pure Dart entities (PowerLog, DailyStat, Complaint)
│   ├── repositories/     # Abstract interfaces
│   └── usecases/         # Business logic use cases
└── presentation/
    ├── blocs/            # BLoC state management (dashboard, history)
    ├── pages/            # Screens (Dashboard, History, Map, Complaints, Settings)
    └── widgets/          # Reusable UI components
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | flutter_bloc + BLoC pattern |
| Local Storage | Hive (NoSQL, offline-first) |
| Power Detection | battery_plus (charge state monitoring) |
| Background Tasks | workmanager + flutter_background_service |
| Charts | fl_chart |
| Notifications | flutter_local_notifications |
| PDF Generation | pdf + printing (complaint letters) |
| Architecture | Clean Architecture (Domain / Data / Presentation) |

---

## Setup Instructions

### 1. Prerequisites

- Flutter SDK 3.0.0+
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 21+)
- iOS device or simulator (iOS 12+)

### 2. Clone & Install

```bash
git clone https://github.com/YOUR_USERNAME/band_a_audit.git
cd band_a_audit
flutter pub get
```

### 3. Generate Hive Adapters

```bash
dart run build_runner build --delete-conflicting-outputs
```

> This generates the `.g.dart` files for Hive type adapters. Must be run before building.

### 4. Android Permissions

Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.BATTERY_STATS"/>
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>
```

### 5. iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to tag your feeder location for the supply reliability map</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Used to monitor power supply at your location</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

### 6. Run

```bash
# Debug
flutter run

# Release build (Android)
flutter build apk --release

# Release build (iOS)
flutter build ipa --release
```

---

## Claude Code Instructions

When continuing development with Claude Code, use these prompts:

**To generate Hive adapters:**
```
Run: dart run build_runner build --delete-conflicting-outputs
```

**To implement background service:**
```
Implement the WorkManager background task in lib/data/datasources/power_local_datasource.dart
that calls computeAndSaveTodayStat() every 15 minutes using the workmanager package.
```

**To implement complaint PDF generation:**
```
Implement the generateComplaintPdf() function in lib/domain/usecases/power_usecases.dart
using the pdf package. Include: user details, band info, 30-day supply table, average hours,
deficit hours, estimated overcharge in naira, and AEDC/NERC contact info.
```

**To implement the map page:**
```
Implement the MapPage in lib/presentation/pages/map_page.dart using flutter_map + latlong2.
Show a map of Abuja with markers per feeder, colored by average supply hours (green = 20+h,
yellow = 12-20h, red = <12h). Use OpenStreetMap tiles.
```

---

## Screens

| Screen | Description |
|--------|-------------|
| Dashboard | Live power status, today's hours, 30-day stats, mini chart |
| History | Bar chart of daily hours, aggregate stats, period selector |
| Map | Feeder reliability map across Abuja |
| Complaints | Generate and track complaint letters to AEDC/NERC |
| Settings | Band selection, meter number, tracking toggle, data export |

---

## App 3 of 11 — Abuja Infrastructure Series

This is part of a series of apps solving Abuja-specific infrastructure problems:
1. Tax Filing Assistant
2. E-Invoicing Tool for SMEs
3. **Band A Audit** ← you are here
4. Solar Sizing & Installer App
5. FCT Land Due-Diligence
6. Remote Build Monitor
7. Street Levy & Guard Payroll
8. Water Tanker Booking
9. Agro-Input Verification
10. Reusable Crate Ledger
11. Abuja Transit Map
