import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/settings_service.dart';

class SettingsRepository {
  const SettingsRepository(this._service);
  final SettingsService _service;

  Future<SettingsSnapshot> load() => _service.load();
  Future<void> saveTheme(ThemeMode mode) => _service.saveTheme(mode);
  Future<void> saveLocale(Locale locale) => _service.saveLocale(locale);
  Future<void> saveOnboarding(bool value) => _service.saveOnboarding(value);
  Future<void> saveSession({required bool signedIn, UserProfile? profile}) => _service.saveSession(signedIn: signedIn, profile: profile);
}
