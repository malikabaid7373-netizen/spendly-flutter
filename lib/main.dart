import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/finance_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/local_database_service.dart';
import 'data/services/settings_service.dart';
import 'view_models/app_settings_view_model.dart';
import 'view_models/finance_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = LocalDatabaseService();
  final settingsService = SettingsService();
  final financeRepository = FinanceRepository(databaseService);
  final settingsRepository = SettingsRepository(settingsService);

  final appSettings = AppSettingsViewModel(settingsRepository);
  final finance = FinanceViewModel(financeRepository);

  await appSettings.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appSettings),
        ChangeNotifierProvider.value(value: finance),
      ],
      child: SpendlyApp(settings: appSettings),
    ),
  );

  // Load finance data after the first frame so the splash can appear immediately.
  unawaited(finance.load());
}
