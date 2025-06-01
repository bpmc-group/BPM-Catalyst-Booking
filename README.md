# Patient Booking App

A Flutter-based healthcare platform with role-based authentication for patients and doctors.

## 🎯 Current Status: Week 1 Complete

### ✅ Implemented Features

**Core Architecture:**

- ✅ User role system (Patient/Doctor)
- ✅ Role-based authentication with Firebase Auth
- ✅ State management with Riverpod
- ✅ Clean architecture with models and providers

**Authentication Flow:**

- ✅ User type selection screen
- ✅ Separate registration flows for patients and doctors
- ✅ Role-aware login system
- ✅ AuthWrapper for automatic routing

**UI/UX:**

- ✅ Beautiful, consistent design system
- ✅ Role-specific home dashboard
- ✅ Professional doctor registration form
- ✅ Responsive layouts

### ⚠️ Known Limitations (To be fixed in Week 2)

1. **Role Persistence**: When users log back in, their role defaults to "patient" because roles are not yet persisted in Firestore. This will be fixed when we implement Firestore integration.

2. **Doctor Profile Storage**: Doctor professional information (license, specialization, etc.) is collected but not yet stored permanently.

3. **Limited Dashboard**: Home screen shows role-appropriate UI but limited functionality.

## 🗂️ Project Structure

```
lib/
├── models/
│   ├── user.dart              # User model with role system
│   └── doctor_profile.dart    # Doctor professional profile
├── providers/
│   └── auth_provider.dart     # Authentication state management
├── screens/
│   ├── auth/
│   │   ├── user_type_selection_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── doctor_registration_screen.dart
│   └── home/
│       └── home_screen.dart   # Role-aware dashboard
└── main.dart                  # App entry point with AuthWrapper
```

## 🚀 How to Test

1. **Run the app**: `flutter run -d emulator-5554`
2. **Test Patient Flow**:
   - Choose "I'm a Patient" → Register → Login
   - See patient-specific dashboard
3. **Test Doctor Flow**:
   - Choose "I'm a Doctor" → Complete professional registration
   - See doctor-specific dashboard with medical info

## 📋 Next Steps (Week 2)

- [ ] Firestore integration for data persistence
- [ ] Role persistence on login
- [ ] Doctor profile storage and retrieval
- [ ] Enhanced dashboards with real functionality
- [ ] Doctor availability management system

## 🛠️ Tech Stack

- **Frontend**: Flutter with Material Design 3
- **State Management**: Riverpod
- **Authentication**: Firebase Auth
- **Database**: Firebase Firestore (Week 2)
- **Platform**: Android, iOS, Web support
