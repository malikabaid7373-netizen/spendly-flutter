import 'package:flutter/material.dart';

import '../data/models/user_profile.dart';
import '../data/repositories/settings_repository.dart';

class AppSettingsViewModel extends ChangeNotifier {
  AppSettingsViewModel(this._repository);
  final SettingsRepository _repository;

  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');
  bool _onboardingCompleted = false;
  bool _signedIn = false;
  bool _initialized = false;
  bool _splashFinished = false;
  UserProfile? _profile;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isSignedIn => _signedIn;
  bool get isInitialized => _initialized;
  bool get splashFinished => _splashFinished;
  UserProfile? get profile => _profile;

  Future<void> initialize() async {
    final snapshot = await _repository.load();
    _themeMode = snapshot.themeMode;
    _locale = snapshot.locale;
    _onboardingCompleted = snapshot.onboardingCompleted;
    _signedIn = snapshot.signedIn;
    _profile = snapshot.profile;

    // Migrate the original portfolio sample profile to the owner's name.
    if (_profile?.email == 'demo@spendly.app' || _profile?.name == 'Malik Abaid') {
      _profile = const UserProfile(name: 'Abaid', email: 'abaid@spendly.app');
      await _repository.saveSession(signedIn: _signedIn, profile: _profile);
    }

    _initialized = true;
    notifyListeners();
  }

  void finishSplash() {
    if (_splashFinished) return;
    _splashFinished = true;
  }

  Future<void> completeOnboarding() async {
    _onboardingCompleted = true;
    await _repository.saveOnboarding(true);
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _repository.saveTheme(_themeMode);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _repository.saveLocale(locale);
  }

  Future<void> register({required String name, required String email}) async {
    _profile = UserProfile(name: name.trim(), email: email.trim().toLowerCase());
    _signedIn = true;
    await _repository.saveSession(signedIn: true, profile: _profile);
  }

  Future<void> login({required String email}) async {
    final existing = _profile;
    final fallbackName = email.split('@').first.replaceAll('.', ' ');
    _profile = existing ?? UserProfile(name: _titleCase(fallbackName), email: email.trim().toLowerCase());
    _signedIn = true;
    await _repository.saveSession(signedIn: true, profile: _profile);
  }

  Future<void> enterDemo() async {
    _profile = const UserProfile(name: 'Abaid', email: 'abaid@spendly.app');
    _signedIn = true;
    _onboardingCompleted = true;
    await _repository.saveOnboarding(true);
    await _repository.saveSession(signedIn: true, profile: _profile);
  }

  Future<void> logout() async {
    _signedIn = false;
    await _repository.saveSession(signedIn: false, profile: _profile);
  }

  String _titleCase(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
