import 'package:hive/hive.dart';
import 'package:kuma/core/constants/app_constants.dart';
import 'package:kuma/shared/domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUserSettings(UserSettings settings);
  Future<UserSettings?> getLastUserSettings();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final HiveInterface hive;

  AuthLocalDataSourceImpl({required this.hive});

  @override
  Future<void> cacheUserSettings(UserSettings settings) async {
    final box = await hive.openBox(AppConstants.CACHE_USER_SETTINGS);
    await box.put('user_settings', settings.toJson());
  }

  @override
  Future<UserSettings?> getLastUserSettings() async {
    try {
      final box = await hive.openBox(AppConstants.CACHE_USER_SETTINGS);
      final data = box.get('user_settings');
      if (data != null) {
        return UserSettings.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    final box = await hive.openBox(AppConstants.CACHE_USER_SETTINGS);
    await box.clear();
  }
}