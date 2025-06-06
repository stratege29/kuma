# Onboarding Navigation Fix

## Issue Identified
After completing onboarding and clicking "Commencer", the app wasn't navigating to the HomePage. Users would remain on the onboarding completion screen, and only after restarting the app would they see the HomePage with their selected country.

## Root Cause Analysis
The problem was a **state synchronization issue** between onboarding completion and authentication state:

1. **User completes onboarding** → OnboardingBloc saves settings to Firestore
2. **OnboardingPage navigates to splash** → AuthWrapper recreated
3. **AuthBloc uses cached user data** → still shows `isOnboardingCompleted: false`
4. **AuthWrapper redirects back to onboarding** → infinite loop
5. **Only on app restart** → fresh data loaded from Firestore

### The Core Problem
- **OnboardingBloc** updated user document in Firestore ✓
- **AuthBloc** never knew the data changed ✗
- **Navigation timing** was too fast for Firestore propagation ✗

## Solution Implemented

### 1. **Enhanced AuthBloc with RefreshUserData Event**
Added a new event to force fresh user data retrieval:
```dart
// New event
const factory AuthEvent.refreshUserData() = _RefreshUserData;

// New handler
Future<void> _onRefreshUserData() async {
  // Fetches fresh user data from Firestore and updates auth state
}
```

### 2. **Increased Onboarding Completion Delay**
Extended the delay after saving settings to ensure Firestore propagation:
```dart
// Before: 500ms - insufficient for Firestore consistency
await Future.delayed(const Duration(milliseconds: 500));

// After: 1500ms - allows proper Firestore propagation
await Future.delayed(const Duration(milliseconds: 1500));
```

### 3. **Enhanced SaveUserSettings Debugging**
Added comprehensive logging to track the settings saving process:
- Local storage confirmation
- Firestore update confirmation  
- Settings comparison (old vs new)
- Error tracking for failed operations

### 4. **Improved AuthWrapper Initialization**
Ensured AuthWrapper always performs fresh auth checks:
```dart
create: (context) {
  final authBloc = sl<AuthBloc>();
  // Always do a fresh auth check when AuthWrapper is created
  authBloc.add(const AuthEvent.checkAuthStatus());
  return authBloc;
}
```

## Expected Flow After Fix

### Successful Onboarding Completion:
1. **User clicks "Commencer"** → OnboardingBloc.completeOnboarding() called
2. **Settings saved** → Firestore document updated with `isOnboardingCompleted: true`
3. **Extended delay** → Allows Firestore write to propagate (1.5 seconds)
4. **Navigation triggered** → Goes to splash route (AuthWrapper)
5. **Fresh auth check** → AuthBloc fetches updated user data from Firestore
6. **Updated state** → AuthWrapper sees `isOnboardingCompleted: true`
7. **HomePage navigation** → User directed to HomePage with selected country

### Debug Logs Expected:
```
OnboardingBloc: Starting completion process...
OnboardingBloc: Created settings - Country: [COUNTRY], Completed: true
AuthRepository: Saving user settings...
AuthRepository: Settings to save - Country: [COUNTRY], Completed: true
AuthRepository: User data updated in Firestore successfully
OnboardingBloc: Waiting for Firestore persistence and propagation...
OnboardingBloc: Onboarding completion process finished successfully
OnboardingPage: Onboarding completed, navigating to splash
AuthRepository: Getting current Firebase user...
AuthRepository: Getting user data for: [USER_ID]
AuthBloc: User found: [USER_ID]
AuthWrapper: User onboarding: true, country: "[COUNTRY]"
AuthWrapper: Final decision - completed: true, hasCountry: true
AuthWrapper: Onboarding completed with country selection ([COUNTRY]), navigating to HomePage
```

## Files Modified

1. **`auth_event.dart`** - Added `refreshUserData` event
2. **`auth_bloc.dart`** - Added refresh user data handler  
3. **`onboarding_bloc.dart`** - Increased completion delay to 1.5 seconds
4. **`onboarding_page.dart`** - Simplified navigation logic
5. **`auth_repository_impl_v2.dart`** - Enhanced saveUserSettings with detailed logging
6. **`auth_wrapper.dart`** - Ensured fresh auth checks on creation

## Prevention Measures

To prevent similar issues in the future:
- **State synchronization** between different BLoCs is now more robust
- **Firestore propagation delays** are properly accounted for
- **Debug logging** provides visibility into the flow
- **Fresh data checks** ensure consistency after navigation

The onboarding completion should now work seamlessly, with users being immediately directed to the HomePage after completing their setup!