# FitWell

A comprehensive health and fitness tracking Flutter application.

## Features

- **Medicine Reminder**: Track and manage medication schedules with notifications
- **Meal Tracker**: Log meals and track daily calorie intake
- **Water Intake Tracker**: Monitor daily water consumption
- **User Authentication**: Login and signup functionality
- **Firebase Integration**: Cloud storage for data synchronization
- **Local Storage**: Hive for offline data persistence

## Getting Started

This project is a Flutter application that helps users track their health and fitness goals.

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Firebase project setup
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase:
   - Add `google-services.json` for Android (already present)
   - Configure Firebase for iOS if needed
4. Run `flutter run` to start the app

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                  # Data models
├── providers/               # State management (Provider)
├── screens/                 # UI screens
├── services/                # Services (notifications, etc.)
└── widgets/                 # Reusable widgets
```

## Dependencies

- `provider`: State management
- `hive` & `hive_flutter`: Local storage
- `cloud_firestore` & `firebase_core`: Cloud database
- `flutter_local_notifications`: Local notifications
- `timezone`: Timezone handling

## Getting Help

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
