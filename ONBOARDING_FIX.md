# Onboarding Per-User Fix

## Issue Identified
New users were being shown as having completed onboarding with "Kenya" selected, even though they had never gone through the onboarding process. This happened because device preferences were being used for user-specific onboarding data.

## Root Cause
The app was incorrectly using **device-level preferences** for **user-specific onboarding** data:

1. **Previous user** (or test) completed onboarding and selected Kenya
2. **Device preferences** stored: `onboardingCompleted: true, startingCountry: "Kenya"`
3. **New user** signs up with: `onboardingCompleted: false, startingCountry: ""`
4. **AuthWrapper logic** used device preferences as fallback → skipped onboarding for new user

### Problematic Logic (Before Fix)
```dart
// ❌ WRONG: Used device preferences for user-specific onboarding
final isOnboardingCompleted = deviceOnboardingCompleted || userOnboardingCompleted;
final hasStartingCountry = deviceStartingCountry.isNotEmpty || userStartingCountry.isNotEmpty;
```

## Solution Implemented

### 1. **Fixed AuthWrapper Logic**
Now only uses **user-specific** onboarding status:
```dart
// ✅ CORRECT: Only use user-specific onboarding data
final isOnboardingCompleted = userOnboardingCompleted;
final hasStartingCountry = userStartingCountry.isNotEmpty;
```

### 2. **Removed Device Preferences from Onboarding Process**
Previously, completing onboarding would save to device preferences:
```dart
// ❌ REMOVED: Don't pollute device preferences with user-specific data
await DevicePreferences.setOnboardingCompleted(true);
await DevicePreferences.setStartingCountry(state.startingCountry);
```

Now, onboarding only saves to:
- User's Firestore document (persistent, user-specific)
- In-memory settings store (current session only)

### 3. **Fixed HomeBloc Country Resolution**
Previously checked device preferences as fallback:
```dart
// ❌ REMOVED: Device preferences fallback
final deviceCountry = await DevicePreferences.getStartingCountry();
```

Now only uses user-specific sources:
- User's saved settings (Firebase)
- In-memory settings store (current session)

## Result

✅ **Each user now completes their own onboarding**
✅ **Device preferences no longer interfere with user-specific data**
✅ **New users will be properly redirected to onboarding**
✅ **Country selection is per-user, not per-device**

## Expected Behavior After Fix

### New User Flow
1. User signs up → User document created with `isOnboardingCompleted: false`
2. AuthWrapper checks **only user settings** → sees onboarding incomplete
3. User redirected to **OnboardingPage** 
4. User completes onboarding → saves to **user document only**
5. Next login → checks user document → goes to HomePage with selected country

### Existing User Flow
1. User logs in → User document loaded with their settings
2. If they completed onboarding → goes to HomePage with their country
3. If they didn't complete onboarding → goes to OnboardingPage

## Files Modified

1. **`auth_wrapper.dart`**
   - Removed device preferences dependency
   - Simplified logic to use only user-specific data
   - Removed unnecessary FutureBuilder for device preferences

2. **`onboarding_bloc.dart`**
   - Removed device preferences storage from completion process
   - Onboarding now only saves to user document and memory store

3. **`home_bloc.dart`**
   - Removed device preferences fallback from `_getStartingCountry()`
   - Now only uses user-specific data sources

## Device Preferences Purpose Clarified

Device preferences should only be used for:
- **Device-level settings** (theme, font size, etc.)
- **App-level preferences** (language, notifications)
- **Non-user-specific data**

Device preferences should **NOT** be used for:
- User onboarding status
- User-selected countries or preferences
- Any user-specific application state

This ensures a clean separation between device-level and user-level data.