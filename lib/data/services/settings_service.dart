import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class SettingsSnapshot {
  const SettingsSnapshot({required this.themeMode, required this.locale, required this.onboardingCompleted, required this.signedIn, required this.profile});

  final ThemeMode themeMode;
  final Locale locale;
  final bool onboardingCompleted;
  final bool signedIn;
  final UserProfile? profile;
}

class SettingsService {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _onboardingKey = 'onboarding_completed';
  static const _signedInKey = 'signed_in';
  static const _profileKey = 'profile';

  Future<SettingsSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? 'dark';
    final localeCode = prefs.getString(_localeKey) ?? 'en';
    final profileJson = prefs.getString(_profileKey);
    return SettingsSnapshot(
      themeMode: themeName == 'light' ? ThemeMode.light : ThemeMode.dark,
      locale: Locale(localeCode),
      onboardingCompleted: prefs.getBool(_onboardingKey) ?? false,
      signedIn: prefs.getBool(_signedInKey) ?? false,
      profile: profileJson == null ? null : UserProfile.fromJson(profileJson),
    );
  }

  Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == ThemeMode.light ? 'light' : 'dark');
  }

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> saveOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, value);
  }

  Future<void> saveSession({required bool signedIn, UserProfile? profile}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, signedIn);
    if (profile != null) await prefs.setString(_profileKey, profile.toJson());
  }
}
