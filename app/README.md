# VrikshaChain Flutter App

A Flutter mobile application for the VrikshaChain herbal supply chain management system. This app shares the same Firebase backend with the web application, enabling seamless synchronization across platforms.

## Overview

This Flutter app provides the same functionality as the web application:
- **Authentication**: Email/Password and Google Sign-In (shared with web)
- **Batch Management**: Create, view, update, and track batches in real-time
- **Quality Metrics**: Add and manage quality metrics linked to batches
- **Certifications**: Manage product certifications
- **Analytics**: View supply chain statistics and insights
- **Real-time Sync**: All data syncs in real-time with Firebase Realtime Database

## Firebase Integration

### Shared Database

Both the web app and Flutter app use the **same Firebase project**:
- **Project ID**: `vriksha-chain`
- **Database URL**: `https://vriksha-chain-default-rtdb.asia-southeast1.firebasedatabase.app`
- **Authentication**: Shared user accounts between web and mobile

### Data Structure

The app syncs with the following Firebase Realtime Database paths:
- `/batches` - All batch data
- `/qualityMetrics` - Quality metrics linked to batches
- `/certifications` - Product certifications
- `/stats` - Calculated statistics

### Authentication

- **Email/Password**: Same credentials work on both web and mobile
- **Google Sign-In**: Uses the same Firebase project, so Google accounts are shared
- **Real-time Auth State**: Authentication state syncs across devices

## Architecture

### Project Structure

```
lib/
├── main.dart                 # App entry point with Firebase initialization
├── models/                   # Data models
│   ├── batch_model.dart
│   └── quality_metric_model.dart
├── services/                 # Firebase services
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   └── database_service.dart
├── providers/                # State management (Provider pattern)
│   ├── auth_provider.dart
│   ├── batch_provider.dart
│   └── quality_metrics_provider.dart
├── screens/                  # App screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── batches_screen.dart
│   ├── batch_detail_screen.dart
│   ├── analytics_screen.dart
│   └── quality_metrics_screen.dart
├── widgets/                  # Reusable widgets
│   ├── stats_cards.dart
│   ├── recent_batches_list.dart
│   ├── create_batch_dialog.dart
│   ├── quality_metric_form_dialog.dart
│   └── certification_form_dialog.dart
└── routes/                   # Navigation routing
    └── app_router.dart
```

### State Management

Uses the **Provider** pattern for state management:
- `AuthProvider`: Manages authentication state
- `BatchProvider`: Manages batch data with real-time sync
- `QualityMetricsProvider`: Manages quality metrics and certifications

### Real-time Data Sync

All providers use Firebase Realtime Database streams:
```dart
Stream<DatabaseEvent> getBatchesStream() {
  return FirebaseDatabase.instance.ref().child('batches').onValue;
}
```

When data changes in Firebase (from web or mobile), all connected clients receive updates instantly.

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or later)
- Firebase account with the `vriksha-chain` project
- Android Studio / Xcode (for mobile development)

### Installation

1. **Install Flutter dependencies:**
   ```bash
   cd app
   flutter pub get
   ```

2. **Configure Firebase (Already done):**
   - Firebase configuration is hardcoded in `lib/main.dart`
   - Uses the same Firebase project as the web app

3. **Platform-specific setup:**

   **Android:**
   - No additional setup needed (Firebase config is in code)
   
   **iOS:**
   - May need to add iOS bundle identifier in Firebase Console
   - Download and add `GoogleService-Info.plist` (if required)

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d chrome        # Web
flutter run -d android      # Android
flutter run -d ios          # iOS
```

## Features

### 1. Authentication
- Email/Password login (shared with web)
- Google Sign-In (shared with web)
- Persistent authentication state
- Automatic session management

### 2. Batch Management
- **View Batches**: Real-time list of all batches
- **Create Batch**: Add new batches with all details
- **Update Status**: Change batch status in real-time
- **Batch Details**: View full batch information with QR code
- **Search & Filter**: Find batches by product, batch number, status

### 3. Quality Metrics
- **Add Metrics**: Create quality metrics linked to specific batches
- **Filter by Batch**: View metrics for specific batches
- **Score Tracking**: Track quality scores (0-100)
- **Status Management**: Manage metric status (Certified, Passed, Failed, etc.)
- **Notes**: Add additional notes to metrics

### 4. Certifications
- **Add Certifications**: Create new certifications
- **Active/Inactive**: Toggle certification status
- **Expiry Tracking**: Track certification expiry dates
- **Issuing Body**: Record certification authority

### 5. Analytics
- **Key Metrics**: Total batches, active batches, supply partners
- **Quality Score**: Average quality score across batches
- **Traceability Rate**: Percentage of fully traceable batches
- **Top Products**: Products with most batches

## Integration with Web App

### Shared Authentication

1. **Sign in on web** → Can access same account on mobile
2. **Sign in on mobile** → Can access same account on web
3. **Sign out on one** → Session persists on the other (until explicitly signed out)

### Shared Data

1. **Create batch on web** → Appears instantly on mobile
2. **Update status on mobile** → Updates instantly on web
3. **Add quality metric on web** → Appears on mobile in real-time
4. **All changes sync bidirectionally** → Both platforms stay in sync

### Real-time Synchronization

The Firebase Realtime Database provides:
- **Instant Updates**: Changes appear within milliseconds
- **Offline Support**: Data persists locally, syncs when online
- **Conflict Resolution**: Firebase handles concurrent updates
- **Cross-platform**: Web, iOS, Android all sync together

## Data Flow

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Web App   │────────▶│   Firebase   │◀────────│ Flutter App │
│  (React)    │         │   Realtime   │         │   (Dart)    │
│             │◀────────│   Database   │────────▶│             │
└─────────────┘         └──────────────┘         └─────────────┘
     ▲                          ▲                          ▲
     │                          │                          │
     └─────────── Real-time Sync ───────────────────────────┘
```

1. User action on Web or Mobile
2. Change written to Firebase Realtime Database
3. Firebase broadcasts change to all connected clients
4. Web and Mobile apps receive update simultaneously
5. UI updates automatically

## Firebase Configuration

The app uses the following Firebase configuration (shared with web):

```dart
FirebaseOptions(
  apiKey: "AIzaSyAB6lo7ZKQpSAf-CS9jY1HxG-OACZo21-4",
  authDomain: "vriksha-chain.firebaseapp.com",
  databaseURL: "https://vriksha-chain-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "vriksha-chain",
  storageBucket: "vriksha-chain.firebasestorage.app",
  messagingSenderId: "263466607025",
  appId: "1:263466607025:web:31d3334ac56f7d13fb1d90",
)
```

## Dependencies

Key packages used:
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `firebase_database`: Realtime Database
- `provider`: State management
- `go_router`: Navigation
- `qr_flutter`: QR code generation
- `intl`: Date formatting

## Testing

Test the integration:
1. **Create a batch on web** → Check if it appears on mobile
2. **Update status on mobile** → Check if web updates
3. **Add quality metric on web** → Check mobile real-time sync
4. **Sign in on web** → Sign in on mobile with same account

## Troubleshooting

### Authentication Issues
- Ensure Firebase project has Authentication enabled
- Check that Email/Password and Google providers are enabled
- Verify Firebase configuration matches web app

### Data Not Syncing
- Check internet connection
- Verify Firebase Realtime Database rules allow read/write
- Check Firebase project is the same (`vriksha-chain`)

### Build Errors
- Run `flutter pub get` to install dependencies
- Ensure Flutter SDK is 3.0.0 or later
- Check Android/iOS setup if platform-specific issues

## Security Notes

- Firebase security rules should be configured in Firebase Console
- Authentication is required for all data access
- Database rules should restrict access to authenticated users

## Future Enhancements

- Push notifications for batch updates
- Offline-first data handling
- Barcode scanning for batch lookup
- Map integration for location tracking
- Export batch data to PDF/CSV

## Support

For issues related to:
- **Flutter App**: Check this README and code comments
- **Firebase Setup**: See `../FIREBASE_SETUP.md` in the main project
- **Web App Integration**: See `../README.md` in the main project

## License

Same license as the main VrikshaChain project.


