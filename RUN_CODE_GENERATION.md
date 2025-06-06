# Fix Freezed Code Generation Error

## The Error
```
The name '_RefreshUserData' isn't a type, so it can't be used as a type argument.
```

This error occurs because we added a new event `refreshUserData` to the AuthEvent but haven't generated the Freezed code yet.

## Solution

Run the following command in your terminal from the project root directory:

```bash
cd /Users/arnaudkossea/development/kuma
flutter pub run build_runner build --delete-conflicting-outputs
```

This command will:
1. Generate the missing `_RefreshUserData` class
2. Update all Freezed files (`.freezed.dart` and `.g.dart`)
3. Delete any conflicting outputs

## Alternative Commands

If the above doesn't work, try:

```bash
# Clean first, then build
flutter pub run build_runner clean
flutter pub run build_runner build

# Or watch for changes (useful during development)
flutter pub run build_runner watch
```

## What This Generates

The build_runner will generate:
- `auth_event.dart` → Updates `auth_bloc.freezed.dart` with `_RefreshUserData` class
- All other Freezed unions and data classes in the project

## After Generation

Once the code generation completes successfully:
1. The `_RefreshUserData` error will be resolved
2. The app will compile successfully
3. The onboarding navigation fix will work as intended

## Prevention

To avoid this in the future:
- Always run `build_runner` after modifying Freezed classes
- Consider using `build_runner watch` during development
- Check for `.freezed.dart` files when you see "type not found" errors