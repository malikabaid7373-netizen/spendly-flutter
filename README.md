# Spendly

Spendly is a polished bilingual personal finance portfolio app built with Flutter. It focuses on clean budgeting, local-first persistence, useful analytics, and a premium fintech-inspired experience without connecting to real banking services.

## Highlights

- Animated splash and onboarding
- Local login/register/demo experience
- English + Arabic with RTL/LTR support
- Light + dark themes
- Income and expense tracking
- Transaction search, type filters, recurring filter, edit and delete
- Category budgets with animated progress and budget health states
- Financial health score (0-100)
- Smart data-driven financial insight
- Weekly spend and no-spend-day tracking
- Projected monthly spending
- Recurring expense summary
- Month-over-month spending comparison
- 7-day cash-flow pulse chart
- 6-month expense trend
- Category pie chart
- Premium responsive navigation for phone/tablet layouts
- SQLite persistence
- Provider state management
- Repository/service architecture

## Stack

- Flutter 3.27 compatible source
- Dart 3.6 compatible constraints
- Provider
- go_router
- sqflite
- shared_preferences
- fl_chart
- intl

## Android build configuration

The included Android project is configured for Android API 35 development with:

- Android Gradle Plugin 8.6.1
- Gradle 8.7
- Java/Kotlin target 17

## Run

```bash
flutter clean
flutter pub get
flutter analyze
flutter run
```

## Portfolio note

Spendly is intentionally local-first. It demonstrates mobile UI engineering, navigation, persistence, state management, charts, localization, theming, responsive layout, and product polish without pretending to be a real banking product.

## Performance architecture

Spendly v1.2 keeps the five main tabs alive with `StatefulShellRoute.indexedStack`, caches finance summaries inside `FinanceViewModel`, uses one-shot reveal animations, updates local UI optimistically before SQLite persistence completes, and loads finance data after the first app frame so navigation and settings feel more immediate.
