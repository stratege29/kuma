import 'package:hive_flutter/hive_flutter.dart';

/// Device-level preferences that persist across user sessions
class DevicePreferences {
  static const String _boxName = 'device_preferences';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyStartingCountry = 'starting_country';
  
  static Box? _box;
  
  /// Initialize the preferences box
  static Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }
  
  /// Get if onboarding has been completed on this device
  static Future<bool> getOnboardingCompleted() async {
    await init();
    return _box?.get(_keyOnboardingCompleted, defaultValue: false) ?? false;
  }
  
  /// Set onboarding completion status
  static Future<void> setOnboardingCompleted(bool completed) async {
    await init();
    await _box?.put(_keyOnboardingCompleted, completed);
  }
  
  /// Get the starting country chosen during onboarding
  static Future<String?> getStartingCountry() async {
    await init();
    return _box?.get(_keyStartingCountry);
  }
  
  /// Set the starting country
  static Future<void> setStartingCountry(String country) async {
    await init();
    await _box?.put(_keyStartingCountry, country);
  }
  
  /// Clear all device preferences (only for testing or app reset)
  static Future<void> clearAll() async {
    await init();
    await _box?.clear();
  }
}